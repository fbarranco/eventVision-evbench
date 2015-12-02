%name = 'seq2';

% pathname = '/home/fran/dvs_calib';
% 
% names = {'img1', 'img2', 'img3', 'img4', 'img5', ...
%     'img6', 'img7', 'img8', 'img9', 'img10', ...
%     'img11', 'img12', 'img13', 'img14', 'img15', ...
%     'img16', 'img17', 'img18', 'img19', 'img20', ...
%     'img21', 'img22'};

%pathname = '/home/fran/Desktop/mice_data';
pathname = '/home/fran/Desktop/davis_calib';

%names = {'first', 'second', 'third', 'fourth', 'fifth', 'sixth'};
%names = {'first', 'second', 'third', 'fourth'};
names = {'far', 'close'};

oldNumFrame_aps = 0;
oldNumFrame_dvs = 0;
interval = 5e6;
for ii=1:numel(names)
    
    numEvents=getNumofEvents(fullfile(pathname, strcat(names{ii}, '.aedat')));
    disp(numEvents)  
    % Get chunks of 10000000 events
    for kk=1:interval:numEvents-interval
        % get chunk of the file
        [allAddr,allTs] = loadaerdat_chunk(fullfile(pathname, strcat(names{ii}, '.aedat')), kk, kk+interval-1);
        
        [frames] = getAPSframesDavisGS_chunk(allAddr, allTs);
        [oldNumFrame_aps] = saveAllFrames(squeeze(frames(3,:,:,:)), pathname, names{ii}, oldNumFrame_aps);
        
        [x,y,pol,ts] = getDVSeventsDavis_chunk(allAddr, allTs);
        [oldNumFrame_dvs] = saveAllDVSFrames(x, y, ts, pol, pathname, names{ii}, oldNumFrame_dvs);
        disp(kk)
    end
    
    clear frames; clear allAddr; clear allTs;
    clear x; clear y; clear pol; clear ts;
end
