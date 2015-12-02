function E = errorForSelfMotion(VelGt,OmegaGt, VelEst,OmegaEst)
% errorForSelfMotion
%   VelGt       - Ground-truth for linear velocity (3D vector).
%   OmegaGt     - Ground-truth for rotational velocity (ground-truth).
%   VelEst      - Estimate of linear velocity.
%   OmegaEst    - Estimate of rotational veloctiy.
%
% RETURN
%   E   - Vector with the following three error meausres (in that order):
%         * Angular difference for linear velocities.
%         * Angular difference for rotational velocities.
%         * Speed difference for rotational velocities.
%
%   Copyright (C) 2014  Florian Raudies, 10/10/2014, Boston University.
%   License, GNU GPL, free software, without any warranty.
%

E       = zeros(3,1);
E(1)    = angularDifference(   VelGt,   VelEst  );
E(2)    = angularDifference(   OmegaGt, OmegaEst);
E(3)    = speedDifference(     OmegaGt, OmegaEst);

function a = angularDifference(X,Y)
a = sum(X.*Y)./(eps+sqrt(sum(X.^2)*sum(Y.^2)));
a(a>1) = 1;
a = acos(a);

function s = speedDifference(X,Y)
s = sqrt(sum(X.^2)) - sqrt(sum(Y.^2));
