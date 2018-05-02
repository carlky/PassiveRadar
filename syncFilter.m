% ---------------------------------------------
% SyncFilter
% input: signal (struct)
%        fields: sampleFreq, centerFreq, data 
% output: filterd signal (struct)
% Author: Johan
% ---------------------------------------------
function [Filter_signal] = syncFilter(signal)
    raw_data = signal.data;
    [m,~] = size(raw_data);
    for i=1:m
        hpFilter = designfilt(  'highpassfir','StopbandFrequency',10, ...
         'PassbandFrequency',0.3e6,'PassbandRipple',0.5, ...
         'StopbandAttenuation',65,'SampleRate',40e6, ...
         'DesignMethod','kaiserwin');
    % fvtool(hpFilter)  % Display filter
    Filter_signal(i,:) = filtfilt(hpFilter,raw_data(i,:));
    end
end


