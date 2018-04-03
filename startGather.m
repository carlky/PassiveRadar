function numSDR = startGather(centerFrequency, sampleRate, duration)

% Finds connected SDR-RTL devices and initiates datacollection to a
% .cfile with name captN where N is the serial number of the SDR.
% All SDRs need to have unique serial number, to set this use:
% 'rtl_eeprom -d 0 -s 01' for setting device 0 with serial number 01.  

l = 0; % Reference for newData for how much data has been read
save('readLines.mat','l');

system('rm *.cfile'); % Remove all previous recordings

[~,cmdout] = system('rtl_eeprom'); % Check for plugged in devices

if contains(cmdout,'No supported devices found.') || ...
        contains(cmdout,'/bin/bash: rtl_eeprom: command not found')
    
    error('Error: \n \n %s', cmdout);
    
else
    
    dev_num = []; % array for device USB number
    
    % Find all devices in response from rtl_eeprom call. Callback (cmdout)
    % is formatted:
    % n:  Generic RTL2832U OEM
    % where n is an integer number.
    s = string(strsplit(cmdout,newline));
    matches = strfind(s, ":  Generic RTL2832U OEM");
    for i = 1:length(s)
        if length(matches{i}) == 1
            dev_num = [dev_num, str2double(...
                convertStringsToChars(extractBefore(s(i),':')))];
        end
    end
    %disp(dev_num)
    
    dev_ser = dev_num; % array for device serial number (values changed later)
    % Loop through all devices and find their serial number.
    for i = 1:length(dev_num)
        [~,cmdout] = system(['rtl_eeprom -d ' num2str(dev_num(i))]);
        %disp(['rtl_eeprom -d ' num2str(dev_num(i))])
        %disp(cmdout)
        %disp(convertStringsToChars(extractBetween(cmdout,'Serial number:',newline)))
        dev_ser(i) = str2double(convertStringsToChars(extractBetween(cmdout,'Serial number:',newline)));
    end
    
    %disp(dev_ser)
    
    % Send cmd to all detected SDRs to start recording. 
    cmdin = ['rtl_sdr -f %d -s %d -n %d -g 8.7 -d %d '...
        pwd filesep 'capt%d.cfile &']; % Format for command
    for i=1:length(dev_num)
        system(sprintf(cmdin,centerFrequency,sampleRate,...
            duration*sampleRate,dev_num(i),dev_ser(i)));
    end
    
    numSDR = length(dev_num);
end