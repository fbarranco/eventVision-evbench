% exp2
%             
% DESCRIPTION
%   script exp2
%
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.


% imadjust or imsharpen do not help, the error is the same
% pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final';
% 
% % Read the images from davis (first, adjust the contrast)
% selected_davis= dir(fullfile(pathname, 'davis_*.pgm'));
% for k = 1:numel(selected_davis)
%    im_tmp = imread(fullfile(pathname, selected_davis(k).name)); % Reading pgm
% %    imwrite(imadjust(im_tmp), fullfile(pathname, strcat('adj_', selected_davis(k).name)))
%    imwrite(imsharpen(im_tmp), fullfile(pathname, strcat('adj_', selected_davis(k).name)))   
% end
% 
% 
% keyboard

% Exp2
% This script tries the rectification that Matlab uses 
% pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/worked2';
pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/worked';

% Read the images from davis (first, adjust the contrast)
selected_davis= dir(fullfile(pathname, 'davis_*.pgm'));
numImages = numel(selected_davis);
for k = 1:numel(selected_davis)
   filenames_davis{k} = fullfile(pathname, selected_davis(k).name); % Reading pgm
   images_davis(:,:,k)=imread(filenames_davis{k});
end


% Read the images from Kinect
selected_kinect= dir(fullfile(pathname, 'kinect_*.pgm'));
for k = 1:numel(selected_kinect)
    filenames_kinect{k} = fullfile(pathname, selected_kinect(k).name); % Reading pgm   imwrite(imresize(I, [480 640], 'bicubic'), strcat(sprintf('davis_%04d', k),'.pgm'));
    images_kinect(:,:,k)=imread(filenames_kinect{k});
end

% keyboard
[imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_davis, filenames_kinect);
%[imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_kinect, filenames_davis);
pairsUsed


% for k=1:numImages
%     figure, imshow(images_davis(:,:,k), 'InitialMagnification', 50);
%     hold on;
%     plot(imagePoints(:, 1, k, 1), imagePoints(:, 2, k, 1), '*-g');    
%     keyboard
% end
% 
%     
% for k=1:numImages
%     figure, imshow(images_kinect(:,:,k), 'InitialMagnification', 50);
%     hold on;
%     plot(imagePoints(:, 1, k, 2), imagePoints(:, 2, k, 2), '*-g');    
%     keyboard
% end

% Generate world coordinates of the checkerboard points.
squareSize = 30; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Compute the stereo camera parameters
% stereoParams = estimateCameraParameters(imagePoints, worldPoints, 'NumRadialDistortionCoefficients',3);
stereoParams = estimateCameraParameters(imagePoints, worldPoints);

% Evaluate calibration accuracy.
figure;
showReprojectionErrors(stereoParams);

% keyboard

% Read in the stereo pair of images.
I1 = imread(fullfile(pathname, selected_davis(1).name));
I2 = imread(fullfile(pathname, selected_kinect(1).name));


% Rectify the images.
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

% Display the images before rectification.
figure;
imshow(stereoAnaglyph(I1, I2), 'InitialMagnification', 50);
title('Before Rectification');

% Display the images after rectification.
figure;
imshow(stereoAnaglyph(J1, J2), 'InitialMagnification', 50);
title('After Rectification');
keyboard

