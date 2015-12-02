function [T, R] = computeRotationTranslationFromPanTiltAngle(angle_panOrTilt, r_panOrTilt, v_panOrTilt, w_panOrTilt)

% T(theta) = ((1-cos(theta)(r^T*r-I) + sin(theta)*Ar)*v
term1 = (1-cos(angle_panOrTilt))*(r_panOrTilt'*r_panOrTilt - eye(3));
term2 = sin(angle_panOrTilt)*[0 -r_panOrTilt(3) r_panOrTilt(2); r_panOrTilt(3) 0 -r_panOrTilt(1); -r_panOrTilt(2) r_panOrTilt(1) 0];
T = ((term1+term2)*v_panOrTilt')';

% R(theta) = w^T*w + cos(theta)*(I - w^T*w) + sin(theta)*Aw
term1 = w_panOrTilt'*w_panOrTilt;
term2 = cos(angle_panOrTilt)*(eye(3) - term1);
term3 = sin(angle_panOrTilt)*[0 -w_panOrTilt(3) w_panOrTilt(2); w_panOrTilt(3) 0 -w_panOrTilt(1); -w_panOrTilt(2) w_panOrTilt(1) 0];
R = term1 + term2 + term3;

end