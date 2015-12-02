%add libraries for smoothing and inpainting the Kinect depth
addpath('./inpaintZ'); 
addpath('./inpaintZ/bmorph');

% First, read the depth file and format it to get Z
% pathfile = '/home/fran/WORK/calibration_data/my_output/worked_final';
pathfile = '/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/october';


files = dir(fullfile(pathfile, 'd-*.pgm'));

tmp = imread(fullfile(pathfile,files(1).name));
data = swapbytes(tmp);
[~, distance_old] = depthToCloud(data);

% Init inpaintZ to smooth Z values
distance_tmp = double(-distance_old);
distance_tmp(distance_tmp==0) = nan;

distance_new = my_inpaintZ(distance_tmp, 10^-3);



% Now, read the intensity image and see if we can do the registration
A_orig = imread('/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/davis_0001.pgm');
B_orig = imread('/home/fran/WORK/calibration cam_ptu/TOOLBOX_calib/calib_example/kinect_0001.pgm');

figure, imshowpair(B_orig, distance_new, 'falsecolor')
keyboard