%%
function [totalNumFrames] = saveAllFrames(frames, pathname, name, initNumFrame)

newpathname = fullfile(pathname, name);
if ~exist(newpathname, 'dir')
    mkdir(newpathname);
end

for ii=1:size(frames,3)
    tmp = mat2gray(flipud(frames(:,:,ii)'));
    imwrite(tmp, fullfile(newpathname, strcat(name, sprintf('_%05d', ii+initNumFrame),'.png')));
end

totalNumFrames = initNumFrame+size(frames,3);

end