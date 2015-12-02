% This function do the calibration between a camera and the PTU
%1. Compute the intrinsic parameters for the camera
%2. The baseline is 0º pan, 0º tilt
%3. Compute extrinsic parameter for each pan/titl combination w.r.t the baseline. 
%This is the translation and rotation of the camera w.r.t the baseline

% The intrinsic parameters are read from the data that we get from our
% manual calibration with rpg_dvs_calibration packages (intrinsic and
% extrinsic)

% For intrinsic parameters (read them from a file?)
% k1 = ; k2 = ; k3 = ;            % radial distorsion coeffs
% p1= ; p2= ;                     % tangencial distorsion coeffs
% D = [k1 k2 p1 p2 k3];           % distorsion coeffs
% cx = ; cy = ;                   % image center 
% fx = ; fy = ;                   % focal lengths
% K = [fx 0 cx; 0 fy cy; 0 0 1];  % camera matrix

% For extrinsic parameters (read them from a file?)
%% For Pan
rvecs_pan = [-0.022 -0.998 0.053;...
                -0.014 -0.998  0.053;...
                -0.004 -0.999  0.053;...
                -0.046 -0.998  0.053;...
                -0.086 -0.995  0.054;...
                 0.125  0.991 -0.049;...
                 0.027  0.998 -0.052;...
                 0.022  0.998 -0.053;...
                 0.002  0.999 -0.053;...
                 0.029  0.998 -0.053];
pan = [-5 -4 -3 -2 -1 1 2 3 4 5]*pi/180;
% rot_pan = [5.07 4.32 3.32 2.12 1.03 1.18 2.05 2.95 4.02 5.12]*pi/180;
rot_pan = [-5.07 -4.32 -3.32 -2.12 -1.03 1.18 2.05 2.95 4.02 5.12]*pi/180;
tvecs_pan= [-1.349 0.215 5.422;...
                -0.442  0.057  2.975;...
                -0.358  0.087  2.173;...
                -0.490  0.082  1.771;...
                -0.259  0.055  1.057;...
                 0.321 -0.045 -0.953;...
                 0.567 -0.099 -2.783;...
                 0.956 -0.226 -5.010;...
                 1.176 -0.239 -6.073;...
                 1.287 -0.157 -7.203];

% For Tilt
rvecs_tilt =[0.997 -0.078  0.014;...
                 0.996 -0.090  0.015;...
                 0.995 -0.102  0.015;...
                 0.981 -0.193  0.009;...
                 0.998 -0.058  0.018;... 
                -0.991  0.135 -0.017;...
                -0.987  0.160 -0.012;...
                -0.999 -0.035 -0.019;... 
                -0.999 -0.051 -0.018;...
                -0.996 -0.091 -0.020];
tilt = [-5 -4 -3 -2 -1 1 2 3 4 5]*pi/180;
% rot_tilt= [4.86 3.89 2.92 2.09 0.98 0.90 2.05 3.06 3.99 5.01]*pi/180;
% rot_tilt= [-4.86 -3.89 -2.92 -2.09 -0.98 0.90 2.05 3.06 3.99 5.01]*pi/180;
tvecs_tilt = [0.946 -1.258 -12.655;...
                 0.667 -1.236 -10.310;...
                 0.679 -0.739 -7.654;...
                 0.379 -0.579 -5.296;...
                 0.155 -0.331 -2.622;...
                -0.190  0.428  2.835;...
                -0.361  0.875  5.323;...
                -0.372  1.296  8.403;...
                -0.513  1.847  11.477;...
                -0.690  2.491  14.089];
             
     
sizex = 128; sizey = 128;
% iNum = 361; jNum = 181;
iNum = 81; jNum = 41;
Xs = zeros(jNum,iNum); Ys = zeros(jNum,iNum); Zs = zeros(jNum,iNum);
res_pan = zeros(jNum,iNum);  res_tilt = zeros(jNum,iNum);
ve_pan  = zeros(jNum,iNum,3); ve_tilt = zeros(jNum,iNum,3);
te_pan = zeros(jNum,iNum,3);  te_tilt = zeros(jNum, iNum,3);

% Now, start the minimization 
for j = 1:jNum
    nstr = fprintf( '.' );
%     phi = -pi/2 + pi/(jNum-1) * (j-1);
    phi = 0 + 2*pi/(jNum-1) * (j-1);
    for i = 1:iNum
        the = 0 + pi/(iNum-1) * (i-1);        
        te(1) = cos(phi)*sin(the);
        te(2) = sin(phi)*sin(the);
        te(3) = cos(the);
        
%         the = -pi + 2*pi/(iNum-1) * (i-1);
%         te(1) = cos(phi)*cos(the);
%         te(2) = cos(phi)*sin(the);
%         te(3) = sin(phi);
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        options = optimset('TolFun', 1e-15, 'TolX', 1e-15, 'Display', 'off', 'Algorithm', 'interior-point', 'LargeScale', 'off', 'GradObj', 'on');
        ve0 = [0,0,0];
%         [ve, res] = fmincon('calibrationfunH',ve0,[],[],[],[],[-500;-500;-500],[500;500;500], [], options, pan, te, tvecs_pan);
%         res_pan(i,j) = res; ve_pan(i,j,:) = ve; te_pan(i,j,:)=te;
        
                
        [ve, res] = fmincon('calibrationfunH',ve0,[],[],[],[],[-500;-500;-500],[500;500;500], [], options, tilt, te, tvecs_tilt);
        res_tilt(j,i) = res; ve_tilt(j,i,:) = ve; te_tilt(j,i,:)=te;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%         [H_pan, f_pan, errorSum_pan]   = computeQuadProgParams(rot_pan, te, tvecs_pan);
%         [H_tilt, f_tilt, erroSum_tilt] = computeQuadProgParams(rot_tilt, te, tvecs_tilt);
%         
%         opts = optimoptions('quadprog','Algorithm','interior-point-convex', 'Display', 'off');
%         [x_pan, fval_pan, eflag_pan, output_pan, lambda_pan] = quadprog(H_pan,f_pan,[],[],[],[],[],[],[],opts);
%         res_pan(j,i) = fval_pan;
%         ve_pan(j,i,:) = x_pan;
%         
%         [x_tilt, fval_tilt, eflag_tilt, output_tilt, lambda_tilt] = quadprog(H_tilt,f_tilt,[],[],[],[],[],[],[],opts);
%         res_tilt(j,i) = fval_tilt;
%         ve_tilt(j,i,:) = x_tilt;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
% %         % Compute variables
% %         tmp_pan = repmat(1-cos(rot_pan), [3 1]);
% %         one_minus_cos_pan = repmat(tmp_pan(:), [1 3]);        
% %         tmp_tilt = repmat(1-cos(rot_tilt), [3 1]);
% %         one_minus_cos_tilt = repmat(tmp_tilt(:), [1 3]);
% %                        
% %         rrT_I = te*te' - eye(3);
% %         
% %         Qr = [0 -te(3,1) te(2,1);...
% %               te(3,1) 0 -te(1,1);...
% %               -te(2,1) te(1,1) 0];
% %         
% %         tmp_pan = repmat(sin(rot_pan), [3 1]);
% %         sin_pan = repmat(tmp_pan(:), [1 3]);
% %         tmp_tilt = repmat(sin(rot_tilt), [3 1]);
% %         sin_tilt = repmat(tmp_tilt(:), [1 3]);  
% %         
% %         Qr_sin_pan  = sin_pan.*repmat(Qr, [numel(rot_pan),1]);
% %         Qr_sin_tilt = sin_tilt.*repmat(Qr, [numel(rot_tilt),1]);
% %         
% %         % coefficient
% %         coef_pan  = one_minus_cos_pan.*repmat(rrT_I, [numel(rot_pan),1]) + Qr_sin_pan;
% %         coef_tilt = one_minus_cos_tilt.*repmat(rrT_I, [numel(rot_tilt),1]) + Qr_sin_tilt;
% %         
% %         % indep term
% %         indep_pan  = tvecs_pan;
% %         indep_tilt = tvecs_tilt;
% %         
% %         % Solve for rotation with the translation (for pan)
% %         ve0 = [0,0,0];
% %         options = optimset('MaxIter',50, 'Display', 'none');
% %         [we,resnorm,residual,exitflag,output,lambda] = lsqlin(coef_pan, indep_pan, [],[],[],[],[],[], ve0, options);
% %         res_pan(j,i) = resnorm;
% %         ve_pan(j,i,:) = ve;
% %         
% %         % Solve for rotation with the translation (for tilt)
% %         ve0 = [0,0,0];
% %         options = optimset('MaxIter',50, 'Display', 'none');
% %         [we,resnorm,residual,exitflag,output,lambda] = lsqlin(coef_tilt, indep_tilt, [],[],[],[],[],[], ve0, options);
% %         res_tilt(j,i) = resnorm;
% %         ve_tilt(j,i,:) = ve;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % for drawing
        Xs(j,i) = te(1);
        Ys(j,i) = te(2);
        Zs(j,i) = te(3);
    end
end

keyboard





