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

sig = oldSig;
clear oldSig
sampleRate = sig.sampleRate;
centerFrequency = sig.centerFrequency;

[m,n] = size( sig.data); % Size of data for later use

% Default for plotSteps is false, unless an argument is provided
if ~exist('plotSteps','var')
    plotSteps = false;
end

% Make sure that syncFrequency + bandwidth is inside bandwidth, if not
% throw error
if syncFrequency-syncBandwidth/2-centerFrequency < -sampleRate || ...
        syncFrequency+syncBandwidth/2-centerFrequency > sampleRate
    error('Sync frequency  outside bandwidth!! Aborting!');
end

% Frequency compensate for the offset of local oscillators:
df = sampleRate/n; % Resolution in frequency
fftData = fftshift(fft(sig.data,[],2),2);
indexes = round((syncFrequency-centerFrequency + ...
    sampleRate/2)/df + linspace(-1e5,1e5,2e5+1));
[~,ind] = max(fftData(:,indexes),[],2);
% Frequency relative to sync
freq = (ind-length(indexes)/2)*df;
t=(0:(n-1))/sampleRate; % Time vector
sig.data = sig.data.*lo(freq,t); % Frequency shift!
fprintf(['Done with intitial frequency shifting! \n'...
    'Starting filtering of syncsignal! \n \n'])

% Filter out only the syncsignal
% Downconverted signal: 
down_sig=sig.data.*lo(syncFrequency-centerFrequency,t);
% Filter:
LPF=fir1(256,syncBandwidth/2/(sampleRate/2),'low');

down_sig_filt = zeros(m,n);
for i = 1:m
    down_sig_filt(i,:) = filtfilt(LPF,1,down_sig(i,:));
    % If plotSteps, the first results are plotted for verification that 
    % everything is working as intended. The rest of the filtering is
    % continued and the program is paused at the end waiting for keypress
    % to proceed.
    if plotSteps
        clf;
        subplot(3,1,1)
        freq = linspace(-sampleRate/2,sampleRate/2,...
            length(sig.data));
        plot(freq,abs(fftshift(fft(sig.data(i,:)))))
        title('Original spectrum')
        subplot(3,1,2)
        plot(freq,abs(fftshift(fft(down_sig(i,:)))))
        title('Frequency shifted spectrum')
        subplot(3,1,3)
        plot(freq,abs(fftshift(fft(down_sig_filt(i,:)))))
        [~,ind]=max(abs(fftshift(fft(down_sig_filt(i,:)))));
        hold on;
        plot(freq(ind),abs(fftshift(fft(down_sig_filt(i,ind)))))
        fprintf(['SDR ' num2str(i) ' syncsignal ' num2str(freq(ind)) ...
            ' Hz from center \n \t after centering and filtering \n'])
        hold off;
        title('Filtered frequency shifted spectrum')
        pause(1) % Wait for userinput before continuing
    end
end
if plotSteps
    fprintf('\n')
end
fprintf(['Done with filtering of syncsignal! \n' ...
    'Starting time alignment! \n\n'])

% Calculate the adjustment needed for the signals to be time aligned and 
% align them

% Actual syncing:

% First: Find integer alignment and cut data that is not used:
intDelay = zeros(m,1);
for i = 2:m
    r=xcorr(down_sig_filt(1,:),down_sig_filt(i,:));
    [~,maxind]=max(r);
    intDelay(i)=maxind-(n+1); % Delay relative to middle
    % If plotSteps, plot the cross correlation pre alignment
    if plotSteps
        clf;
        t = linspace(-length(r)/sampleRate/2,...
            length(r)/sampleRate/2,length(r));
        plot(t,abs(r)/abs(r(maxind)),'b.')
        hold on;
        plot(t(maxind),1,'ro')
        hold off;
        title('Cross correlation before alignment')
        pause(1)
        if i == 2
            save('preAlignCross.mat','r','t')
        end
    end
end
%Cut away the part of the signal that do not correlate:
cut_down_sig_filt = zeros(m,n + min(intDelay) - max(intDelay));
cut_data = cut_down_sig_filt;
for i = 1:m
    cut_down_sig_filt(i,:) = ...
        down_sig_filt(i,(max(intDelay)+1:n + min(intDelay)) - intDelay(i));
    cut_data(i,:) = ...
        sig.data(i,(1 + max(intDelay):n + min(intDelay)) - intDelay(i));
end
% Second: find accurate alignment to sub sample resolution:
N = 1e2; % Limit on cross correlation width for subsample resolution for 
    % increasing speed of calculation
for i = 2:m
    r=xcorr(cut_down_sig_filt(1,:),cut_down_sig_filt(i,:),N);
    tdelta=fminbnd(@(tdelta) -abs(circdelay_local(r,tdelta,N+1)), ...
        -0.5, 0.5,optimset('TolX',1e-12));
    cut_data(i,:) = circdelay_local(cut_data(i,:),-tdelta);
    fprintf(['Signal ' num2str(i) ' relative to 1 was started \n \t' ...
            num2str((intDelay(i)+tdelta)/sampleRate) ...
            ' seconds late. \n'])
    % If plotSteps, plot the crosscorrelation after alignment:
    if plotSteps
        clf;
        % Do the subsample aligment to down_sig_filt
        cut_down_sig_filt(i,:) = ...
            circdelay_local(cut_down_sig_filt(i,:),-tdelta);
        r = xcorr(cut_down_sig_filt(1,:),cut_down_sig_filt(i,:));
        [~,maxind]=max(r);
        t = linspace(-length(r)/sampleRate/2,...
            length(r)/sampleRate/2,length(r));
        plot(t,abs(r)/abs(r(maxind)),'b.')
        hold on;
        plot(t(maxind),1,'ro')
        hold off;
        title('Cross correlation after alignment')
        pause(1)
        if i == 2
            save('postAlignCross.mat','r','t')
        end
    end
end
sig.data = cut_data;
[m,n] = size( sig.data); % Updated size of data
fprintf(['\n Done with time alignment! \n'...
    'Starting filtering of final signal! \n\n'])


% Filter out the syncsignal and leave only the rest of the signal
% Time vector:
t=(0:(n-1))/sampleRate;
% Frequency shift the aligned signal:
down_sig = sig.data.*lo(syncFrequency-centerFrequency,t);
down_sig_filt = down_sig;
% Filter:
HPF=fir1(256,syncBandwidth/2/(sampleRate/2),'high');
for i = 1:m
    down_sig_filt(i,:) = filtfilt(HPF,1,down_sig(i,:));
    % If plotSteps, results are plotted to make sure everything is working
    % fine:
    if plotSteps
        sig_filt = down_sig_filt(i,:)./lo(syncFrequency-centerFrequency,t);
        clf;
        subplot(3,1,1)
        freq = linspace(-sampleRate/2,sampleRate/2,...
            length(sig.data));
        plot(freq,abs(fftshift(fft(down_sig(i,:)))))
        title('Frequency shifted spectrum')
        subplot(3,1,2)
        plot(freq,abs(fftshift(fft(down_sig_filt(i,:)))))
        title('Filtered frequency shifted spectrum')
        subplot(3,1,3)
        plot(freq,abs(fftshift(fft(sig_filt))))
        title('Filtered inverse frequency shifted spectrum')
        pause(1);
    end 
end
clf;
fprintf('Done with filtering, function syncSignals is finished! \n\n')


sig.data = down_sig_filt./lo(syncFrequency-centerFrequency,t);

function lo = lo(f,t)
    % Create a local oscillator for frequency shifting with frequency shift
    % f and time vector t. 
    lo = exp(1i*2*pi*-f.*t);
    
function x2=circdelay_local(x,delay,N) 
% time shifting by a linear phase addition in the spectral domain.
% Parameter N is only used in the optimization, otherwise unnessesary
%
% Courtesy of Professor Thomas Eriksson, Chalmers University of Technology

x2=ifft(ifftshift(fftshift(fft(x)).*exp(1i*2*pi*delay*(-length(x)/2:length(x)/2-1)/length(x))));
if nargin>2
    x2=x2(N); % this is just for the optimization fminbnd
end
