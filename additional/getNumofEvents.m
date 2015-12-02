function [numEvents]=getNumofEvents(file)

path = '';
f=fopen([path,file],'r');
% skip header lines
bof=ftell(f);
line=native2unicode(fgets(f));
tok='#!AER-DAT';
version=0;

while line(1)=='#',
    if strncmp(line,tok, length(tok))==1,
        version=sscanf(line(length(tok)+1:end),'%f');
    end
    %fprintf('%s',line); % print line using \n for newline, discarding CRLF written by java under windows
    bof=ftell(f); % save end of comment header location
    line=native2unicode(fgets(f)); % gets the line including line ending chars
end

switch version,
    case 0
        fprintf('No #!AER-DAT version header found, assuming 16 bit addresses with version 1 AER-DAT file format\n');
        version=1;
    case 1
        fprintf('Addresses are 16 bit with version 1 AER-DAT file format\n');
    case 2
        fprintf('Addresses are 32 bit with version 2 AER-DAT file format\n');
    otherwise
        fprintf('Unknown AER-DAT file format version %g',version);
end

numBytesPerEvent=6;
switch(version)
    case 1
        numBytesPerEvent=6;
    case 2
        numBytesPerEvent=8;
end

        
fseek(f,0,'eof');
numEvents=floor((ftell(f)-bof)/numBytesPerEvent); % 6 or 8 bytes/event

fclose(f);

