%%
clc, clear, clf
%Simulation
f = 626e6; 
c =  2.99792458e8; %light speed m/s
lambda = c/f;
d1 = lambda/2;
d2 = 3*lambda/2;

%--------------------------------------------------------------------------

%Below: generate signals from target sites and calculate the received
%signals. Later: to see if beamforming produces correct angles to targets
%and to see if the zero-forcing method can recover originally transmitted
%signals.

%ATM targets at angles 30, 90 and 120 degrees
%tx = 10.*[sqrt(3) 1; 0.2589 0.9659; -0.2589 0.9659; -sqrt(3) 1]; %30, 75, 105, 150 degrees
%tx = 100.*[sqrt(3) 1; 0.2589 0.9659; 0 2; -0.2589 0.9659]; %30, 75, 90, 105
%tx = 100.*[sqrt(3) 1; 1 1; 0.2589 0.9659; 0 2]; %30, 45, 75, 90 degrees
%tx = 100.*[sqrt(3) 1; 0 2; 1 sqrt(3)]; %30, 60, 90 degrees
%tx = 100.*[sqrt(3) 1; 0 2; -1 sqrt(3)]; %30, 60, 120 degrees
%tx = 100.*[sqrt(3) 1; 1 sqrt(3)]; %30,60 degrees
tx = 500.*[0 2;sqrt(3) 1]; %30,90 degrees
%tx = 100.*[ sqrt(3) 1;1 1]; %30, 45 degrees

%tx = 100.*[0.2589 0.9659; 0 2]; %75,90 degrees
%tx = 100.*[0.34202 0.939693; 0 2]; %70,90 degree
%tx = 100.*[0.422618 0.906308; 0 2]; %65,90 degrees
%tx = 100.*[0.5 0.866025; 0 2]; %60,90 degrees
%tx = 100.*[0.5 0.866025; 0 2]; %50,90 degrees
%tx = 500.*[1 1; 0 2]; %45,90 degrees
%tx = 100.*[sqrt(3) 1; 0 2]; %30,90 degrees

%tx = 100.*[sqrt(3) 1;-1 1]; %30,135 degrees
%tx = 100.*[0.2589 0.9659]; %75 degrees
%tx = 100.*[sqrt(3) 1]; %30 degrees
mx = [0 0; -d1 0; -2*d1 0; -3*d1 0; -d2-3*d1 0; -d2-4*d1 0; -d2-5*d1 0; -d2-6*d1 0];
%mx = [d2/2+3*d1 0; d2/2+2*d1 0; d2/2+d1 0; d2/2 0;-d2/2 0; -d2/2-d1 0; -d2/2-2*d1 0; -d2/2-3*d1 0]; %8 receivers

%To hold distances from targets to receivers
Rx = zeros(size(mx,1),size(tx,1));
%Calculate all distances from each target to each receiver
for i=1:size(mx,1) %For every receiver
   for j=1:size(tx,1) %For every transmitter
      Rx(i,j) = norm(tx(j,:)-mx(i,:));
   end
end

%Signals generated at target locations:
n = 200;%length of transmitted signal/number of samples
fff = 2.0985e6; %sample frequency
S = zeros(size(tx,1),n);
Sref = exp(1j*2*pi*f*rand(1,10*n)); %this is for a fraction of a second
dt = 1/fff; %time between each samples.
%Let's say that signal one is the source, and signal two is a reflection:
for i=1:size(tx,1)
    dr = norm(tx(i,:)-tx(1,:)); %length between source and target.
    dr/(c*dt)
    ddtt = round(dr/(c*dt)); %number of samples for signal from source to travel to target.
    S(i,:) = Sref(ddtt+1:n+ddtt);
end

%Signals reaching the receiver sites:
x = zeros(size(mx,1),n); %Total signal reaching the different receivers
gamma = 0; %attenuation constant, weakening of the signals
 for i=1:size(mx,1) %For every receiver
     for j=1:size(tx,1) %For every transmitter
        x(i,:) =  x(i,:)+S(j,:).*exp(Rx(i,j)*(1j*(2*pi*f/c)-gamma));
     end
 end

%--------------------------------------------------------------------------

sig.data = [x(1,:);x(2,:);x(3,:);x(4,:);x(5,:);x(6,:);x(7,:);x(8,:)];
sig.centerFrequency = 626e6;

%info = beamforming(sig,d2);
[pks,directions] = beamforming(sig,d2);
angles = directions
vinklar = directions.*(180/pi)

%A measure of how good the plane wave approximation is:
%((2*pi/lambda)*d1*cos(30*(pi/180))-(2*pi/lambda)*(Rx(2,1)-Rx(1,1)))*(180/pi)
%((2*pi/lambda)*(6*d1+d2)*cos(30*(pi/180))-(2*pi/lambda)*(Rx(8,1)-Rx(1,1)))*(180/pi)

%%
%xcorr
y=zeroForcer(sig,directions,d2);
Fs = 2.0985e6;%Sample frequency (number of samples per second) 
ss1 = y(1,:); %Relative to a time frame of 1s
ss2 = y(2,:); %Relative to a time frame of 1s
[acorr,lag] = xcorr(ss1,ss2);
[~,I] = max(abs(acorr));
lagDiff = lag(I)
timeDiff = lagDiff/Fs;
L = Rx(1,2);
RRR = c*abs(timeDiff)+L;
phi = angles(1); %Angle to the desired target
Rrx = (RRR^2-L^2)/(2*(RRR-L*sin(phi)))
ActualDistance = norm(tx(1,:)-mx(1,:))

plot(lag,abs(acorr))
%title('acorr-lag')
