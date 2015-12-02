pathname = '/home/fran/Desktop/PTU';
names_pan = {'img_0_0', 'img_1_0', 'img_2_0', 'img_3_0', 'img_4_0', 'img_5_0'...
    'img_m1_0', 'img_m2_0', 'img_m3_0', 'img_m4_0', 'img_m5_0'}; % 11 elements

subpathnames_pan{1} = '/close/pan/central_center';
subpathnames_pan{2} = '/close/pan/central_down';
subpathnames_pan{3} = '/close/pan/central_up';
subpathnames_pan{4} = '/close/pan/left';
subpathnames_pan{5} = '/close/pan/right';
subpathnames_pan{6} = '/far/pan/central_center';
subpathnames_pan{7} = '/far/pan/central_down';
subpathnames_pan{8} = '/far/pan/central_up';
subpathnames_pan{9} = '/far/pan/left';
subpathnames_pan{10} = '/far/pan/right';
 
for kk =1:numel(subpathnames_pan)
    for ii=1:numel(names_pan)
        % get chunk of the file    
        [frames] = getAPSframesDavisGS(fullfile(pathname, subpathnames_pan{kk}, strcat(names_pan{ii}, '.aedat')));
        saveAllFrames(squeeze(frames(3,:,:,:)), fullfile(pathname, subpathnames_pan{kk}), names_pan{ii}, 1);
    end
end


pathname = '/home/fran/Desktop/PTU';

% % The baseline (0,0) is in names_pan
names_tilt = {'img_0_1', 'img_0_2', 'img_0_3', 'img_0_4', 'img_0_5'...
    'img_0_m1', 'img_0_m2', 'img_0_m3', 'img_0_m4', 'img_0_m5'};  %10 elements

subpathnames_tilt{1} = '/close/tilt/central_center';
subpathnames_tilt{2} = '/close/tilt/central_down';
subpathnames_tilt{3} = '/close/tilt/central_up';
subpathnames_tilt{4} = '/close/tilt/left';
subpathnames_tilt{5} = '/close/tilt/right';
subpathnames_tilt{6} = '/far/tilt/central_center';
subpathnames_tilt{7} = '/far/tilt/central_down';
subpathnames_tilt{8} = '/far/tilt/central_up';
subpathnames_tilt{9} = '/far/tilt/left';
subpathnames_tilt{10} = '/far/tilt/right';

for kk =1:numel(subpathnames_tilt)
    for ii=1:numel(names_tilt)
        % get chunk of the file    
        [frames] = getAPSframesDavisGS(fullfile(pathname, subpathnames_tilt{kk}, strcat(names_tilt{ii}, '.aedat')));
        saveAllFrames(squeeze(frames(3,:,:,:)), fullfile(pathname, subpathnames_tilt{kk}), names_tilt{ii}, 1);
    end
end