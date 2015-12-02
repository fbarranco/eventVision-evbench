% Reading rotation and translation vectors
R = load('rotationVectors.txt');
T = load('translationVectors.txt');

calib_angles = 0.175:-0.035:-0.175;

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


% According to the results, T(:,1) is the pan angle, and it looks like
% T((:,2) is the tilt, and T(:,3) the Z (the rotation and translation
% vectors are switched ..., maybe I took it wrong from the opencv data)

% About the calibration measures with the same angle vectors (R), I'm not sure ...