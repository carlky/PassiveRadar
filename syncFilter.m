% ---------------------------------------------
% SyncFilter
% input: signal (struct)
%        fields: sampleFreq, centerFreq, data 
% output: filterd signal (struct)
% Author: Johan
% ---------------------------------------------
function [Filter_signal] = syncFilter(signal)
    raw_data = signal.data;

hpFilter = designfilt(  'highpassfir','StopbandFrequency',10, ...
         'PassbandFrequency',0.5e6,'PassbandRipple',0.5, ...
         'StopbandAttenuation',65,'SampleRate',40e6, ...
        'DesignMethod','kaiserwin');
    fvtool(hpFilter)
    Filter_signal = filtfilt(hpFilter,raw_data);
    
end


