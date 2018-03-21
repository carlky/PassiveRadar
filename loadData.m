function s = loadData(filename)
    %This function is used to load all data, in order
    %to ensure that all files use the same syntax.
    %OBS: Input only the name of the file, not the full path!
    %The returned data is in the form of a struct with
    %fields CenterFrequency, SampleFrequency and Data.
    
    path = [pwd filesep 'Data' filesep filename '.mat'];
    
    s = load(path);
    
    