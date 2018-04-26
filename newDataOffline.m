
function sig = newDataOffline(centerFrequency, sampleRate, dirName, sampleLength)

% Reads data of length sampleLength. Returns this data in the form
% of a structured array sig with fields:
% - centerFrequency: The frequency that the the receviers are listening to.
% - sampleRate: The rate at which new samples are recorded.
% - data: An m by n matrix, where m is the number of receivers and n is the
%   sampleLength that is set as a variable in the file MainOffline.m.

load readLines.mat l;
%The variable l contains the information about the amount of lines that has
%been read in the data files.

dirFolder=['Data/',dirName,'/*.cfile'];
path=dir(dirFolder);
numSDR=length(path);
%Checks how many files there are in the latest reading folder, i.e. how
%many SDRs that have saved data.

data=zeros(numSDR,sampleLength);
%Declaration of the data array.
                           
for i=1:numSDR
    filename=['Data/',dirName,'/capt' num2str(i) '.cfile'];
    f = fopen(filename,'rb');   %Open file capt(i).file, returns -1 if fail.
                                %'rb'=read binary.
    if f == -1
        error('Could not open file %s',file(i));
    else
        fseek(f,l,'bof');
        temp=fread(f,sampleLength*2);
        data(i,:)=temp(1:2:end) + 1i*temp(2:2:end);
    end
    fclose(f);          %Close the file capt(i).file.
end

clear temp;             %Temp might be really big, best to clear.

l = l + sampleLength*2;
save('readLines.mat','l');
%Updates the variable l with the amount of lines that have been processed
%in the saved files.

% Produce sig-struct:
sig = struct('centerFrequency',centerFrequency,...
    'sampleRate',sampleRate,...
    'data',data);
end