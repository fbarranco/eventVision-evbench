%
% Morimichi Nishigaki
% 

function [f, ft, fw] = ContinuousMotionField( t, w, p, A, Z )
%
% Compute motion in image given camera motion
% assume A is [fx,  0, cx;...
%               0, fy, cy;...
%               0,  0,  1];
%
    if nargin < 5
        error( 'Not enough input arguments.  See HELP ContinuousMotionField' );
    end
    if prod(size(t)) ~= 3
        error( 't must be a 3D vector' );
    end
    if prod(size(w)) ~= 3
        error( 'w must be a 3D vector' );
    end
    if size(A,1) ~= 3 || size(A,2) ~= 3
        error( 'A must be a 3x3 matrix' );
    end
    if size(Z,1) ~= 1
        error( 'Z must be a row vector' );
    end
    if size(p,1) ~= 2 && size(p,1) ~= 3
        error( 'p must have two or three rows' );
    end
    if size(p,2) ~= size(Z,2)
        error( 'p and Z must have same number of columns' );
    end

    if size(p,1) == 2
        p(3,:) = ones(1,size(p,2));
    end
    
%     iA = inv(A);
%     pn = iA*p;    
    pn = A\p;

    fx = A(1,1);
    fy = A(2,2);
    
    ft = [-fx.*t(1)+fx.*t(3).*pn(1,:);...
          -fy.*t(2)+fy.*t(3).*pn(2,:)]./repmat(Z,[2,1]);

    fw = [fx.*pn(1,:).*pn(2,:).*w(1)-fx.*(1+pn(1,:).^2).*w(2)+fy.*pn(2,:).*w(3);...
          fy.*(1+pn(2,:).^2).*w(1)-fy.*pn(1,:).*pn(2,:).*w(2)-fx.*pn(1,:).*w(3)];

    f = ft + fw;