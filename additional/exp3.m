% % Exp3
% % This script rectifies images and depth, and tries the depth registration 
% pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/october';
pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final';

% % Read the images from davis (first, adjust the contrast)
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

% keyboard
[imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_davis, filenames_kinect);
% [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_kinect, filenames_davis);
pairsUsed
% Generate world coordinates of the checkerboard points and compute camera
% parameters
% squareSize = 30; % millimeters
squareSize = 27; % millimeters --> for october folder!!!!
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
stereoParams = estimateCameraParameters(imagePoints, worldPoints);

% Now read the disparity
%add libraries for smoothing and inpainting the Kinect depth
addpath('./inpaintZ'); 
addpath('./inpaintZ/bmorph');
% pathname_depth = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/october';
pathname_depth = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final';

% First, read the depth file and format it to get Z
selected_depth = dir(fullfile(pathname_depth, 'd-*.pgm'));
numImages_depth = numel(selected_depth);
for k = 1:numImages_depth
   filenames_depth{k} = fullfile(pathname_depth, selected_depth(k).name); % Reading pgm
%    depth_tmp=double(swapbytes(imread(filenames_depth{k})));
   depth_tmp=double(swapbytes(imread(filenames_depth{k})));
   [kkk,~]=depthToCloud(depth_tmp);
   realdepth_tmp=kkk(:,:,3); 
   
   % Init inpaintZ to smooth Z values
   images_depth_before(:,:,k) = depth_tmp;
   depth_tmp(depth_tmp==0)=nan;
   depth_tmp = my_inpaintZ(depth_tmp, 10^-1);
   images_depth(:,:,k) = -imresize(depth_tmp,[180 240]);
   
   images_realdepth_before(:,:,k) = imresize(realdepth_tmp, [180 240]);
   realdepth_tmp(realdepth_tmp==0)=nan;   
   realdepth_tmp = my_inpaintZ(realdepth_tmp, 10^-3);
   images_realdepth(:,:,k) = -imresize(realdepth_tmp,[180 240]);
end

% Rectify the depth images with the stereo params: first davis, then the
% depth
for k=1:numImages_depth
    [tmp_kinect_rect, tmp_davis_rect] = rectifyStereoImages(double(images_kinect(:,:,k)), double(images_davis(:,:,k)), stereoParams);
    [tmp_depth_rect, ~] = rectifyStereoImages(double(images_depth(:,:,k)), double(images_kinect(:,:,k)), stereoParams);
    [tmp_realdepth_rect, ~] = rectifyStereoImages(double(images_realdepth(:,:,k)), double(images_kinect(:,:,k)), stereoParams);
    
    davis_rect(:,:,k)= tmp_davis_rect;
    kinect_rect(:,:,k)= tmp_kinect_rect;
    depth_rect(:,:,k)= tmp_depth_rect;
    realdepth_rect(:,:,k)= tmp_realdepth_rect;
end

% save worksp;
save worksp;

% load worksp; % worksp contains the workspace from here to the top
% 
% % Now, register davis_rect and depth_rect
% [optimizer, metric] = imregconfig('multimodal');
% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 300;
% 
% for k=1:numImages
%     close all
%     movingRegistered = imregister(depth_rect(:,:,k), davis_rect(:,:,k), 'translation', optimizer, metric);
%     registered_depth(:,:,k) = movingRegistered;
%     
%     figure, imshowpair(movingRegistered, davis_rect(:,:,k), 'falsecolor')
%     keyboard
% end


