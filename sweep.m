function s = sweep(CenterFrequency,varargin)
    p = inputParser;
    
    addRequired(p,'CenterFrequency',@isnumeric);
    addParameter(p,'SampleFrequency',1e6,@isnumeric);
    addParameter(p,'SamplesPerFrame',1024,@isnumeric);
    addParameter(p,'EnableTunerAGC',true,@islogical);
    addParameter(p,'TunerGain',0,@isnumeric);
    addParameter(p,'NumberOfSweeps',1,@isnumeric);
    
    parse(p,CenterFrequency,varargin{:});
    
    hSDR = comm.SDRRTLReceiver('0',...
        'CenterFrequency',  p.Results.CenterFrequency,...
        'SampleRate',       p.Results.SampleFrequency,...
        'SamplesPerFrame',  p.Results.SamplesPerFrame,...
        'EnableTunerAGC',   p.Results.EnableTunerAGC,...
        'TunerGain',        p.Results.TunerGain,...
        'OutputDataType',   'double');
    
    hLogger = dsp.SignalSink;
    
    for count = 1:p.Results.NumberOfSweeps
        hLogger(step(hSDR));
    end
    
    s = struct('CenterFrequency',p.Results.CenterFrequency,...
        'SampleFrequency',p.Results.SampleFrequency,...
        'Data',hLogger.Buffer());
    
    release(hSDR);