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
%   Copyright (C) 2015  Francisco Barranco, 13/10/2016, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.
%


% Redo the flow from the egomotion parameters and depth
addpath('./inpaintZ');
addpath('./inpaintZ/bmorph');

pathname_davis = ('./DATA/sequences/');
pathname_kinect = ('./DATA/sequences/');

%% First and last event in the DAVIS chunk for sequences: [seq_0001, seq_0002, seq_0003]
%% This data can also be found in file: initial_final_events_of_DVSstream.txt
seq_index=[1 2 3];
start_elem = [6132778, 9100390, 5536804];
end_elem = [8078366, 13002116, 7761106];


% Extract images and events from DAVIS data
% (uncompress sequences in folder)
selected= dir(fullfile(pathname_davis, '*.aedat')); 
if (numel(selected)==0)
    disp('Error: No .aedat files. Please, first uncompress the .7z sequences!')
    return
end
%%
frame_rate = [0 0 0];
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

	% And now, compute frame rates for the current sequence
    % Initialize exposure times vector
	time_frames=[];
    for ii=1:size(frames,4)-1 % compute time between consecutive readings
        time_frames(ii)= max(max(frames(4,:,:,ii+1)))-max(max(frames(4,:,:,ii)));
    end
    time_frames(end)=[];

    exposure_time(kk) = median(time_frames); % though it is global shutter, there are some small differences sometimes

    %The real frame rate for the recorded sequence is
    frame_rate(kk) = double(ts(end)-ts(1))./double(exposure_time(kk));
end

keyboard
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
   save(strcat(pathname_kinect, name, '_d.mat'), 'D');
end

%%
addpath('./calibration/');
load('./DATA/matfiles/worksp_ptu_calib', 'r_pan', 'r_tilt', 'v_pan', 'v_tilt','w_pan', 'w_tilt');
load('./DATA/matfiles/worksp_ptucam', 'stereoParams'); 
%load('./DATA/matfiles/worksp', 'stereoParams'); % This is from the stereo calibration in ./additional/exp3.m between Davis and Kinect
cameraParams = stereoParams.CameraParameters1; % Davis is camera 1

% For sequences seq_0001 to seq_0003
% The values for all the sequences are in file: pan_tilt_zoom_fromPTU.txt
angle_pan = [0., 0., -0.15]./frame_rate;
angle_tilt = [0.15, -0.13, -0.3]./frame_rate; 

% Now, compute the rotation and translation in the PTU calibration framework
for kk=1:numel(seq_index)
    [tpan_vec{kk}, Rot_pan{kk}] = computeRotationTranslationFromPanTiltAngle(angle_pan(kk), r_pan, v_pan, w_pan);
    [ttilt_vec{kk}, Rot_tilt{kk}] = computeRotationTranslationFromPanTiltAngle(angle_tilt(kk), r_tilt, v_tilt, w_tilt);

    % For the first sequence, there is only tilt
    rvec = rodrigues(Rot_pan{kk}*Rot_tilt{kk});
    tvec = tpan_vec{kk} + ttilt_vec{kk};
    
    load(sprintf('~/DATA/sequences/seq_%04d_d.mat', seq_index(kk)), 'D');
    
    SCENE_NUM = [240 180];

    SCENE_MAX = [239 179];
    SCENE_MIN = [0 0];
    [X, Y] = meshgrid(SCENE_MIN(1):1:SCENE_MAX(1), SCENE_MIN(2):1:SCENE_MAX(2));
    f = cameraParams.FocalLength;
    X = (X - cameraParams.PrincipalPoint(1))./f(1);
    Y = (Y - cameraParams.PrincipalPoint(2))./f(2);

    Z = abs(Depth);

    % Calculate optical flow field with the instantaneous motion model
    U_trans = ((-tvec(1) + tvec(3)*X)./(Z+eps))*f(1);
    U_rot = (rvec(1)* X.*Y    - rvec(2)*(1+X.^2) + rvec(3)*Y)*f(1);
    U = (-tvec(1) + tvec(3)*X)./(Z+eps) + rvec(1)* X.*Y    - rvec(2)*(1+X.^2) + rvec(3)*Y;
    V_trans = ((-tvec(2) + tvec(3)*Y)./(Z+eps))*f(2);
    V_rot = (rvec(1)*(1+Y.^2) - rvec(2)*X.*Y     - rvec(3)*X)*f(2);
    V = (-tvec(2) + tvec(3)*Y)./(Z+eps) + rvec(1)*(1+Y.^2) - rvec(2)*X.*Y     - rvec(3)*X;

    U = U*f(1); V = V*f(2);

    % Print the optical flow field
	addpath('./flow-code-matlab');
	flow(:,:,1)=U; flow(:,:,2)=-flipud(V);
	img = flowToColor(flow);
	figure, imagesc(img), title('Optical Flow Field') % Colors from Baker et al. 2011
	figure, imagesc(img(:,:,1)), title('X Flow Field') % Matlab colors
	figure, imagesc(img(:,:,2)), title('Y Flow Field') % Matlab colors

	disp('Vectors of rotation and translation)
	rvec
	tvec'
end