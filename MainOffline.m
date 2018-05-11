%% Import
clear all
clc
dirName='Reading Helikopter';
centerFrequency=626e6;
sampleRate=2e6;
syncFrequency = 625.3e6;
syncBandwidth = 0.75e6;

sampleLength=10e6; 
      
%If sample frequency is 2MHz, there will be 4 Mrows/s in the data files,
%captX.cfile. The function newDataOffline will give one second of data if
%sampleLength=2e6.

l=0;
save('readLines.mat','l');
%The variable l contains the information about the amount of lines that has
%been read in the data files.
s = dir(['Data/',dirName,'/capt1.cfile']);

fileLength=s.bytes;

tic
%while l<=fileLength-sampleLength*2
    sig = newDataOffline(centerFrequency, sampleRate, dirName, sampleLength);
toc 
sig.data = sig.data - mean(sig.data,2);
%%
tic
    sig_new = syncSignals(sig, syncFrequency,syncBandwidth,true);
toc
%%
tic
     [pks,direction] = beamforming(sig_new,0.302);
toc
%     sig_isolated = isolateDirections(sig,direction);
%     t_delay = findDelay(sig_1,sig_2);
%     plotData(direction, t_delay, fig);
    %load readLines.mat l;
%end

beep
%% Power calculation of all of the different SDRs
tic
effek1 = bandpower(sig.data(1,:));
for i = 1:8
    subplot(4,2,i)
    fftData = fft(sig.data(i,:));
    freq = linspace(-1e6,1e6,length(fftData));
    plot(freq,abs(fftshift( fftData)))
    title(num2str(bandpower(sig.data(i,:))/effek1))
    toc
end

%% Display spectrum of SDR 5

fftData = fftshift(fft(sig.data(5,:)));
freq = linspace(-1e6,1e6,length(fftData));

figure('units','points','position',[0 0 1000 600])
plot(freq/1e6,abs(fftData)/max(abs(fftData)),'b')
hold on;
x_rec =[-1,-1,-0.4,-0.4];
y_rec =[0,1.1,1.1,0];
p = patch(x_rec,y_rec,'m');
set(p,'FaceAlpha',0.2,'Linestyle','--')
x_rec =[-0.4,-0.4,1,1];
y_rec =[0,0.2,0.2,0];
p = patch(x_rec,y_rec,'c');
set(p,'FaceAlpha',0.2,'Linestyle','-')
hold off;
set(gca,'TickLabelInterpreter','latex','Fontsize',16)
legend({'Spektrum f\"{o}r Mottagare 5','Synkroniseringssignal','DVB-T signal'},...
    'interpreter','latex','fontsize',16)
title({'Spektrum f\"{o}r Mottagare 5'},'interpreter','latex','fontsize',22)
xlabel('Frekvens $f$ [MHz]','interpreter','latex','fontsize',18)
ylabel({'Normerad intensitet'},'interpreter','latex','fontsize',18)
xticks(linspace(-1,1,11))
yticks(linspace(0,1,11))

%% Display Crosscorr between 2 and 1
pre = load('preAlignCross.mat');

figure('units','pixels','position',[75 0 500 600])
[~,maxind] = max(pre.r);
plot(pre.t*1e3,abs(pre.r)/abs(pre.r(maxind)),'b')
hold on;
plot(pre.t(maxind)*1e3,1,'mo')
hold off;
set(gca,'TickLabelInterpreter','latex','Fontsize',16)
title({'Korskorrelation f\"{o}r signal 2 relativt 1','innan synkronisering'}...
    ,'interpreter','latex','fontsize',22)
legend({'Korskorrelation','Max-v\"{a}rde'},...
    'interpreter','latex','fontsize',16,'location','northwest')
xlabel('F\"{o}rskjutning $\tau$ [ms]','interpreter','latex','fontsize',18)
ylabel({'Normerad intensitet'},'interpreter','latex','fontsize',18)
xticks(linspace(-10,10,11))
yticks(linspace(0,1,11))
axis([-10,10,0,1.05])

post = load('postAlignCross.mat');

figure('units','pixels','position',[575 0 500 600])
[~,maxind] = max(post.r);
plot(post.t*1e6,abs(post.r)/abs(post.r(maxind)),'b')
hold on;
plot(post.t(maxind)*1e6,1,'mo')
hold off;
set(gca,'TickLabelInterpreter','latex','Fontsize',16)
title({'Korskorrelation f\"{o}r signal 2 relativt 1','efter synkronisering'}...
    ,'interpreter','latex','fontsize',22)
legend({'Korskorrelation','Max-v\"{a}rde'},...
    'interpreter','latex','fontsize',16,'location','northeast')
xlabel(['F\"{o}rskjutning $\tau$ [$\mu$s]'],...
    'interpreter','latex','fontsize',18)
ylabel({'Normerad intensitet'},'interpreter','latex','fontsize',18)
xticks(linspace(-50,50,11))
yticks(linspace(0,1,11))
axis([-50,50,0,1.05])