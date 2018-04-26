%% MainOffline
clc
% dirname=organizeFiles();
dirName='Reading 23-Apr-2018 10-23-42';
centerFrequency=626e6;
sampleRate=2e6;
syncFrequency = 625.5e6;

sampleLength=2e6;       
%If sample frequency is 2MHz, there will be 4 Mrows/s in the data files,
%captX.cfile. The function newDataOffline will give one second of data if
%sampleLength=2e6.

l=0;
save('readLines.mat','l');
%The variable l contains the information about the amount of lines that has
%been read in the data files.
s = dir(['Data/',dirName,'/capt1.cfile']);
tic
fileLength=s.bytes;
toc

tic
%while l<=fileLength-sampleLength*2
    sig = newDataOffline(centerFrequency, sampleRate, dirName, sampleLength);
toc
%%    
%     sig_new = syncSignals(sig_old, syncFrequency);
%     direction = findDirections(sig);
%     sig_isolated = isolateDirections(sig,direction);
%     t_delay = findDelay(sig_1,sig_2);
%     plotData(direction, t_delay, fig);
    load readLines.mat l;
%end