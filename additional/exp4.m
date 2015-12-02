% Exp4.m
% This script uses stereoParams from ./worked folder for rectifying images
% in ./final folder (to see if the rectification conditions where the same)


% THIS DOESN'T WORK WITH WORKED AND FINAL, THE CAMERA STEREO RIG CONFIGURATION WASN'T THE SAME/OR SIMILAR


pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final';

% Read the images from davis (first, adjust the contrast)
selected_davis= dir(fullfile(pathname, 'davis_*.pgm'));
numImages = numel(selected_davis);
for k = 1:numImages
   filenames_davis{k} = fullfile(pathname, selected_davis(k).name); % Reading pgm
   images_davis(:,:,k)=imread(filenames_davis{k});
end

% Read the images from Kinect
selected_kinect= dir(fullfile(pathname, 'kinect_*.pgm'));
for k = 1:numImages
    filenames_kinect{k} = fullfile(pathname, selected_kinect(k).name); % Reading pgm   imwrite(imresize(I, [480 640], 'bicubic'), strcat(sprintf('davis_%04d', k),'.pgm'));
    images_kinect(:,:,k)=imread(filenames_kinect{k});
end

% Now read the disparity
%add libraries for smoothing and inpainting the Kinect depth
addpath('./inpaintZ'); 
addpath('./inpaintZ/bmorph');
% pathname_depth = '/home/fran/WORK/calibration_data/my_output/worked_final';
pathname_depth = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final/depth';

% First, read the depth file and format it to get Z
selected_depth = dir(fullfile(pathname_depth, 'd-*.pgm'));
numImages_depth = numel(selected_depth);
for k = 1:numImages_depth
   filenames_depth{k} = fullfile(pathname_depth, selected_depth(k).name); % Reading pgm
   depth_tmp=double(swapbytes(imread(filenames_depth{k})));
   [~,realdepth_tmp]=depthToCloud(depth_tmp);
   
   % Init inpaintZ to smooth Z values
   images_depth_before(:,:,k) = depth_tmp;
   depth_tmp(depth_tmp==0)=nan;
   depth_tmp = my_inpaintZ(depth_tmp, 10^-1);
   images_depth(:,:,k) = -depth_tmp;
   
   images_realdepth_before(:,:,k) = realdepth_tmp;
   realdepth_tmp(realdepth_tmp==0)=nan;   
   realdepth_tmp = my_inpaintZ(realdepth_tmp, 10^-3);
   images_realdepth(:,:,k) = -realdepth_tmp;
end

% Rectify the depth images with the stereo params: first davis, then the
% depth

%load stereoParams
load('worksp_folderworked', 'stereoParams');

for k=1:numImages_depth
    [tmp_davis_rect, tmp_kinect_rect] = rectifyStereoImages(double(images_davis(:,:,k)), double(images_kinect(:,:,k)), stereoParams);
    [~, tmp_depth_rect] = rectifyStereoImages(double(images_davis(:,:,k)), double(images_depth(:,:,k)), stereoParams);
    [~, tmp_realdepth_rect] = rectifyStereoImages(double(images_davis(:,:,k)), double(images_realdepth(:,:,k)), stereoParams);
    
    davis_rect(:,:,k)= tmp_davis_rect;
    kinect_rect(:,:,k)= tmp_kinect_rect;
    depth_rect(:,:,k)= tmp_depth_rect;
    realdepth_rect(:,:,k)= tmp_realdepth_rect;
end

keyboard

% Now, register davis_rect and depth_rect
[optimizer, metric] = imregconfig('multimodal');
optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

for k=1:numImages
    close all
    movingRegistered = imregister(depth_rect(:,:,k), davis_rect(:,:,k), 'translation', optimizer, metric);
    registered_depth(:,:,k) = movingRegistered;
    
    figure, imshowpair(movingRegistered, davis_rect(:,:,k), 'falsecolor')
    keyboard
end
