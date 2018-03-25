function sig = newData(centerFrequency, sampleRate)

% Reads the newest data from the receivers. Returns this data in the form
% of a structured array sig with fields:
% - centerFrequency: The frequency that the the receviers are listening to
% - sampleRate: The rate at which new samples are recorded
% - data: An m by n matrix, where m is the number of receivers and n is the
%         length of the recorded data

load readLines.mat l; % Load number of previously read lines to variable l

file = dir('*.cfile'); % Get list of all files with ending .cfile in pwd
data_struct = repmat(struct('data',[]), ...
    1,length(file));    % Allocate an array of structs
                        % to save the new data from each receiver
l_read = zeros(1,length(file)); % Allocate an array for number of 
                                % read lines for each .cfile

% Loop through all files, open them (if possible) and save the data to the
% allocated array of structs. Record how many lines of data are read from
% each file. 
for i = 1:length(file)
    f = fopen(file(i).name,'rb'); % Open file(i), returns -1 if fail
    if f == -1
        error('Could not open file %s',file(i));
    else
        fseek(f,l,'bof');   % move reading cursor l lines in to file 
                            % from begining of file ('bof') 
        tmp = fread(f);     % Read the rest of the file
        fclose(f);          % Close the file
        % The receivers record the data from one time as real1, complex1,
        % real2, comple2, ... Hence, the IQ-data is extracted like this:
        data_struct(i).data = tmp(1:2:end) + 1i*tmp(2:2:end); 
        l_read(i) = length(tmp);
    end
end
clear tmp; % tmp might be really big, best to clear 

min_l_read = min(l_read);   % Find the minimum of read lines, in case a 
                            % recevier was updated before another or
                            % inbetween filereads
data = zeros(length(file),min_l_read/2);    % Allocate matrix for data in 
                                            % sig-struct

% Loop through all of the read data and save the results to the data-matrix
for i = 1:length(file)
    data(i,:) = data_struct(i).data(1:min_l_read/2);
end
clear data_struct; % if tmp was big, data_struct will be huge. Best  to clear

% Update and save number of read lines. 
l = l + min_l_read;
save('readLines.mat','l');

% Produce sig-struct:
sig = struct('centerFrequency',centerFrequency,...
    'sampleRate',sampleRate,...
    'data',data);