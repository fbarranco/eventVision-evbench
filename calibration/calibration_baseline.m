% % % % This script rectifies images and depth, and tries the depth registration 
% % pathname = '/home/fran/WORK/calibration cam_ptu/baseline';
% % % pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final';
% % % 
% % % % Read the images from davis (first, adjust the contrast)
% % selected= dir(fullfile(pathname, 'frame_*.pgm'));
% % numImages = numel(selected);
% % for k = 1:numImages
% %    filenames{k} = fullfile(pathname, selected(k).name); % Reading pgm
% %    images(:,:,k)=imread(filenames{k});
% % end
% % 
% % [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames);
% % pairsUsed
% % 
% % % Generate world coordinates of the checkerboard points and compute camera
% % % parameters
% % squareSize = 30; %<----- should be 27 for the last case!!!!!
% % 
% % worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% % cameraParams = estimateCameraParameters(imagePoints, worldPoints);
% % 
% % %%
% % % Once it is calibrated, read from a different file with the same angle
% % pathname = '/home/fran/WORK/calibration cam_ptu/panm4_tilt0';
% % 
% % % Read the images from davis (first, adjust the contrast)
% % selected= dir(fullfile(pathname, 'frame_*.pgm'));
% % numImages = numel(selected);
% % for k = 1:numImages
% %    filenames{k} = fullfile(pathname, selected(k).name); % Reading pgm
% %    images(:,:,k)=imread(filenames{k});
% %    
% %    %undist_images(:,:,k) = undistortImage(images(:,:,k), cameraParams);
% %    %[imagePoints, ~] = detectCheckerboardPoints(undist_images(:,:,k));    
% %    [imagePoints, ~] = detectCheckerboardPoints(images(:,:,k));    
% %    [rotationMatrix, translationVector] = extrinsics(imagePoints, cameraParams.WorldPoints, cameraParams);
% %      
% % %    figure, imshow(undist_images(:,:,k), 'InitialMagnification', 50);
% % %    hold on;
% % %    plot(imagePoints(:, 1), imagePoints(:, 2), '*-g');
% %    
% %    vectorOfRotationVectors(k,:)=(rodrigues(rotationMatrix))';
% %    vectorOfTranslationVectors(k,:) = translationVector;
% % %    close all   
% % end
% % 
% % keyboard



% % % This script rectifies images and depth, and tries the depth registration 
% pathname = '/home/fran/WORK/calibration cam_ptu/baseline';
% % pathname = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/final';
% % 
% % % Read the images from davis (first, adjust the contrast)
% selected= dir(fullfile(pathname, 'frame_*.pgm'));
% numImages = numel(selected);
% for k = 1:numImages
%    filenames{k} = fullfile(pathname, selected(k).name); % Reading pgm
%    images(:,:,k)=imread(filenames{k});
% end
% 
% [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames);
% pairsUsed
% 
% % Generate world coordinates of the checkerboard points and compute camera
% % parameters
% squareSize = 30; %<----- should be 27 for the last case!!!!!
% 
% worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% cameraParams = estimateCameraParameters(imagePoints, worldPoints);
% 
% %%
% % Once it is calibrated, read from a different file with the same angle
% pathname = '/home/fran/WORK/calibration cam_ptu/pan0_tiltm4';
% 
% % Read the images from davis (first, adjust the contrast)
% selected= dir(fullfile(pathname, 'frame_*.pgm'));
% numImages = numel(selected);
% for k = 1:numImages
%    filenames{k} = fullfile(pathname, selected(k).name); % Reading pgm
%    images(:,:,k)=imread(filenames{k});
%    
%    undist_images(:,:,k) = undistortImage(images(:,:,k), cameraParams);
%    %[imagePoints, ~] = detectCheckerboardPoints(undist_images(:,:,k));    
%    [imagePoints, ~] = detectCheckerboardPoints(undist_images(:,:,k));    
%    [rotationMatrix, translationVector] = extrinsics(imagePoints, cameraParams.WorldPoints, cameraParams);
%      
%    figure, imshow(undist_images(:,:,k), 'InitialMagnification', 50);
%    hold on;
%    plot(imagePoints(:, 1), imagePoints(:, 2), '*-g');
%    keyboard
%    vectorOfRotationVectors(k,:)=(rodrigues(rotationMatrix))';
%    vectorOfTranslationVectors(k,:) = translationVector;
% %    close all   
% end
% 
% keyboard


% % This script rectifies images and depth, and tries the depth registration 
pathname_baseline = '/home/fran/WORK/calibration cam_ptu/baseline';
pathname_pantilt = '/home/fran/WORK/calibration cam_ptu/pan0_tilt4';
% pathname_pantilt = '/home/fran/WORK/calibration cam_ptu/pan0_tiltm4';
% pathname_pantilt = '/home/fran/WORK/calibration cam_ptu/pan4_tilt0';
% pathname_pantilt = '/home/fran/WORK/calibration cam_ptu/panm4_tilt0';

% Read the images from davis (first, adjust the contrast)
selected= dir(fullfile(pathname_baseline, 'frame_*.pgm'));
numImages = numel(selected);
for k = 1:numImages
   filenames_base{k} = fullfile(pathname_baseline, selected(k).name); % Reading pgm
   images_base(:,:,k)=imread(filenames_base{k});
end

selected= dir(fullfile(pathname_pantilt, 'frame_*.pgm'));
numImages = numel(selected);
for k = 1:numImages
   filenames_pantilt{k} = fullfile(pathname_pantilt, selected(k).name); % Reading pgm
   images_pantilt(:,:,k)=imread(filenames_pantilt{k});
end

[imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_base, filenames_pantilt);
pairsUsed

% Generate world coordinates of the checkerboard points and compute camera
% parameters
squareSize = 30; %<----- should be 27 for the last case!!!!!

worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[stereoParams,pairsUsed,errors] = estimateCameraParameters(imagePoints, worldPoints);
pairsUsed

errors.RotationOfCamera2Error
errors.TranslationOfCamera2Error

% displayErrors(errors, stereoParams);

