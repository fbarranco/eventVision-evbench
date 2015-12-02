function E = errorForFlow(DxGt,DyGt,DxEst,DyEst)
% errorForFlow
%   DxGt    - Horizontal flow component -- ground truth.
%   DyGt    - Vertical flow component -- ground truth.
%   DxEst   - Horizontal flow component -- estimate.
%   DyEst   - Vertical flow component -- estimate.
%
% RETURN
%   E       - Error measures in that order:
%             * speed difference in PIXEL or RAD per FRAME
%             * angular difference in RAD
%             * speed vector difference in PIXEL OR RAD per FRAME
%             * endpoint error in RAD
%
% DESCRIPTION
%   The endpoint error was defined by Barron, Fleet, & Beauchemin (1994).
%   Performance of optical flow techniques. International Journal of 
%   Computer Vision 12:1, 43-77.
%
%   Copyright (C) 2014  Florian Raudies, 10/10/2014, Boston University.
%   License, GNU GPL, free software, without any warranty.
%

SpdGt       = hypot(DxGt, DyGt);    % pixel / frame
SpdEst      = hypot(DxEst, DyEst);  % pixel / frame
SpdDiff     = abs(SpdGt - SpdEst);
AngDiff     = (DxGt.*DxEst + DyGt.*DyEst)./(eps + SpdGt.*SpdEst);
AngDiff(AngDiff>1) = 1;
AngDiff     = acos(AngDiff); % RAD
SpdVec      = hypot(DxGt-DxEst, DyGt-DyEst); % pixel / frame
EndErr      = (DxGt.*DxEst + DyGt.*DyEst + 1) ...
            ./(eps + sqrt( (DxGt.^2 + DyGt.^2 + 1).*(DxEst.^2 + DyEst.^2 + 1) ));
EndErr(EndErr>1) = 1;
EndErr      = acos(EndErr);

E       = zeros(4,1);
E(1)    = mean(SpdDiff(:)); % Speed difference.
E(2)    = mean(AngDiff(:)); % Angular difference.
E(3)    = mean(SpdVec(:));  % Speed vector difference.
E(4)    = mean(EndErr(:));  % Endpoint error.
