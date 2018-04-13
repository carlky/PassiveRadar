function sendSyncSignal(centerFrequency,duration)

% Find connected radios
connectedRadios = findsdru;
if strncmp(connectedRadios(1).Status, 'Success', 7)
  if strncmp(connectedRadios(1).Platform,'N200/N210/USRP2')
      address = connectedRadios(1).IPAddress;
      platform = 'N200/N210/USRP2';
  else
      error('USRP platform not N200/N210/USRP2. This is not supported!');
  end
else
  error('No radio connected!')
end

% Create radio object
radio = comm.SDRuTransmitter('Platform', platform, ...
        'IPAddress', address, ...
        'CenterFrequency', centerFrequency,...
        'Gain', 15, ...
        'InterpolationFactor', 400);

disp('Found radio');
disp(radio);        
radioInfo = info(radio);

playCount = ceil(72.4695/duration + 0.5);

% Create audio source 
audio = dsp.AudioFileReader('RockGuitar-16-44p1-stereo-72secs.wav',...
    'SamplesPerFrame',4410,...
    'PlayCount',playCount);

% Create fm modulator
fmbMod = comm.FMBroadcastModulator('AudioSampleRate',audio.SampleRate, ...
    'SampleRate',radioInfo.BasebandSampleRate);

% Send audio untill done
while ~isDone(audio)
    audioData = audio();
    modData = fmbMod(audioData);
    radio(modData);
end

release(radio);
release(fmbMod);