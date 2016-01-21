% reconstructFlow
%   frames    		- Structure with gray data from the output of getAPSframesDavisGS.
%   pathname    	- Folder to store the frames.
%   name   			- Name of the png files.
%   initNumFrame    - The number of the first png file to be stored.
%
% RETURN
%   totalNumFrames  - The number of the last png file to be stored. 
%             
% DESCRIPTION
%   The function save all the frames in a chunk of data from DAVIS sensor. 
% 	This saves the gray data in a folder in $pathname/$name_%05.png where the first
%	frame starts with the number $initNumFrame. All the frames are in the structure
% 	$frames, read with getAPSframesDavisGS (the output has six components, the 3rd 
%	is this gray data for $frames)
%
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.
%


% Redo the flow from the egomotion parameters and depth
addpath('~/Desktop/sequences/inpaintZ');
addpath('~/Desktop/sequences/inpaintZ/bmorph');

pathname_davis = ('~/Desktop/sequences/DAVIS/');
pathname_kinect = ('~/Desktop/sequences/kinect/');

%%
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

    saveAllFrames(data, pathname_davis, name, 1);
    save(strcat(fullfile(pathname_davis, name),'_e.mat'), 'x', 'y', 'pol', 'ts'); 
end

%%
load('worksp', 'stereoParams'); % This is from the stereo calibration in ~/WORK/DAVIS/exp3.m between Davis and Kinect

% Read the depth
for kk=1:numel(selected)
   [~,name,~]= fileparts(selected(kk).name);
   selected2= dir(fullfile(pathname_kinect, name, 'd-*.pgm')); 
   D = [];
   for jj=1:numel(selected2)
       depth=imread(fullfile(pathname_kinect, name, selected2(jj).name));

       depth_tmp=double(swapbytes(depth));
       [kkk,~]=depthToCloud(depth_tmp);
       realdepth_tmp = kkk(:,:,3);
       keyboard

       realdepth_tmp(realdepth_tmp==0)=nan;   
       realdepth_tmp = my_inpaintZ(realdepth_tmp, 10^-3);
       newDepth = -imresize(realdepth_tmp,[180 240]);
       
       % Registering Kinect depth to DAVIS frame of reference
       D(:,:,jj) =registerDepth(newDepth, stereoParams);
   end
   save(strcat(fullfile(pathname_kinect, name),'_d.mat'), 'D');
end

%%
load('worksp_ptu_calib', 'r_pan', 'r_tilt', 'v_pan', 'v_tilt','w_pan', 'w_tilt');

load('worksp', 'stereoParams'); % This is from the stereo calibration in ~/WORK/DAVIS/exp3.m between Davis and Kinect
cameraParams = stereoParams.CameraParameters1; % Davis is camera 1

angle_pan = [0, 0, -0.15]/20; speed_pan = [0, 0, 0.15]/20;
angle_tilt = [0.15, -0.3, -0.3]/40; speed_tilt = [0.15, 0.15, 0.3]/20;

for kk=1:numel(selected)
    [tpan_vec{kk}, Rot_pan{kk}] = computeRotationTranslationFromPanTiltAngle(angle_pan(kk), r_pan, v_pan, w_pan);
    [ttilt_vec{kk}, Rot_tilt{kk}] = computeRotationTranslationFromPanTiltAngle(angle_tilt(kk), r_tilt, v_tilt, w_tilt);
    
    rpan_vec{kk} = rodrigues(Rot_pan{kk});
    rtilt_vec{kk} = rodrigues(Rot_tilt{kk});
end

nseq =2;
% For the first sequence, there is only tilt
rvec = rtilt_vec{nseq}; 
tvec = ttilt_vec{nseq};
load('~/Desktop/sequences/kinect/seq_0002_d.mat', 'D');
Depth = D(:,:,nseq);
SCENE_NUM = [240 180];
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



% % angErr = (Tgt'*Test) /(norm(Tgt) * norm(Test));
% % angErr(angErr>1) =1;
% % angErr(angErr<-1)=-1;
% % angErr = acos(angErr) * 180/pi;
% % % Calculate deflection between ground-truth and estimate.
% % disp(sprintf('translation: angular error = %2.2f deg',angErr));
% % disp(['rotation: |Rgt - Rest| = ',num2str(abs(Rgt'-Rest')*180/pi),' deg/frame']);