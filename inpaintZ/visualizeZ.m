function out = visualizeDEM(Z)

contrast = 0.75;

N = getNormals_conv(Z);

Z = (Z - min(Z(:)))./max(eps,max(Z(:)) - min(Z(:)));
Z = .75 - Z * .85;

S = N(:,:,3);
S = (S - min(S(:)))./max(eps,max(S(:)) - min(S(:)));
S = S*contrast + (1-contrast);

vis = max(0, min(1, hsv2rgb(cat(3, Z, ones(size(S))*2/3, S))));

vis(isnan(N)) = 0;

if nargout == 0
  imagesc(vis);
  imtight;
else
  out = vis;
end
