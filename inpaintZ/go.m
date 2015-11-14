
clear all;

load depth/bad_im.mat
Z = im;
Z(Z == 2047) = nan;
Z = -Z;

% Z = Z(250:end, 50:500);

Zsmooth = inpaintZ(Z, 10^-1);



