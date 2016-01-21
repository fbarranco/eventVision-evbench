function [H, f, errorSum] = computeQuadProgParams(theta, r, tvecs)
% computeQuadProgParams 
%   theta    	- the angle for the rotation.
%   r   		- The rotation axis.
%   tvecs    	- The list of translation vectors.
%
% RETURN
%   f  			- The output function cost to be minimized
%	H           - The matrix with the 3x3 values of the system
%	errorSum	- Summation of the error (indep term)
%             
% DESCRIPTION
%   The function is passed as an argument for the minimization of the system 
%	that is build with the parameters. The method for solving the optimization
%	problem is quadratic programming. The details are given in the paper:
% 	A dataset for Visual Navigation with Neuromorphic Methods, 
%	F. Barranco, C. Fermuller, Y. Aloimonos, T. Delbruck, 
%	Frontiers in Neuroscience: Neuromorphic Engineering, 1-16, 2015.
%
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.
 

    % Compute variables
    N = numel(theta);
    one_minus_cos_theta = repmat(reshape(1-cos(theta),[1 1 N]), [3 3 1]);          
    rrT_I = repmat(r*r' - eye(3), [1 1 N]);
    
    Qr = [0 -r(3,1) r(2,1);...
           r(3,1) 0 -r(1,1);...
          -r(2,1) r(1,1) 0];

    sin_theta = repmat(reshape(sin(theta), [1 1 N]), [3 3 1]);    
    Qr_sin_theta = sin_theta.*repmat(Qr, [1 1 N]);
    
    
    % coefficient
    coef  = one_minus_cos_theta.*rrT_I + Qr_sin_theta;
        
    % indep term    
    b1 = squeeze(tvecs(:,1)); b2 = squeeze(tvecs(:,2)); b3 = squeeze(tvecs(:,3));
    a1 = squeeze(coef(1,1,:)); a2 = squeeze(coef(1,2,:)); a3 = squeeze(coef(1,3,:));
    a4 = squeeze(coef(2,1,:)); a5 = squeeze(coef(2,2,:)); a6 = squeeze(coef(2,3,:));
    a7 = squeeze(coef(3,1,:)); a8 = squeeze(coef(3,2,:)); a9 = squeeze(coef(3,3,:));
    

    a = sum(2*(a1.^2+a4.^2+a7.^2));
    b = 0;
    c = 0;
    d = sum(4*(a1.*a2+a4.*a5+a7.*a8));
    e = sum(2*(a2.^2+a5.^2+a8.^2));
    f = 0;
    g = sum(4*(a1.*a3+a4.*a6+a7.*a9));
    h = sum(4*(a2.*a3+a5.*a6+a8.*a9));
    k = sum(2*(a3.^2+a6.^2+a9.^2));
    
    r = sum(-2*a1.*b1 - 2*a4.*b2 - 2*a7.*b3);
    s = sum(-2*a2.*b1 - 2*a5.*b2 - 2*a8.*b3);
    t = sum(-2*a3.*b1 - 2*a6.*b2 - 2*a9.*b3);
    
    H=[a b c; d e f; g h k];
    f=[r s t];
    errorSum = sum(b1.^2+b2.^2+b3.^2);
end