function saveData(CenterFrequency,SampleFrequency,Data,varargin)
    %This function is used to save all data, in 
    %order to ensure that all files are saved in
    %the same directory. The goal is to ensure that
    %file I/O is handled in the background. 
    %The user has to specify the center frequency, the 
    %sample frequency, and input the data as a numeric array. 
    %The user can choose to specify the filename, if no 
    %filename is specified DD-MMM-YYYY_hh:mm:ss.mat will be 
    %used to save the data. 
    
    p = inputParser;
    
    defaultFilename = strrep(datestr(datetime),' ','_');
    %Default Filename is DD-MMM-YYYY_hh:mm:ss
    
    addRequired(p,'CenterFrequency',@isnumeric);
    addRequired(p,'SampleFrequency',@isnumeric);
    addRequired(p,'Data',@isnumeric);
    addParameter(p,'Filename',defaultFilename,@ischar);
    
    parse(p,CenterFrequency,SampleFrequency,Data,varargin{:});
    
    path = [pwd filesep 'Data' filesep p.Results.Filename '.mat'];
    
    s = struct('CenterFrequency',p.Results.CenterFrequency,...
        'SampleFrequency',p.Results.SampleFrequency,...
        'Data',p.Results.Data);
    
    save(path,'-struct','s');