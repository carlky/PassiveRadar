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


% Time vector:
t=(0:(n-1))/oldSig.sampleRate;
% Local oscillator for frequency shift:
lo=exp(1i*2*pi*-(syncFrequency-oldSig.centerFrequency).*t);
% Downconverted signal: 
down_sig=oldSig.data.*lo;
% Filter:
LPF=fir1(256,syncBandwidth/2/(oldSig.sampleRate/2),'low');

down_sig_filt = zeros(m,n);
for i = 1:m
    down_sig_filt(i,:) = filtfilt(LPF,1,down_sig(i,:));
    % If plotSteps, the first results are plotted for verification that 
    % everything is working as intended. The rest of the filtering is
    % continued and the program is paused at the end waiting for keypress
    % to proceed.
    if plotSteps && i == 1
        clf;
        subplot(3,1,1)
        freq = linspace(-oldSig.sampleRate/2,oldSig.sampleRate/2,...
            length(oldSig.data));
        plot(freq,abs(fftshift(fft(oldSig.data(1,:)))))
        title('Original spectrum')
        subplot(3,1,2)
        plot(freq,abs(fftshift(fft(down_sig(1,:)))))
        title('Frequency shifted spectrum')
        subplot(3,1,3)
        plot(freq,abs(fftshift(fft(down_sig_filt(1,:)))))
        title('Filtered frequency shifted spectrum')
        pause(0.1) % Allow plot to show up
    elseif plotSteps && i == m
        pause
    end
end

% Calculate the lag difference for the different signals relative to signal
% 1. Plot the frequencies for the syncSigData and the xcor between the
% different signals if plotSteps is enabled. 
lagDiff = zeros(m,1);

for i = 2:m
    [r,lags] = xcorr( down_sig_filt(1,:), down_sig_filt(i,:));
    [~,j] = max(r);
    lagDiff(i) = lags(j);
    if plotSteps
        clf;
        plot(abs(r),'b.')
        hold on;
        plot(j,abs(r(j)),'ro')
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

% Filter out syncsignal:
