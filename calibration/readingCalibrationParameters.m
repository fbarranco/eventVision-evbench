% readingCalibrationParameters
%
%             
% DESCRIPTION
%   The function reads the calibration parameters from two txt files (rotationVectors 
%	and translationVectors). It represents in a graph the different axis of rotation
% 	and translation
% 	
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.
%


% Reading rotation and translation vectors

% Examples of filenames
%R = load('rotationVectors.txt');
%T = load('translationVectors.txt');

%Examples of calib_angles
%calib_angles = 0.175:-0.035:-0.175;

% Repeat the angle structure (2 calibration measures with the same angle,
% for 5 different poses of the calibration grid)
cnt = 1;
for ii=calib_angles    
    anglex2(cnt)=ii;
    anglex2(cnt+1)=ii;
    
    cnt = cnt+2;    
end

angle = [anglex2, anglex2, anglex2, anglex2, anglex2];


figure, plot(R(:,1), 'r'), hold on
plot(R(:,2),'b'), plot(R(:,3),'g'), plot(T(:,1), 'c'), plot(T(:,2), 'm'), plot(T(:,3), 'y'), plot(angle, 'b--')


% According to the results, T(:,1) is the pan angle,  
% T((:,2) is the tilt, and T(:,3) the Z (the rotation and translation
% vectors are switched)

