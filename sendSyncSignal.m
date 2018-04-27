function sendSyncSignal(centerFrequency,duration)
% Function to connect to a USRP hooked up to your computer and broadcast a
% signal to synchronise from for at least duration seconds. The signal is
% broadcast at centerfrequency centerFrequency. The broadcast signal is an 
% FM-modulated song that is 72 seconds long.
% Currently the function only supports USRPs of the type N200/N210/USRP2,
% but it should be fairly simple to change this, google MATLAB USRP
% communication and have a look. 
%
% If you want to read the data from an SDR or some other USRP, this
% function could be run via a system call form MATLAB, for example:
% 


% Find connected USRP radios of the type N200/N210/USRP2. Select the first
% one. It is recomended that you only connect one radio. If you have
% multiple radios connected and want to specifiy which one, this has to be
% modified.
connectedRadios = findsdru;
if strncmp(connectedRadios(1).Status, 'Success', 7)
  if strcmp(connectedRadios(1).Platform,'N200/N210/USRP2')
      address = connectedRadios(1).IPAddress;
      platform = 'N200/N210/USRP2';
  else
      error('USRP platform not N200/N210/USRP2. This is not supported!');
  end
else
  error('No radio connected!')
end

% Create a transmitterobject that the FM modulated signal can be sent to. 
radio = comm.SDRuTransmitter('Platform', platform, ...
        'IPAddress', address, ...
        'CenterFrequency', centerFrequency,...
        'Gain', 30, ...
        'InterpolationFactor', 400);

disp('Found radio');

% Get info about the radio. More specifically, we're interested in the
% BasebandSampleRate; the sample rate which the USRP expects data at. 
radioInfo = info(radio);

% Calculate how many times the signal should be repeated, rounding the
% number up significantly. 
playCount = ceil(duration/72.4695 + 0.5);

% Create an audio source and reference the audiofile that you want to read.
% MATLAB comes preloaded with a few audiofiles, more can be had with the
% Audio system toolbox. One that is included in that toolbox is 
% RockGuitar-16-44p1-stereo-72secs.wav. The dsp.AudioFileReader will play
% the audio playCount times. 
audio = dsp.AudioFileReader('RockGuitar-16-44p1-stereo-72secs.wav',...
    'SamplesPerFrame',4410,...
    'PlayCount',playCount);

% Create a comm.FMBroadcastModulator object to encode the audio signal into 
% an FM signal at samplerate radioInfo.BasebandSampleRate. 
fmbMod = comm.FMBroadcastModulator('AudioSampleRate',audio.SampleRate, ...
    'SampleRate',radioInfo.BasebandSampleRate,...
    'Stereo',true);

% Get at piece of audio data, modulate it into an FM-signal and send it out
% to the USRP device. 

disp(['Starting transmission! Planning on transmitting for ' ...
    num2str(playCount*72.4695) ' seconds' ]);
tic
progress = 0.1;
progressStep = 0.1;
while ~isDone(audio)
    audioData = audio();
    modData = fmbMod(audioData);
    radio(modData);
    if toc/playCount/72.4695 > progress
        disp([num2str(progress*100) '% done. Took ' num2str(toc) ...
            ' seconds.']);
        progress = progress + progressStep;
    end
end
disp(['Transmission finished! Transmitted for ' num2str(toc)... 
    ' seconds']);

% Release the radio and fm modulator. 
release(radio);
release(fmbMod);