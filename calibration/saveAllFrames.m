function [totalNumFrames] = saveAllFrames(frames, pathname, name, initNumFrame)
% saveAllFrames
%   frames    		- Structure with gray data from the output of getAPSframesDavisGS.
%   pathname    	- Folder to store the frames.
%   name   			- Name of the png files.
%   initNumFrame    - The number of the first png file to be stored.
%
% RETURN
%   totalNumFrames  - The number of the last png file to be stored. 
%             
% DESCRIPTION
%   The function save all the frames in a chunk of data from DAVIS sensor. 
% 	This saves the gray data in a folder in $pathname/$name_%05.png where the first
%	frame starts with the number $initNumFrame. All the frames are in the structure
% 	$frames, read with getAPSframesDavisGS (the output has six components, the 3rd 
%	is this gray data for $frames)
%
%   Copyright (C) 2015  Francisco Barranco, 01/12/2015, Universidad de Granada.
%   License, GNU GPL, free software, without any warranty.
%

newpathname = fullfile(pathname, name);
if ~exist(newpathname, 'dir')
    mkdir(newpathname);
end

for ii=1:size(frames,3)
    tmp = mat2gray(flipud(frames(:,:,ii)'));
    imwrite(tmp, fullfile(newpathname, strcat(name, sprintf('_%05d', ii+initNumFrame),'.pgm')));
end

totalNumFrames = initNumFrame+size(frames,3);

end