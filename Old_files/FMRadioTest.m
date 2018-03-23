clc
f_sample = 1e6; %sample freq, 900e3 < f_sample <= 3200e3, do not increase above 2.6e6
f = [];
FFTData = [];

f_sweep = [88,108]*1e6;

for f_center = f_sweep(1):f_sample:f_sweep(2)
    data = sweep(f_center,...
        'SampleFrequency', f_sample,...
        'EnableTunerAGC',false,...
        'SamplesPerFrame',2^10,... %Min 2^8 max 2^18, needs to be power of 2
        'TunerGain',10,...
        'NumberOfSweeps',20);
    df = f_sample/length(data.Data);
    f = [f,(-f_sample/2:df:f_sample/2-df) + f_center];
    [y,i] = min(abs(-f_sample/2:df:f_sample/2-df));
    fftdata = fftshift(fft(data.Data)).';
    fftdata = [fftdata(1:i-1),mean(fftdata([i-1,i+1])),fftdata(i+1:length(fftdata))];
    FFTData = [FFTData,fftdata];
end

%%
spectra = abs(FFTData);
[~,index] = findpeaks(spectra,'MinPeakProminence',max(spectra)/150,...
    'MinPeakDistance',round(length(spectra)/70));
plot(f*1e-6,spectra);
hold on;
for i = index
    plot(f(i)*1e-6,spectra(i),'ro');
    text(f(i)*1e-6-0.5,spectra(i)+max(spectra)/30,num2str(round(f(i)*1e-6,1)));
end
hold off;
xlabel('Frekvens [MHz]');
title('spektra');