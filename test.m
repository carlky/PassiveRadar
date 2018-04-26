centerFrequency = 626e6;
sampleRate = 2e6;
duration = 300;

startGather(centerFrequency,sampleRate,duration);
%%
dirname = organizeFiles();
%%

l=0;
save('readLines.mat','l');
tic
toc1 = toc;
while toc<duration+1
    while toc< toc1 +1 
        pause(0.01);
    end
    toc1 = toc;
    load('readLines.mat');
    sig = newDataOffline(centerFrequency,sampleRate,dirname,1e6);
    toc2 = toc;
    [m,n] = size(sig.data);
    fftData = fftshift(fft(sig.data,[],2),2);
    fftData(:,[n/2-1,n/2,n/2+1]) = 0;
    freq = -sampleRate/2:sampleRate/n:sampleRate*(1/2 - 1/n);
    for i=1:m
        subplot(3,3,i)
        plot(freq,abs(fftData(i,:)));
        [~,j] = max(abs(fftData(i,:)));
        hold on;
        title(['SDR ' num2str(i)]);
        plot(freq(j),abs(fftData(i,j)),'ro');
        hold off;
    end
    toc3 = toc;
    pause(0.01);
    clear sig;
    load('readLines.mat')
    disp(['newData took ' num2str(toc2-toc1) ...
        ' seconds. Plot fft took ' num2str(toc3-toc2) ...
        ' seconds. ' num2str(l/2) ' lines have been read.']);
    clear l;
end