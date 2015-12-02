% This script reads the extrinsic calibration parameters from 
% from PTU - camera calibration and does the minimization for extracting
% the final transformation between PTU_pan, PTU_tilt and the camera (R_pan,
% T_pan, R_titl, T_titl) that will be applied to the image

%11 different values
%-5 -4 -3 -2 -1 0 1 2 3 4 5
%We are doing from +5 to -5 pan and then, from +5 to -5 tilt (the baseline will be the first)
load('worksp_ptucam', 'rvecs_pan', 'rvecs_tilt', 'tvecs_pan', 'tvecs_tilt');

% pan_ptu_angles = [-0.087 -0.07 -0.052 -0.035 -0.017 0.017 0.035 0.052 0.07 0.087];%[-5 -4 -3 -2 -1 1 2 3 4 5]*pi/180;
% til_ptu_angles = [-0.087 -0.07 -0.052 -0.035 -0.017 0.017 0.035 0.052 0.07 0.087];%[-5 -4 -3 -2 -1 1 2 3 4 5]*pi/180;

% pan_ptu_angles =  [0.017 0.035 0.052 0.07 0.087 -0.017 -0.035 -0.052 -0.07 -0.087];%[1 2 3 4 5 -1 -2 -3 -4 -5]*pi/180;
% tilt_ptu_angles = [0.017 0.035 0.052 0.07 0.087 -0.017 -0.035 -0.052 -0.07 -0.087];%[1 2 3 4 5 -1 -2 -3 -4 -5]*pi/180;

pan_ptu_angles =  [-0.017 -0.035 -0.052 -0.07 -0.087 0.017 0.035 0.052 0.07 0.087];%[1 2 3 4 5 -1 -2 -3 -4 -5]*pi/180;
tilt_ptu_angles = [-0.017 -0.035 -0.052 -0.07 -0.087 0.017 0.035 0.052 0.07 0.087];%[1 2 3 4 5 -1 -2 -3 -4 -5]*pi/180;


% order for pan: we discard the 0_0 for this, because is the baseline
% 0_0, 1_0, 2_0, 3_0, 4_0, 5_0, m1_0, m2_0, m3_0, m4_0, m5_0
% order for tilt
% 0_1, 0_2, 0_3, 0_4, 0_5, 0_m1, 0_m2, 0_m3, 0_m4, 0_m5
% rvecs_pan= [-0.022 -0.998 0.053;...
%                 -0.014  -0.998  0.053;...
%                 -0.004  -0.999  0.053;...
%                 -0.046  -0.998  0.053;...
%                 -0.086  -0.995  0.054;...
%                  0.125 0.991 -0.049;...
%                  0.027 0.998 -0.052;...
%                  0.022 0.998 -0.053;...
%                  0.002 0.999 -0.053;...
%                  0.029 0.998 -0.053];
% 
% tvecs_pan= [-1.349 0.215 5.422;...
%                 -0.442  0.057  2.975;...
%                 -0.358  0.087  2.173;...
%                 -0.490  0.082  1.771;...
%                 -0.259  0.055  1.057;...
%                  0.321 -0.045 -0.953;...
%                  0.567 -0.099 -2.783;...
%                  0.956 -0.226 -5.010;...
%                  1.176 -0.239 -6.073;...
%                  1.287 -0.157 -7.203];
% 
% % For Tilt
% rvecs_tilt =[0.997 -0.078  0.014;...
%                  0.996 -0.090  0.015;...
%                  0.995 -0.102  0.015;...
%                  0.981 -0.193  0.009;...
%                  0.998 -0.058  0.018;... 
%                 -0.991  0.135 -0.017;...
%                 -0.987  0.160 -0.012;...
%                 -0.999 -0.035 -0.019;... 
%                 -0.999 -0.051 -0.018;...
%                 -0.996 -0.091 -0.020];
% 
% tvecs_tilt = [0.946 -1.258 -12.655;...
%                  0.667 -1.236 -10.310;...
%                  0.679 -0.739 -7.654;...
%                  0.379 -0.579 -5.296;...
%                  0.155 -0.331 -2.622;...
%                 -0.190  0.428  2.835;...
%                 -0.361  0.875  5.323;...
%                 -0.372  1.296  8.403;...
%                 -0.513  1.847  11.477;...
%                 -0.690  2.491  14.089];
             
% iNum = 361; jNum = 181;
iNum = 241; jNum = 361;
Xs = zeros(iNum,jNum); Ys = zeros(iNum,jNum); Zs = zeros(iNum,jNum);
res_pan = zeros(iNum,jNum);  res_tilt = zeros(iNum,jNum);
ve_pan  = zeros(iNum,jNum,3); ve_tilt = zeros(iNum,jNum,3);
te_pan = zeros(iNum,jNum,3);  te_tilt = zeros(iNum,jNum,3);

% Now, start the minimization 
for jj = 1:jNum
    nstr = fprintf( '.' );
%     phi = -pi/2 + pi/(jNum-1) * (j-1);
    phi = 0 + 2*pi/(jNum-1) * (jj-1);
    for ii = 1:iNum
        the = 0 + pi/(iNum-1) * (ii-1);
        te(1) = cos(phi)*sin(the);
        te(2) = sin(phi)*sin(the);
        te(3) = cos(the);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         options = optimset('TolFun', 1e-15, 'TolX', 1e-15, 'Display', 'off', 'Algorithm', 'interior-point', 'LargeScale', 'off', 'GradObj', 'on');
        options = optimset('TolFun', 1e-15, 'TolX', 1e-15, 'Display', 'off', 'Algorithm', 'interior-point', 'LargeScale', 'off');
        ve0 = [0,0,0];
%         [ve, res] = fmincon('calibrationfunH',ve0,[],[],[],[],[-500;-500;-500],[500;500;500], [], options, pan_ptu_angles, te, tvecs_pan);
        [ve, res] = fmincon('calibrationfunH2',ve0,[],[],[],[],[-500;-500;-500],[500;500;500], [], options, pan_ptu_angles, te, tvecs_pan);
        res_pan(ii,jj) = res; ve_pan(ii,jj,:) = ve; te_pan(ii,jj,:)=te;
        
%         [ve, res] = fmincon('calibrationfunH',ve0,[],[],[],[],[-500;-500;-500],[500;500;500], [], options, tilt_ptu_angles, te, tvecs_tilt);
        [ve, res] = fmincon('calibrationfunH2',ve0,[],[],[],[],[-500;-500;-500],[500;500;500], [], options, tilt_ptu_angles, te, tvecs_tilt);
        res_tilt(ii,jj) = res; ve_tilt(ii,jj,:) = ve; te_tilt(ii,jj,:)=te;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % for drawing
        Xs(ii,jj) = te(1);
        Ys(ii,jj) = te(2);
        Zs(ii,jj) = te(3);
    end
end

save tmp;
%%
% PAN
% Find minimum
[row, col, cost_pan]=find(res_pan == min(min(res_pan)));
if numel(row)>1
    row = row(1); col = col(1);
    cost_pan = cost_pan(1);
end
vpan_min=ve_pan(row, col,:);
tpan_min=te_pan(row, col,:);


figure, surf(Xs, Ys, Zs, log(res_pan+1e-16), 'LineStyle', 'none', 'EdgeLighting', 'phong', 'FaceLighting', 'phong', 'EdgeColor', 'interp', 'FaceColor', 'interp')
axis equal, xlabel('x'), ylabel('y'), zlabel('z'), title('Pan error')
hold on
plot3(tpan_min(1), tpan_min(2), tpan_min(3), 'rx', 'MarkerSize', 5, 'LineWidth', 5);
hold off


% TILT
% Find minimum
[row, col, cost_tilt]=find(res_tilt == min(min(res_tilt)));
if numel(row)>1
    row = row(1); col = col(1);
    cost_tilt = cost_tilt(1);
end
vtilt_min=ve_tilt(row, col,:);
ttilt_min=te_tilt(row, col,:);

figure, surf(Xs, Ys, Zs, log(res_tilt+1e-16), 'LineStyle', 'none', 'EdgeLighting', 'phong', 'FaceLighting', 'phong', 'EdgeColor', 'interp', 'FaceColor', 'interp')
axis equal, xlabel('x'), ylabel('y'), zlabel('z'), title('Tilt error')
hold on
plot3(ttilt_min(1), ttilt_min(2), ttilt_min(3), 'rx', 'MarkerSize', 5, 'LineWidth', 5);
hold off

% Here we have obtained the tpan_min and ttilt_min (r rotation axis), and
% the vpan_min, vtilt_min (v vector).

%%
% To obtain the rotation vector w (set the sign as the sign of the
% positive)
r_pan = tpan_min;
v_pan = vpan_min;
w_pan(3) = sign(median(rvecs_pan(1:5, 3)))*mean(abs(rvecs_pan(:,3)));
w_pan(2) = sign(median(rvecs_pan(1:5, 2)))*mean(abs(rvecs_pan(:,2)));
w_pan(1) = sign(median(rvecs_pan(1:5, 1)))*sqrt(1-w_pan(3)^2-w_pan(2)^2);

r_tilt = ttilt_min;
v_tilt = vtilt_min;
w_tilt(3) = sign(median(rvecs_tilt(1:5, 3)))*mean(abs(rvecs_tilt(:,3)));
w_tilt(1) = sign(median(rvecs_tilt(1:5, 1)))*mean(abs(rvecs_tilt(:,1)));
w_tilt(2) = sign(median(rvecs_tilt(1:5, 2)))*sqrt(1-w_tilt(3)^2-w_tilt(1)^2);

r_pan = squeeze(r_pan)';
r_tilt = squeeze(r_tilt)';
v_pan = squeeze(v_pan)';
v_tilt = squeeze(v_tilt)';

save worksp_ptu_calib;

% How to computer the Translation and Rotation parameters for the pan and
% tilt: angle_pan or angle_tilt is the angle measured by the PTU unit
% [T_pan, R_pan] = computeRotationTranslationFromPanTiltAngle(angle_pan, r_pan, v_pan, w_pan);
% [T_tilt, R_tilt] = computeRotationTranslationFromPanTiltAngle(angle_tilt, r_tilt, v_tilt, w_tilt);

