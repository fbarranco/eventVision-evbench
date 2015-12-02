function [f] = calibrationfunH2(w, theta, r, tvecs)

%     r = [-0.052 0.997 -0.052];
%     w = [46.554 312.956 -3.629];
    
%     r = [-0.94 0.324 -0.105];
%     w = [-221.493 -86.002 -2.419];

    % Compute variables
    N = numel(theta);
    one_minus_cos_theta = repmat(reshape(1-cos(theta),[1 1 N]), [3 3 1]);          
    rrT_I = repmat(r'*r - eye(3), [1 1 N]);

    Qr = [0 -r(3) r(2);...
           r(3) 0 -r(1);...
          -r(2) r(1) 0];
    
    sin_theta = repmat(reshape(sin(theta), [1 1 N]), [3 3 1]);    
    Qr_sin_theta = sin_theta.*repmat(Qr, [1 1 N]);  


    % coefficient
    coef  = one_minus_cos_theta.*rrT_I + Qr_sin_theta;

    % indep term    
%     b1 = squeeze(tvecs(:,1)); b2 = squeeze(tvecs(:,2)); b3 = squeeze(tvecs(:,3));
%     a1 = squeeze(coef(1,1,:)); a2 = squeeze(coef(1,2,:)); a3 = squeeze(coef(1,3,:));
%     a4 = squeeze(coef(2,1,:)); a5 = squeeze(coef(2,2,:)); a6 = squeeze(coef(2,3,:));
%     a7 = squeeze(coef(3,1,:)); a8 = squeeze(coef(3,2,:)); a9 = squeeze(coef(3,3,:));

    f = 0; 
    
    for ii=1:N
        f = f + norm(squeeze(coef(:,:,ii))*w' - squeeze(tvecs(ii,:))');
    end
    
end    