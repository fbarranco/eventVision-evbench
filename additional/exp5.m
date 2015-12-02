% This experiment register depth using stereoParams (from stereo
% calibration)

%add libraries for smoothing and inpainting the Kinect depth
addpath('./inpaintZ'); 
addpath('./inpaintZ/bmorph');

% load data from calibration in exp3
%The stereo calibration was: image1 -- kinect, image2 -- davis
% load('worksp_cam1kinect_cam2davis', 'images_davis', 'images_kinect', 'images_depth', 'images_realdepth', ...
%         'filenames_davis', 'filenames_kinect', 'filenames_depth', ...  
%         'stereoParams');

%The stereo calibration was: image1 -- davis, image2 -- kinect
% load('worksp_cam1davis_cam2kinect', 'images_davis', 'images_kinect', 'images_depth', 'images_realdepth', ...
%         'filenames_davis', 'filenames_kinect', 'filenames_depth', ...  
%         'stereoParams');

% load('worksp', 'images_davis', 'images_kinect', 'images_depth', 'images_realdepth', ...
%         'filenames_davis', 'filenames_kinect', 'filenames_depth', ...  
%         'stereoParams');

load('worksp', 'images_davis', 'images_kinect', 'images_depth', 'images_realdepth', ...
        'filenames_davis', 'filenames_kinect', 'filenames_depth', ...  
        'stereoParams');    
    
%%    
% inv_depth_fx = 1.0 / stereoParams.CameraParameters1.FocalLength(1);
% inv_depth_fy = 1.0 / stereoParams.CameraParameters1.FocalLength(2);
% depth_cx = stereoParams.CameraParameters1.PrincipalPoint(1); 
% depth_cy = stereoParams.CameraParameters1.PrincipalPoint(2);
% depth_Tx = 0; depth_Ty = 0;
% 
% davis_fx = stereoParams.CameraParameters2.FocalLength(1);
% davis_fy = stereoParams.CameraParameters2.FocalLength(2);
% davis_cx = stereoParams.CameraParameters2.PrincipalPoint(1);
% davis_cy = stereoParams.CameraParameters2.PrincipalPoint(2);
% davis_Tx = 0; davis_Ty = 0;


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

% Read images
depth = images_realdepth(:,:,1); % in meters
depth = depth*1000; % in mm
davis = images_davis(:,:,1);
kinect = images_kinect(:,:,1);

% Let's use undistorted images
[undist_kinect, ~] = undistortImage(kinect, stereoParams.CameraParameters2, 'FillValue', nan);
[undist_depth, ~] = undistortImage(depth, stereoParams.CameraParameters2, 'FillValue', nan);
[undist_davis, ~] = undistortImage(davis, stereoParams.CameraParameters1, 'FillValue', nan);

if sum(sum(isnan(undist_depth)))
    undist_depth = my_inpaintZ(double(undist_depth), 10^-1);
end

kinect = undist_kinect;
depth = undist_depth;
davis = undist_davis;

height = size(depth,1);
width= size(depth,2);

% Estimate transformation
R = stereoParams.RotationOfCamera2;
T = stereoParams.TranslationOfCamera2;

% 3-D Matrix transformation: homogeneous coordinates
M = [R,T'];
M(4,:) = [0 0 0 1];
% M = inv(M);

% M = [eye(3),T'];
% M(4,:) = [0 0 0 1];

% M = [R,[0 0 0]'];
% M(4,:) = [0 0 0 1];

% M = [eye(3),[0 0 0]'];
% M(4,:) = [0 0 0 1];

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
u_davis = floor((davis_fx*X_davis + davis_Tx).*inv_Z + davis_cx +0.5);
v_davis = floor((davis_fy*Y_davis + davis_Ty).*inv_Z + davis_cy +0.5);

% u_davis = (1/inv_depth_fx*X_davis).*inv_Z + depth_cx +0.5;
% v_davis = (1/inv_depth_fy*Y_davis).*inv_Z + depth_cy +0.5;

% UV(:,:,1)=u_davis-XX; UV(:,:,2)=v_davis-YY;
% B = imwarp(depth, UV);

%%
reg_depth = nan(height, width);
for ii=1:height
    for jj=1:width
        
        if (round(u_davis(ii,jj))<1 || round(u_davis(ii,jj))> width || round(v_davis(ii,jj))<1 || round(v_davis(ii,jj))> height) 
           continue;
        end
        
        new_depth = Z_davis(ii,jj);
        % Z-buffer check
%         if reg_depth(u_davis(ii,jj),v_davis(ii,jj)) > new_depth
%             reg_depth(u_davis(ii,jj),v_davis(ii,jj)) = new_depth;
%         end
        
        if isnan(reg_depth(round(v_davis(ii,jj)),round(u_davis(ii,jj)))) || reg_depth(round(v_davis(ii,jj)),round(u_davis(ii,jj))) > new_depth
            reg_depth(round(v_davis(ii,jj)),round(u_davis(ii,jj))) = new_depth;
        end
    end
end


%%
mask_nan = isnan(reg_depth);
filt = mediannan(reg_depth, 3);
filt(mask_nan) = nan; %In this way I keep nan for inpaintZ but get rid of outliers in Z

% Init inpaintZ to smooth Z values
distance_tmp = double(filt);
distance_new = my_inpaintZ(distance_tmp, 10^-1);

figure, imshowpair(distance_new, davis, 'falsecolor')
