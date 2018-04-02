function sig = syncSignals(oldSig,syncFrequency)

% Function to sync oldSig signal according to signal broadcast at
% syncFrequency. Returns an identical signal object, sig with the same
% fields as sigOld, that is:
% - centerFrequency: The frequency that the the receviers are listening to
% - sampleRate: The rate at which new samples are recorded
% - data: An m by n matrix, where m is the number of receivers and n is the
%         length of the recorded data
% The difference is that the data has zeros added in the begining and/or 
% end to make sure the signals have the sime time reference. 

[m,n] = size( oldSig.data); % Size of data for later use

% Convert syncFrequency to index of fouriertransform and make sure that
% index is valid and not outside the length (and therefore bandwidth) of
% the recorded frequencies. If not, thow error!
syncIndex = round(n*(syncFrequency-oldSig.centerFrequency + ...
    oldSig.sampleRate/2)/oldSig.sampleRate);
if syncIndex < 1 || syncIndex > 
    error('Sync frequency  outside bandwidth!! Aborting!');
end

% Calculate the fourier transform and shift it to differentiate between
% positive and negative frequencies.
shiftedFft = fftshift( fft(oldSig.data, 2^nextpow2(n), 2), 2);
absShiftedFft = abs(shiftedFft);

% Calculate a noisefloor to compare the fourier transform with. The
% noisefloor is taken as the average absolute movement between two
% frequencies. Select the frequencies above the noise floor. 
noiseFloor = mean( abs( (absShiftedFft( :, 2:n) - absShiftedFft( :, 1:n-1))));
selected = absShiftedFft > noiseFloor;

clear absShiftedFft noiseFloor; % Clear to keep memory clean

% Check to make sure the sync signal is visible above the noise floor. If
% not, thow error!
if ~prod(selected(:,syncIndex)) 
    error('Sync signal not above noise floor!! Aborting!');
end

% Find the bandwidth of the signal and produce a multi dimensional
% heaviside to single out only the desired signal.
width = zeros(m,2);
for i = 1:m
    width(i,1) = find( prod( selected( m, 1:syncIndex)) == 0, 1, 'last');
    width(i,2) = find( prod( selected( m, syncIndex:n)) == 0, 1);
end
clear selected syncIndex; % Clear to keep memory clean
multiDimHeaviside = heaviside( ones( m, 1)*(1:n) - width( :, 1))...
                    .*heaviside( -ones( m, 1)*(1:n) + width( :, 2));

% Inverse fourier transform to get the signal in time domain
syncSigData = ifft( ifftshift( shiftedFft.*multiDimHeaviside, 2), ...
    2^nextpow2(n), 2);

clear shiftedFft multiDimHeaviside width; % Clear to keep memory clean

% Calculate the lag difference for the different signals relative to signal
% 1. 
lagDiff = zeros(m,1);
for i = 2:m
    [xcor,lags] = xcorr( syncSigData(1,:), syncSigData(i,:));
    [~,j] = max(abs(xcor));
    lagDiff(i) = lags(j);
end

% TODO Compensate for geometry

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