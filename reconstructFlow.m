% reconstructFlow
%             
% DESCRIPTION
%   The function reconstruct the optical flow field from the rotation and translation
%	parameters from the calibration between the PTU and the DAVIS, using the depth 
%	from kinect. This file tries to show the functionality of the different files 
%	and scripts in the repository. Some data is added to the repository in /sequences.
%	The whole dataset is available at:
%	http://atcproyectos.ugr.es/realtimeasoc/protected/evbench.html
%
%	The steps are documented in the website and the comments added to this file explain 
%	the different sections
%
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.
%


% Redo the flow from the egomotion parameters and depth
addpath('./inpaintZ');
addpath('./inpaintZ/bmorph');

pathname_davis = ('./sequences/');
pathname_kinect = ('./sequences/');

%% First and last event in the DAVIS chunk for sequences: [seq_0001, seq_0002, seq_0003]
%% This data can also be found in file: initial_final_events_of_DVSstream.txt
start_elem = [6132778, 9100390, 5536804];
end_elem = [8078366, 13002116, 7761106];


% Extract images and events from DAVIS data
selected= dir(fullfile(pathname_davis, '*.aedat'));
%%
for kk=1:numel(selected)

    % First, cut the excess
    [addr, ts]=loadaerdat(fullfile(pathname_davis, selected(kk).name), 20e6);
    addr(end_elem(kk):end)=[]; ts(end_elem(kk):end)=[];
    addr(1:start_elem(kk))=[]; ts(1:start_elem(kk))=[];
    
    
    [frames] = getAPSframesDavisGS_chunk(addr, ts);
    [x,y,pol,ts] = getDVSeventsDavis_chunk(addr, ts);
    
    data = squeeze(frames(3,:,:,:));

    [~,name,~] = fileparts(selected(kk).name);

    save(strcat(pathname_davis, name,'_e.mat'), 'x', 'y', 'pol', 'ts'); 
end

%%
load('./DATA/matfiles/worksp', 'stereoParams'); % This is from the stereo calibration in ./additional/exp3.m between Davis and Kinect

% Read the depth
for kk=1:numel(selected)
   [~,name,~]= fileparts(selected(kk).name);
   selected2= dir(fullfile(pathname_kinect, strcat('KINECT_', name), 'd-*.pgm'));
   D = [];
   for jj=1:numel(selected2)
   		depth=imread(fullfile(pathname_kinect, strcat('KINECT_', name), selected2(jj).name));

       depth_tmp=double(swapbytes(depth));
       [kkk,~]=depthToCloud(depth_tmp);
       realdepth_tmp = kkk(:,:,3);

       realdepth_tmp(realdepth_tmp==0)=nan;   
       realdepth_tmp = my_inpaintZ(realdepth_tmp, 10^-3);
       newDepth = -imresize(realdepth_tmp,[180 240]);
       
       % Registering Kinect depth to DAVIS frame of reference
       D(:,:,jj) =registerDepth(newDepth, stereoParams);
   end
   save(strcat(pathname_kinect, '_d.mat'), 'D');
end

%%
load('./DATA/matfiles/worksp_ptu_calib', 'r_pan', 'r_tilt', 'v_pan', 'v_tilt','w_pan', 'w_tilt');
load('./DATA/matfiles/worksp', 'stereoParams'); % This is from the stereo calibration in ./additional/exp3.m between Davis and Kinect
cameraParams = stereoParams.CameraParameters1; % Davis is camera 1

% Angles (and speeds) for [seq_0001, seq_0002, seq_0003]
% More GT are available in file: ground-truth_3Dcam.txt
% These values were taking from the PTU while capturing data
%angle_pan = [0, 0, -0.15]/20; speed_pan = [0, 0, 0.15]/20;
%angle_tilt = [0.15, -0.3, -0.3]/40; speed_tilt = [0.15, 0.15, 0.3]/20;

angle_pan = [0, 0, -0.15]/20; speed_pan = [0, 0, 0.15]/20;
angle_tilt = [0.15, -0.3, -0.3]/40; speed_tilt = [0.15, 0.15, 0.3]/20;

%angle_pan = [0, 0, -0.15]/20; speed_pan = [0, 0, 0.15]/20;
%angle_tilt = [0.15, -0.3, -0.3]/40; speed_tilt = [0.15, 0.15, 0.3]/20;


% Now, compute the rotation and translation in the PTU calibration framework
for kk=1:numel(selected)
    [tpan_vec{kk}, Rot_pan{kk}] = computeRotationTranslationFromPanTiltAngle(angle_pan(kk), r_pan, v_pan, w_pan);
    [ttilt_vec{kk}, Rot_tilt{kk}] = computeRotationTranslationFromPanTiltAngle(angle_tilt(kk), r_tilt, v_tilt, w_tilt);
    
    rpan_vec{kk} = rodrigues(Rot_pan{kk});
    rtilt_vec{kk} = rodrigues(Rot_tilt{kk});
end

% Change this name and nseq according to the sequence that is being used
name = 'seq_0002'; nseq =2; 

% For the first sequence, there is only tilt
rvec = rtilt_vec{nseq}; 
tvec = ttilt_vec{nseq};
save(strcat(pathname_kinect, name,'_d.mat'), 'D');

Depth = D(:,:,nseq);
SCENE_NUM = [240 180]; % DAVIS spatial resolution
SCENE_MAX = [120 90];
SCENE_MIN = [-120 -90];

[X, Y] = meshgrid(SCENE_MIN(1)+0.5:1:SCENE_MAX(1), SCENE_MIN(2)+0.5:1:SCENE_MAX(2));
Y = flipud(Y);

f = cameraParams.FocalLength;
Z = abs(Depth);

% Calculate optical flow field with the instantaneous motion model
tx = tvec(1)*abs(tvec(3))/f(1); ty = tvec(2)*abs(tvec(3))/f(1); tz = tvec(3)*abs(tvec(3))/f(1);
rx = rvec(1); ry = rvec(2); rz = rvec(3);
U = (-tx*f(1) + tz.*X)./(Z+eps) + 1/f(1) .* (X.*Y.*rx - (f(1)^2+X.^2).*ry + f(1)*Y.*rz);
V = -((-ty*f(2) + tz.*Y)./(Z+eps) + 1/f(2) .* ((f(2)^2+Y.^2).*rx - X.*Y.*ry - f(2)*X.*rz));

% Print the optical flow field
addpath('./flow-code-matlab');
flow(:,:,1)=U; flow(:,:,2)=V;
img = flowToColor(flow);
figure, imagesc(img(:,:,1)), title('X Flow Field')
figure, imagesc(img(:,:,2)), title('Y Flow Field')
