% This function is adapted from Jon Barron's original file: inpaintZ
% Smooth your Z!
% Jon Barron, 2011. jonbarron@gmail.com. Use at your own risk.
function Zsmooth = my_inpaintZ(Z, lambda_grad)

lambda_curve = 1;
lambda_constrain = 10^3;

Zvalid = ~isnan(Z);

fidx = find(bmorph(~Zvalid, true([3,3])));

[fi1, fj1] = ind2sub(size(Z), fidx);
fi0 = fi1 - 1;
fi2 = fi1 + 1;
fj0 = fj1 - 1;
fj2 = fj1 + 1;

fis = [fi0, fi1, fi2];
fjs = [fj0, fj1, fj2];

keepi = all(fis <= size(Z,1) & fis >= 1,2);
keepj = all(fjs <= size(Z,2) & fjs >= 1,2);

idx1 = [sub2ind(size(Z), fi0(keepi), fj1(keepi)), sub2ind(size(Z), fi1(keepi), fj1(keepi)), sub2ind(size(Z), fi2(keepi), fj1(keepi))];
idx2 = [sub2ind(size(Z), fi1(keepj), fj0(keepj)), sub2ind(size(Z), fi1(keepj), fj1(keepj)), sub2ind(size(Z), fi1(keepj), fj2(keepj))];

idx_curve = [idx1; idx2];
idx_curve = idx_curve(sum(~isnan(Z(idx_curve)),2) < 3,:);

idx_grad = [idx_curve(:,1:2); idx_curve(:,2:3)];
idx_grad = idx_grad(sum(~isnan(Z(idx_grad)),2) < 2,:);

keep = find(bmorph(~Zvalid, true([5,5])));

Zkeep = Z(keep);
[~, idx_curve] = ismember(idx_curve, keep);
[~, idx_grad] = ismember(idx_grad, keep);

Zkeep_valid = ~isnan(Zkeep);

n = size(Zkeep,1);

Acurve = 2*sparse(1:size(idx_curve,1), idx_curve(:,2), 1, size(idx_curve,1), n) - sparse(1:size(idx_curve,1), idx_curve(:,1), 1, size(idx_curve,1), n) - sparse(1:size(idx_curve,1), idx_curve(:,3), 1, size(idx_curve,1), n);
bcurve = sparse(size(Acurve,1),1);

Agrad = sparse(1:size(idx_grad,1), idx_grad(:,1), 1, size(idx_grad,1), n) - sparse(1:size(idx_grad,1), idx_grad(:,2), 1, size(idx_grad,1), n);
bgrad = sparse(size(Agrad,1),1);

Aeq = speye([n, n]);
Aeq = Aeq(Zkeep_valid,:);
beq = Zkeep(Zkeep_valid);

A = [lambda_curve*Acurve; lambda_grad*Agrad; lambda_constrain*Aeq];
b = [lambda_curve*bcurve; lambda_grad*bgrad; lambda_constrain*beq];

X = A \ b; 

Zsmooth = Z;
Zsmooth(keep) = X;



