function outDepth = registerDepth(inDepth, stereoParams)


% This experiment register depth using stereoParams (from stereo
% calibration) and does it for all the images in the folder

%add libraries for smoothing and inpainting the Kinect depth
addpath('./inpaintZ'); 
addpath('./inpaintZ/bmorph');

inv_depth_fx = 1.0 / stereoParams.CameraParameters2.FocalLength(1);
inv_depth_fy = 1.0 / stereoParams.CameraParameters2.FocalLength(2);
depth_cx = stereoParams.CameraParameters2.PrincipalPoint(1); 
depth_cy = stereoParams.CameraParameters2.PrincipalPoint(2);
depth_Tx = 0; depth_Ty = 0;

davis_fx = stereoParams.CameraParameters1.FocalLength(1);
davis_fy = stereoParams.CameraParameters1.FocalLength(2);
davis_cx = stereoParams.CameraParameters1.PrincipalPoint(1);
davis_cy = stereoParams.CameraParameters1.PrincipalPoint(2);
davis_Tx = 0; davis_Ty = 0;

height = size(inDepth,1);
width= size(inDepth,2);
undist_depth = zeros(size(inDepth));
undist_davis = zeros(size(inDepth));
undist_kinect = zeros(size(inDepth));
davis_depth = zeros(size(inDepth));


% Estimate transformation
R = stereoParams.RotationOfCamera2;
T = stereoParams.TranslationOfCamera2;

% 3-D Matrix transformation: homogeneous coordinates
M = [R,T'];
M(4,:) = [0 0 0 1];


% Read images
depth = inDepth*1000; % in mm

% Use undistorted images
[undist_depth, ~] = undistortImage(depth, stereoParams.CameraParameters2, 'FillValue', nan);


if sum(sum(isnan(undist_depth)))
    undist_depth = my_inpaintZ(double(undist_depth), 10^-1);
end

depth = undist_depth;

% Depth to world coordinates: xyz_depth
[XX, YY] = meshgrid(1:width, 1:height);
X_depth = (XX-depth_cx).*depth*inv_depth_fx;
Y_depth = (YY-depth_cy).*depth*inv_depth_fy;
Z_depth = depth;

% Transform to DAVIS Camera Frame (still real-world)
X_davis = M(1,1)*X_depth + M(1,2)*Y_depth + M(1,3)*Z_depth + M(1,4);
Y_davis = M(2,1)*X_depth + M(2,2)*Y_depth + M(2,3)*Z_depth + M(2,4);
Z_davis = M(3,1)*X_depth + M(3,2)*Y_depth + M(3,3)*Z_depth + M(3,4);

% Project to 2D (u,v) the 3D world coordinates in DAVIS camera frame
inv_Z = 1.0./Z_davis;    
u_davis = round((davis_fx*X_davis + davis_Tx).*inv_Z + davis_cx);
v_davis = round((davis_fy*Y_davis + davis_Ty).*inv_Z + davis_cy);

reg_depth = nan(height, width);
for ii=1:height
    for jj=1:width

        if (isnan(u_davis(ii,jj)) || isnan(v_davis(ii,jj)) || round(u_davis(ii,jj))<1 || round(u_davis(ii,jj))> width || round(v_davis(ii,jj))<1 || round(v_davis(ii,jj))> height) 
           continue;
        end

        new_depth = Z_davis(ii,jj);

        % Z-buffer check    
        if isnan(reg_depth(round(v_davis(ii,jj)),round(u_davis(ii,jj)))) || reg_depth(round(v_davis(ii,jj)),round(u_davis(ii,jj))) > new_depth
            reg_depth(round(v_davis(ii,jj)),round(u_davis(ii,jj))) = new_depth;
        end
    end
end

mask_nan = isnan(reg_depth);
filt = mediannan(reg_depth, 3);
filt(mask_nan) = nan; %In this way I keep nan for inpaintZ but get rid of outliers in Z

% Init inpaintZ to smooth Z values
distance_tmp = double(filt);
outDepth = my_inpaintZ(distance_tmp, 10^-1);
outDepth = outDepth*0.001;% back in meters

