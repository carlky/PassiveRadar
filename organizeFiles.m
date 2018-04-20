function dirName=organizeFiles()

% Saves the data files from startGather inside a folder with the format 
% “Reading dd-MMM-yyyy HH-mm-ss”. That folder in turn is located in the
% folder "Data". The files from startGather has the format "captX.cfile".
% Note: This function only works if the data files are in the same folder
% as this function.

date_and_time=datestr(datetime('now','InputFormat','yyyy-MM-dd HH-mm-ss'));
date_and_time = strrep(date_and_time,':','-');
%strrep replaces : with -. The colon creates an issue for the Windows
%command prompt.
dirName=['Reading ' date_and_time];

mkdir('Data',dirName)               %mkdir creates a folter with the name 
                                    %'Reading day-month-2018 HH-mm-ss'.                   
pathName=['Data/',dirName];         %The folder location for the files.                            
movefile('*.cfile',pathName)        %Moves all the files that ends in .cfile to the folder destination.                      

end