% % Script: Prepares data for calibration ptu
pathname = '../PTU';
names_pan = {'img_0_0', 'img_1_0', 'img_2_0', 'img_3_0', 'img_4_0', 'img_5_0'...
    'img_m1_0', 'img_m2_0', 'img_m3_0', 'img_m4_0', 'img_m5_0'}; % 11 elements

% The baseline (0,0) is in names_pan
names_tilt = {'img_0_1', 'img_0_2', 'img_0_3', 'img_0_4', 'img_0_5'...
    'img_0_m1', 'img_0_m2', 'img_0_m3', 'img_0_m4', 'img_0_m5'};  %10 elements

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
numImages_baseline =0;
for kk = 1:numel(idx)
   filenames_baseline{kk} = fullfile(newpathname, sprintf('frame_%05d.pgm', idx(kk)));
   allImages(:,:,1,kk) = imread(filenames_baseline{kk});
   numImages_baseline = numImages_baseline+1;
end

   
%for initialFrame=1:numImagesPerPanTiltCombination
%The order is: 1_0, 2_0, 3_0, 4_0, 5_0, m1_0, m2_0, m3_0, m4_0, m5_0
for initialFrame=2:numImagesPerPanTiltCombination % Discard 0_0
    idx = initialFrame:numImagesPerPanTiltCombination:numImagesTotal;
    
    for ii=1:numel(idx)
       filenames_pantilt{ii} = fullfile(newpathname, sprintf('frame_%05d.pgm', idx(ii)));
       allImages(:,:,1,numImages_baseline + kk) = imread(filenames_pantilt{ii});
    end
    
    % First, undistort the images and use the undistorted ones
    [imagePoints, boardSize] = detectCheckerboardPoints(allImages);
    squareSize = 27;
    worldPoints = generateCheckerboardPoints(boardSize,squareSize);
    cameraParams = estimateCameraParameters(imagePoints,worldPoints);
    
    % Now, read and undistort all of them
    for kk = 1:numImages_baseline
        images_baseline_undist(:,:,1,kk) = undistortImage(imread(filenames_baseline{kk}),cameraParams);
    end
    for kk = 1:numel(idx)
        images_pantilt_undist(:,:,1,kk) = undistortImage(imread(filenames_pantilt{kk}),cameraParams);
    end
    
    [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(images_baseline_undist, images_pantilt_undist);
    pairsUsed

    % Generate world coordinates of the checkerboard points and compute camera
    % parameters
    squareSize = 27; %<----- should be 27 for the last case!!!!!

    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    [stereoParams,pairsUsed,errors] = estimateCameraParameters(imagePoints, worldPoints);
    pairsUsed

    rvecs_pan(initialFrame-1,:)=rodrigues(stereoParams.RotationOfCamera2)'./norm(rodrigues(stereoParams.RotationOfCamera2)');
%     tvecs_pan(initialFrame-1,:)=stereoParams.TranslationOfCamera2/1000; % world units are in mm
    tvecs_pan(initialFrame-1,:)=stereoParams.TranslationOfCamera2/1000; %in m
    rangle_pan(initialFrame-1) = norm(rodrigues(stereoParams.RotationOfCamera2)');
    rerror_pan(initialFrame-1,:) = errors.RotationOfCamera2Error;
%     terror_pan(initialFrame-1,:) = errors.TranslationOfCamera2Error; % world units are in mm
    terror_pan(initialFrame-1,:) = errors.TranslationOfCamera2Error/1000;%in m
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

clear filenames_pantilt images_pantilt images_pantilt_undist; 

%for initialFrame=1:numImagesPerPanTiltCombination
%The order is: 1_0, 2_0, 3_0, 4_0, 5_0, m1_0, m2_0, m3_0, m4_0, m5_0
for initialFrame=1:numImagesPerPanTiltCombination % Discard 0_0
    idx = initialFrame+startImage:numImagesPerPanTiltCombination:numImagesTotal;
    
    for ii=1:numel(idx)
       filenames_pantilt{ii} = fullfile(newpathname, sprintf('frame_%05d.pgm', idx(ii)));
       allimages(:,:,1,numImages_baseline + kk) = imread(filenames_pantilt{ii});
    end
    
    % First, undistort the images and use the undistorted ones
    [imagePoints, boardSize] = detectCheckerboardPoints(allImages);
    squareSize = 27;
    worldPoints = generateCheckerboardPoints(boardSize,squareSize);
    cameraParams = estimateCameraParameters(imagePoints,worldPoints);
    
    % Now, read and undistort all of them
    for kk = 1:numImages_baseline
        images_baseline_undist(:,:,1,kk) = undistortImage(imread(filenames_baseline{kk}),cameraParams);
    end
    for kk = 1:numel(idx)
        images_pantilt_undist(:,:,1,kk) = undistortImage(imread(filenames_pantilt{kk}),cameraParams);
    end
    
    [imagePoints, boardSize,pairsUsed] = detectCheckerboardPoints(images_baseline_undist, images_pantilt_undist);
    pairsUsed
    
    % Generate world coordinates of the checkerboard points and compute camera
    % parameters
    squareSize = 27; %<----- should be 27 for the last case!!!!!
    
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    [stereoParams,pairsUsed,errors] = estimateCameraParameters(imagePoints, worldPoints);
    pairsUsed
    
    rvecs_tilt(initialFrame,:)=rodrigues(stereoParams.RotationOfCamera2)'./norm(rodrigues(stereoParams.RotationOfCamera2)');
%     tvecs_tilt(initialFrame,:)=stereoParams.TranslationOfCamera2; % world units are in mm
    tvecs_tilt(initialFrame,:)=stereoParams.TranslationOfCamera2/1000; % in meters
    rangle_tilt(initialFrame) = norm(rodrigues(stereoParams.RotationOfCamera2)');
    rerror_tilt(initialFrame,:) = errors.RotationOfCamera2Error;
%     terror_tilt(initialFrame,:) = errors.TranslationOfCamera2Error; % world units are in mm
    terror_tilt(initialFrame,:) = errors.TranslationOfCamera2Error/1000; %in meters
end

%%
save worksp_ptucam;