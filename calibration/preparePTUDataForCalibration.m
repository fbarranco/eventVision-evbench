% preparePTUDataForCalibration
%             
% DESCRIPTION
%   The script extracts the calibration parameters for all the pan-tilt combinations
%   with respect to the baseline. It saves all the information in worksp_ptucam
%
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.


% % Script: Prepares data for calibration ptu
% 
% % First, read the vectors and rotation matrices from calibration
%pathname = '/home/fran/Desktop/PTU';
pathname = './DATA/PTU';
names_pan = {'img_0_0', 'img_1_0', 'img_2_0', 'img_3_0', 'img_4_0', 'img_5_0'...
    'img_m1_0', 'img_m2_0', 'img_m3_0', 'img_m4_0', 'img_m5_0'}; % 11 elements

% The baseline (0,0) is in names_pan
names_tilt = {'img_0_1', 'img_0_2', 'img_0_3', 'img_0_4', 'img_0_5'...
    'img_0_m1', 'img_0_m2', 'img_0_m3', 'img_0_m4', 'img_0_m5'};  %10 elements

% %First pan angles:
% % Now, first extract all the images
% % subpathnames_pan{1} = '/close/pan/central_center/davis';
% % subpathnames_pan{2} = '/close/pan/central_down/davis';
% % subpathnames_pan{3} = '/close/pan/central_up/davis';
% % subpathnames_pan{4} = '/close/pan/left/davis';
% % subpathnames_pan{5} = '/close/pan/right/davis';
% % subpathnames_pan{6} = '/far/pan/central_center/davis';
% % subpathnames_pan{7} = '/far/pan/central_down/davis';
% % subpathnames_pan{8} = '/far/pan/central_up/davis';
% % subpathnames_pan{9} = '/far/pan/left/davis';
% % subpathnames_pan{10} = '/far/pan/right/davis';
% 
% subpathnames_pan{1} = '/close/pan/central_center';
% subpathnames_pan{2} = '/close/pan/central_down';
% subpathnames_pan{3} = '/close/pan/central_up';
% subpathnames_pan{4} = '/close/pan/left';
% subpathnames_pan{5} = '/close/pan/right';
% subpathnames_pan{6} = '/far/pan/central_center';
% subpathnames_pan{7} = '/far/pan/central_down';
% subpathnames_pan{8} = '/far/pan/central_up';
% subpathnames_pan{9} = '/far/pan/left';
% subpathnames_pan{10} = '/far/pan/right';
% 
% newpathname = fullfile(pathname, '/output/pan');
% if ~exist(newpathname, 'dir')
%     mkdir(newpathname);
% end
% 
% numFrame = 1;
% for kk=1:numel(subpathnames_pan)
%     for mm = 1:numel(names_pan)
%         % get chunk of the file    
%         [frames] = getAPSframesDavisGS(fullfile(pathname, subpathnames_pan{kk}, strcat(names_pan{mm}, '.aedat')));
%         %saveAllFrames(squeeze(frames(3,:,:,:)), pathname, names{ii}, 1);
%         data = squeeze(frames(3,:,:,:));
%         
%         %save only one of the files, for example, number end-3 (at least 3
%         %files per DVS chunk)
%         tmp = mat2gray(flipud(data(:,:,5)'));
%         imwrite(tmp, fullfile(newpathname, strcat('frame', sprintf('_%05d', numFrame),'.pgm')));
%         
%         numFrame = numFrame+1;        
%     end
% end
% numFramesPan = numFrame;
% 
% %Now tilt angles:
% % subpathnames_tilt{1} = '/close/tilt/central_center/davis';
% % subpathnames_tilt{2} = '/close/tilt/central_down/davis';
% % subpathnames_tilt{3} = '/close/tilt/central_up/davis';
% % subpathnames_tilt{4} = '/close/tilt/left/davis';
% % subpathnames_tilt{5} = '/close/tilt/right/davis';
% % subpathnames_tilt{6} = '/far/tilt/central_center/davis';
% % subpathnames_tilt{7} = '/far/tilt/central_down/davis';
% % subpathnames_tilt{8} = '/far/tilt/central_up/davis';
% % subpathnames_tilt{9} = '/far/tilt/left/davis';
% % subpathnames_tilt{10} = '/far/tilt/right/davis';
% 
% subpathnames_tilt{1} = '/close/tilt/central_center';
% subpathnames_tilt{2} = '/close/tilt/central_down';
% subpathnames_tilt{3} = '/close/tilt/central_up';
% subpathnames_tilt{4} = '/close/tilt/left';
% subpathnames_tilt{5} = '/close/tilt/right';
% subpathnames_tilt{6} = '/far/tilt/central_center';
% subpathnames_tilt{7} = '/far/tilt/central_down';
% subpathnames_tilt{8} = '/far/tilt/central_up';
% subpathnames_tilt{9} = '/far/tilt/left';
% subpathnames_tilt{10} = '/far/tilt/right';
% 
% newpathname = fullfile(pathname, '/output/tilt');
% if ~exist(newpathname, 'dir')
%     mkdir(newpathname);
% end
% 
% numFrame = numFramesPan;
% for kk=1:numel(subpathnames_tilt)
%     for mm = 1:numel(names_tilt)
%         % get chunk of the file    
%         [frames] = getAPSframesDavisGS(fullfile(pathname, subpathnames_tilt{kk}, strcat(names_tilt{mm}, '.aedat')));
%         %saveAllFrames(squeeze(frames(3,:,:,:)), pathname, names{ii}, 1);
%         data = squeeze(frames(3,:,:,:));
%         
%         %save only one of the files, for example, number end-3 (at least 3
%         %files per DVS chunk)
%         tmp = mat2gray(flipud(data(:,:,5)'));
%         imwrite(tmp, fullfile(newpathname, strcat('frame', sprintf('_%05d', numFrame),'.pgm')));
%         
%         numFrame = numFrame+1;
%     end
% end

%% 
% The stereo calibration for each pan-tilt combination w.r.t the baseline
% 0,0 gives us the R and T of each one of them w.r.t the baseline
newpathname = fullfile(pathname, '/output/pan');
selected_files= dir(fullfile(newpathname, 'frame_*.pgm'));

numImagesPerPanTiltCombination = 11;
numImagesTotal = numel(selected_files); %110

%Baseline is the first one 
idx = 1:numImagesPerPanTiltCombination:numImagesTotal;
% Read the images from davis (first, adjust the contrast)
for kk = 1:numel(idx)
   filenames_baseline{kk} = fullfile(newpathname, sprintf('frame_%05d.pgm', idx(kk)));
end

%for initialFrame=1:numImagesPerPanTiltCombination
%The order is: 1_0, 2_0, 3_0, 4_0, 5_0, m1_0, m2_0, m3_0, m4_0, m5_0
for initialFrame=2:numImagesPerPanTiltCombination % Discard 0_0
    idx = initialFrame:numImagesPerPanTiltCombination:numImagesTotal;
    
    for ii=1:numel(idx)
       filenames_pantilt{ii} = fullfile(newpathname, sprintf('frame_%05d.pgm', idx(ii)));
    end

    [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_baseline, filenames_pantilt);
    pairsUsed

    % Generate world coordinates of the checkerboard points and compute camera
    % parameters
    squareSize = 27; %<----- should be 27 for the last case!!!!!

    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    [stereoParams,pairsUsed,errors] = estimateCameraParameters(imagePoints, worldPoints);
    pairsUsed

    rvecs_pan(initialFrame-1,:)=rodrigues(stereoParams.RotationOfCamera2)'./norm(rodrigues(stereoParams.RotationOfCamera2)');
    tvecs_pan(initialFrame-1,:)=stereoParams.TranslationOfCamera2;
    rangle_pan(initialFrame-1) = norm(rodrigues(stereoParams.RotationOfCamera2)');
    rerror_pan(initialFrame-1,:) = errors.RotationOfCamera2Error;
    terror_pan(initialFrame-1,:) = errors.TranslationOfCamera2Error;
end


%% 
% The stereo calibration for each pan-tilt combination w.r.t the baseline
% 0,0 gives us the R and T of each one of them w.r.t the baseline
newpathname = fullfile(pathname, '/output/tilt');
selected_files= dir(fullfile(newpathname, 'frame_*.pgm'));

% The baseline is the same than for pan

numImagesPerPanTiltCombination = 10;
startImage = numImagesTotal;
numImagesTotal = startImage+numel(selected_files); %100

%for initialFrame=1:numImagesPerPanTiltCombination
%The order is: 1_0, 2_0, 3_0, 4_0, 5_0, m1_0, m2_0, m3_0, m4_0, m5_0
for initialFrame=1:numImagesPerPanTiltCombination % Discard 0_0
    idx = initialFrame+startImage:numImagesPerPanTiltCombination:numImagesTotal;
    
    for ii=1:numel(idx)
       filenames_pantilt{ii} = fullfile(newpathname, sprintf('frame_%05d.pgm', idx(ii)));
    end

    [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames_baseline, filenames_pantilt);
    pairsUsed

    % Generate world coordinates of the checkerboard points and compute camera
    % parameters
    squareSize = 27; %<----- should be 27 for the last case!!!!!

    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    [stereoParams,pairsUsed,errors] = estimateCameraParameters(imagePoints, worldPoints);
    pairsUsed

    rvecs_tilt(initialFrame,:)=rodrigues(stereoParams.RotationOfCamera2)'./norm(rodrigues(stereoParams.RotationOfCamera2)');
    tvecs_tilt(initialFrame,:)=stereoParams.TranslationOfCamera2;
    rangle_tilt(initialFrame) = norm(rodrigues(stereoParams.RotationOfCamera2)');
    rerror_tilt(initialFrame,:) = errors.RotationOfCamera2Error;
    terror_tilt(initialFrame,:) = errors.TranslationOfCamera2Error;
end

% % % %%
% % % % % Compute the calibration for the baseline (0,0)
% % % % pathname = fullfile(pathname, '/output/pan');
% % % % numImagesPerPanTiltCombination = 11;
% % % % 
% % % % idx = 1:numImagesPerPanTiltCombination:110;
% % % % % Read the images from davis (first, adjust the contrast)
% % % % for kk = 1:numel(idx)
% % % %    filenames{kk} = fullfile(pathname, sprintf('frame_%05d.pgm', idx(kk))); % Reading pgm
% % % % %   images(:,:,kk)=imread(filenames{kk});
% % % % end
% % % % 
% % % % [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(filenames);
% % % % pairsUsed
% % % % 
% % % % % Generate world coordinates of the checkerboard points and compute camera
% % % % % parameters
% % % % squareSize = 27; %<----- should be 27 for the last case!!!!!
% % % % 
% % % % worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% % % % cameraParams = estimateCameraParameters(imagePoints, worldPoints);
% % % % 
% % % %%
% % % % % Extract the Translation and rotation vectors for pan
% % % % pathname = fullfile(pathname, '/output/pan');
% % % % 
% % % % % Read the images 
% % % % selected_files= dir(fullfile(pathname, 'frame_*.pgm'));
% % % % numImages = numel(selected_files);
% % % % for kk = 1:numImages
% % % %     filenames{kk} = fullfile(pathname, selected_files(kk).name); % Reading pgm   
% % % %     images(:,:,kk)=imread(filenames{kk});
% % % %     
% % % %     undist_images_pan(:,:,kk) = undistortImage(images(:,:,kk), cameraParams);
% % % %     [imagePoints, ~] = detectCheckerboardPoints(undist_images_pan(:,:,kk));    
% % % %     [rotationMatrix, translationVector] = extrinsics(imagePoints, cameraParams.WorldPoints, cameraParams);
% % % %     
% % % %     vectorOfRotationVectors_pan(kk,:)=(rodrigues(rotationMatrix))';
% % % %     vectorOfTranslationVectors_pan(kk,:) = translationVector;
% % % % end
% % % % 
% % % % 
% % % % % Now, get the average values and std
% % % % numImagesPerPanTiltCombination = 11;
% % % % 
% % % % %for initialFrame=1:numImagesPerPanTiltCombination
% % % % %The order is: 1_0, 2_0, 3_0, 4_0, 5_0, m1_0, m2_0, m3_0, m4_0, m5_0
% % % % for initialFrame=2:numImagesPerPanTiltCombination % Discard 0_0
% % % %     idx = initialFrame:numImagesPerPanTiltCombination:numImages;
% % % %     
% % % %     for ii=1:numel(idx)
% % % %        rvec_pan_tmp(ii,:) = vectorOfRotationVectors_pan(idx(ii),:);
% % % %        tvec_pan_tmp(ii,:) = vectorOfTranslationVectors_pan(idx(ii),:);
% % % %     end
% % % % 
% % % %     rvecpan_mean(initialFrame-1,:) = mean(rvec_pan_tmp);
% % % %     rvecpan_std(initialFrame-1,:) = std(rvec_pan_tmp);
% % % % 
% % % %     tvecpan_mean(initialFrame-1,:) = mean(tvec_pan_tmp);
% % % %     tvecpan_std(initialFrame-1,:) = std(tvec_pan_tmp);
% % % % end
% % % % rvecs_pan = rvecpan_mean;
% % % % tvecs_pan = tvecpan_mean;
% % % 
% % % %%
% % % % % Extract the Translation and rotation vectors for tilt
% % % % pathname = fullfile(pathname, '/output/tilt');
% % % % 
% % % % % Read the images 
% % % % selected_files= dir(fullfile(pathname, 'frame_*.pgm'));
% % % % numImages = numel(selected_files);
% % % % for kk = 1:numImages
% % % %     filenames{kk} = fullfile(pathname, selected_files(kk).name); % Reading pgm   imwrite(imresize(I, [480 640], 'bicubic'), strcat(sprintf('davis_%04d', k),'.pgm'));
% % % %     images(:,:,kk)=imread(filenames{kk});
% % % %     
% % % %     undist_images_tilt(:,:,kk) = undistortImage(images(:,:,kk), cameraParams);
% % % %     [imagePoints, ~] = detectCheckerboardPoints(undist_images_tilt(:,:,kk));    
% % % %     [rotationMatrix, translationVector] = extrinsics(imagePoints, cameraParams.WorldPoints, cameraParams);
% % % %     
% % % %     vectorOfRotationVectors_tilt(kk,:)=(rodrigues(rotationMatrix))';
% % % %     vectorOfTranslationVectors_tilt(kk,:) = translationVector;
% % % % end
% % % % 
% % % % 
% % % % % Now, get the average values and std
% % % % %numImagesPerPanTiltCombination = 11;
% % % % numImagesPerPanTiltCombination = 10; % there is no tilt for 0_0 because is the same than for pan
% % % % 
% % % % % The order is: 0_1, 0_2, 0_3, 0_4, 0_5, 0_m1, 0_m2, 0_m3, 0_m4, 0_m5
% % % % for initialFrame=1:n\umImagesPerPanTiltCombination
% % % %     idx = initialFrame:numImagesPerPanTiltCombination:numImages;
% % % %     
% % % %     for ii=1:numel(idx)
% % % %        rvec_tilt_tmp(ii,:) = vectorOfRotationVectors_tilt(idx(ii),:);
% % % %        tvec_tilt_tmp(ii,:) = vectorOfTranslationVectors_tilt(idx(ii),:);
% % % %     end
% % % % 
% % % %     rvectilt_mean(initialFrame-1,:) = mean(rvec_tilt_tmp);
% % % %     rvectilt_std(initialFrame-1,:) = std(rvec_tilt_tmp);
% % % % 
% % % %     tvectilt_mean(initialFrame-1,:) = mean(tvec_tilt_tmp);
% % % %     tvectilt_std(initialFrame-1,:) = std(tvec_tilt_tmp);
% % % % end
% % % % 
% % % % rvecs_tilt = rvectilt_mean;
% % % % tvecs_tilt = tvectilt_mean;

%%
save './DATA/matfiles/worksp_ptucam';