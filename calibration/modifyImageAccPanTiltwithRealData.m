% Apply transformation to original image according to the camera - PTU calibration
% 

% angle_pan = 0;
% angle_tilt = -5*pi/180;

load('worksp_ptu_calib', 'r_pan', 'r_tilt', 'v_pan', 'v_tilt','w_pan', 'w_tilt');
load('~/WORK/DAVIS/worksp', 'stereoParams'); % This is from the stereo calibration in ~/WORK/DAVIS/exp3.m between Davis and Kinect

cameraParams = stereoParams.CameraParameters1; % Davis is camera 1

angle_pan = 0;
angle_tilt = -5*pi/180;

% r_pan= [-0.052 0.997 -0.052];
% r_tilt= [-0.940 0.324 -0.105];
% v_pan= [46.554 312.956 -3.629];
% v_tilt= [-221.493 -86.002 -2.419];
% w_pan= [0.053 0.997 -0.053];
% w_tilt= [-0.994 0.110 -0.016];

% cameraParams.FocalLength= [546.0794 549.6377];
% cameraParams.PrincipalPoint= [322.5364 246.0242];
     

% read images
% image_base = imresize(rgb2gray(imread('image_base.bmp')), [480 640]);
% image_m5tilt = imresize(rgb2gray(imread('image_m5tilt.bmp')), [480 640]);

image_base = imread('~/Desktop/PTU/output/pan/frame_00001.pgm');
image_m5tilt = imread('~/Desktop/PTU/output/tilt/frame_00120.pgm');


% Compute the translation and rotation
[Trans_pan, Rot_pan] = computeRotationTranslationFromPanTiltAngle(angle_pan, r_pan, v_pan, w_pan);
[Trans_tilt, Rot_tilt] = computeRotationTranslationFromPanTiltAngle(angle_tilt, r_tilt, v_tilt, w_tilt);

% % Now get the coordinates
% [height,width] = size(image_base);
% [XX, YY] = meshgrid(1:width, 1:height);

% Apply pan transfromation
M_pan = [Rot_pan,Trans_pan'];
M_pan(4,:) = [0 0 0 1];

% Apply tilt transfromation
M_tilt = [Rot_tilt,Trans_tilt'];
M_tilt(4,:) = [0 0 0 1];
%image_pantilt = imwarp(image_pan, tform_tilt);
%worldPoints = pointsToWorld(cameraParams,rotationMatrix,translationVector,imagePoints);


% M = M_tilt;

% load('worksp', 'cameraParams');
% [height,width] = size(image_base);
% [XX, YY] = meshgrid(1:width, 1:height);
% I1 = undistortImage(image_base, cameraParams);
% imagePoints = [XX(:) YY(:)];
% 
% % Now it is X_world, Y_world, Z_world=0
% worldPoints = pointsToWorld(cameraParams,Rot_tilt,Trans_tilt,imagePoints);
% X_trans = worldPoints(:,1); Y_trans = worldPoints(:,2);
% 
% u = floor(cameraParams.FocalLength(1)*X_trans  + cameraParams.PrincipalPoint(1) +0.5);
% v = floor(cameraParams.FocalLength(2)*Y_trans  + cameraParams.PrincipalPoint(2) +0.5);
% 
% u_res = reshape(u, height, width); v_res = reshape(v, height, width);
% 
% UV(:,:,1)=u_res-XX; UV(:,:,2)=v_res-YY;
% B = imwarp(image_base, UV);



% From 2D to 3D

%%
M = [Rot_tilt,Trans_tilt'];
M(4,:) = [0 0 0 1];

[height,width] = size(image_base);
[uu, vv] = meshgrid(1:width, 1:height);
X_realWorld = uu - cameraParams.PrincipalPoint(1);
Y_realWorld = vv - cameraParams.PrincipalPoint(2);
Z_realWorld = cameraParams.FocalLength(1);
% Z_realWorld = 0;

% From 3D to transformed 3D
X_trans = X_realWorld*M(1,1) + Y_realWorld*M(1,2) + Z_realWorld*M(1,3) + M(1,4);
Y_trans = X_realWorld*M(2,1) + Y_realWorld*M(2,2) + Z_realWorld*M(2,3) + M(2,4);
Z_trans = X_realWorld*M(3,1) + Y_realWorld*M(3,2) + Z_realWorld*M(3,3) + M(3,4);

% From 3D to 2D again
inv_Z = 1.0./Z_trans;
inv_Z(Z_trans==0)=1;

u = floor((cameraParams.FocalLength(1)*X_trans).*inv_Z + cameraParams.PrincipalPoint(1) +0.5);
v = floor((cameraParams.FocalLength(2)*Y_trans).*inv_Z + cameraParams.PrincipalPoint(2) +0.5);

UV(:,:,1)=u-uu; UV(:,:,2)=v-vv;
B = imwarp(image_base, UV);



% UV(:,:,1)=u_davis-XX; UV(:,:,2)=v_davis-YY;
% B = imwarp(image_base, UV);

% function [newImage] = modifyImageAccPanTilt(origImage, angle_pan, angle_tilt, r_pan, r_tilt, v_pan, v_tilt, w_pan, w_tilt)
% 
%     [Trans_pan, Rot_pan] = computeRotationTranslationFromPanTiltAngle(angle_pan, r_pan, v_pan, w_pan);
%     [Trans_tilt, Rot_tilt] = computeRotationTranslationFromPanTiltAngle(angle_tilt, r_tilt, v_tilt, w_tilt);
% 
% 
%     % Compute the 
%     
%     
% 
% 
% end