% Script for stereo calibration kinect - davis

% Compute images from img data
pathname = '/media/fran/Seagate Backup Plus Drive/last/calib';
names = {'img01', 'img02', 'img03', 'img04', 'img05', ...
    'img06', 'img07', 'img08', 'img09', 'img10', ...
    'img11', 'img12', 'img13', 'img14', 'img15', ...
    'img16', 'img17', 'img18', 'img19', 'img20',...
    'img21', 'img22', 'img23', 'img24', 'img25',...
    'img26', 'img27', 'img28', 'img29', 'img30', ...
    'img31', 'img32', 'img33', 'img34', 'img35'};

numFrame = 1;
for ii=1:numel(names)
    % get chunk of the file    
    [frames] = getAPSframesDavisGS(fullfile(pathname, strcat(names{ii}, '.aedat')));
    data = squeeze(frames(3,:,:,:));
        
    %save only one of the files, for example, number end-3 (at least 3
    %files per DVS chunk)
    tmp = mat2gray(flipud(data(:,:,end-3)'));
    imwrite(tmp, fullfile(pathname, strcat('davis', sprintf('_%04d', numFrame),'.pgm')));
    numFrame=numFrame+1;
end

%%

% Computing frames for Kinect
pathname = '/media/fran/Seagate Backup Plus Drive/last/my_output';
selected= dir(fullfile(pathname, '*.ppm'));
for k = 1:numel(selected)
   I = imread(fullfile(pathname, selected(k).name)); % Reading ppm
   imwrite(imresize(rgb2gray(I), [180 240], 'bicubic'), fullfile(pathname, strcat(sprintf('kinect_%04d', k),'.pgm')));
end