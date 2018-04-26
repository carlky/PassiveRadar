function sig = syncSignals(oldSig,syncFrequency,syncBandwidth,plotSteps)

% Function to sync oldSig signal according to signal broadcast at
% syncFrequency with bandwidth syncBandwidth. Returns an identical signal 
% object, sig with the same fields as sigOld, that is:
% - centerFrequency: The frequency that the the receviers are listening to
% - sampleRate: The rate at which new samples are recorded
% - data: An m by n matrix, where m is the number of receivers and n is the
%         length of the recorded data
% The difference is that the data has zeros added in the begining and/or 
% end to make sure the signals have the sime time reference. The function
% does not compensate for geometry and assumes that the syncsignal arrives
% at all receivers approxiamtelly simultaneously. Optional argument
% plotSteps can be set to true to plot all analysis steps. However, this is
% considerably slower. 

% TODO: COMPENSATE FOR FREQUENCY SHIFT OF LOCAL OSCILLATORS

[m,n] = size( oldSig.data); % Size of data for later use

% Default for plotSteps is false, unless an argument is provided
if ~exist('plotSteps','var')
    plotSteps = false;
end


% Convert syncFrequency to index of fouriertransform and make sure that
% index is valid and not outside the length (and therefore bandwidth) of
% the recorded frequencies. If not, thow error!
syncIndex = round(n*(syncFrequency-oldSig.centerFrequency + ...
    oldSig.sampleRate/2)/oldSig.sampleRate);
syncBandwidthIndex = round(n*syncBandwidth/2/oldSig.sampleRate);
width = syncIndex + [-1,1]*syncBandwidthIndex;
if width(1) < 1 || width(2) > n
    error('Sync frequency  outside bandwidth!! Aborting!');
end

syncSigData = ifft(ifftshift(fftshift(fft(oldSig.data,[],2),2)...
    .*heaviside((1:n)-width(1)).*heaviside(width(2)-(1:n)),2),[],2);

% Calculate the lag difference for the different signals relative to signal
% 1. Plot the frequencies for the syncSigData and the xcor between the
% different signals if plotSteps is enabled. 
lagDiff = zeros(m,1);

if plotSteps
    clf;
    plot(real(fftshift(fft(syncSigData(1,:)))));
    pause
end
for i = 2:m
    [xcor,lags] = xcorr( syncSigData(1,:), syncSigData(i,:));
    [~,j] = max(real(xcor));
    lagDiff(i) = lags(j);
    if plotSteps
        clf;
        subplot(2,1,1)
        plot(real(fftshift(fft(syncSigData(1,:)))))
        subplot(2,1,2)
        plot(real(xcor),'b.')
        hold on;
        plot(j,real(xcor(j)),'ro')
        pause
    end
end

% Change lagDiff so that the minimum lagDiff is 0 and create place in
% memory for the new data which will be max(lagDiff) longer than the
% original data. Put the old data into the new data with the lagg
% differences compensated for. 
lagDiff = lagDiff - min(lagDiff);
data = zeros(m,n+max(lagDiff));
for i = 1:m
    data(m, (1:n) + lagDiff(i)) = oldSig.data(m,:);
end

% Create final sig object to return
sig = struct('centerFrequency',oldSig.centerFrequency,...
    'sampleRate',oldSig.sampleRate,...
    'data',data);