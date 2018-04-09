% ************************************************************
% DESCRIPTION:  A function that determines the time difference 
%               between two signals
%
% INPUT:        Signal_1, Signal_2 , 1 x n array or n x 1 array
%
% OUTPUT:       delT [time] 
%
% WRITTEN BY:   Johan Karlsson 
% STATUS:       Finished, Tested, 
% ************************************************************

function [delT] = findDelay(signal_1, signal_2)

[acor,lag] = xcorr(signal_1.data, signal_2.data);   
[~,I] = max(abs(acor));
lagDiff = lag(I);                
delT= lagDiff/signal_1.sampleRate;  
% delT = number of indices * time per index [1/f  = t]
end

