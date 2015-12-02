function [totalNumFrames] = saveAllDVSFrames(x, y, t, pol, pathname, name, initNumFrame)

DVSW = 240;
DVSH = 180;

newpathname = fullfile(pathname, name);
if ~exist(newpathname, 'dir')
    mkdir(newpathname);
end

pol(pol==0)=-1;
interval = 65e3;

cnt = 1;
for tt = t(1):interval:t(end)-interval
    xtmp = x; ytmp = y; poltmp = pol; ttmp = t; 
    mask = t<tt | t>(tt+interval);
    xtmp(mask)=[]; ytmp(mask)=[]; poltmp(mask)=[]; ttmp(mask)=[];
    
    %onofflist=xtmp*DVSW+ytmp+1;
    fr=zeros(DVSH,DVSW);    
    onofflist = sub2ind(size(fr), ytmp+1, xtmp+1);
    fr(onofflist)=poltmp;
    
    newfr = fr;    
    newfr(fr==0)=0.5059;
    newfr(fr==1)=1;
    newfr(fr==-1)=0;
    imwrite(flipud(newfr), fullfile(newpathname, strcat('dvs_',name, sprintf('_%05d', cnt+initNumFrame),'.pgm')));

    %imwrite(fr, fullfile(newpathname, strcat('dvs_',name, sprintf('_%05d', cnt+initNumFrame),'.png')));
    cnt = cnt+1;    
end
totalNumFrames = cnt-1 + initNumFrame;
end

        
%         if(pauseflag==0)&&(~isempty(tms)),
%             imagesc(fr,[-1 1]);
%             colormap gray
%             axis xy;
%             set(gca,'xtick',[],'ytick',[]);
%             axis square
%             box off
%             axis off
%         end

