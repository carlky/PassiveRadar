function y = zeroForcer(sig,directions,dd)
%zeroForcer: solves x = Hy, where y are the received signals, x is the transmitted signals and
%H, the channel matrix, relates the two, and is determined by knowing the
%directions to the various targets. Directions are given by the beamforming
%function. dd is the distance between the two separated antenna arrays.

%sig is a struct with the following fields:
%centerFrequency [Hz]
%sampleRate [Hz]
%data, IQ-signal matrix, size [m x n], received data from m SDR's, and
%n is the number of data points reccorded from each SDR.

c = 2.99792458e8; %speed of light, [m/s]

%distance between antennas in meters:
%These values needs to be substituted by the ones we will actually use.
lambda = c/sig.centerFrequency; %in meters.
d = lambda/2; %distance between antenna elements.
%------------------------------------------------------------------
%Below: Zero-forcing:

%Calculating the channel matrix H:
m = length(directions); %number of target reflections/sources
H = ones(8,m);
   H(2,:) = exp(1j*2*pi*sig.centerFrequency*d*cos(directions)/c);
   H(3,:) = exp(1j*2*pi*sig.centerFrequency*2*d*cos(directions)/c);
   H(4,:) = exp(1j*2*pi*sig.centerFrequency*3*d*cos(directions)/c);
   H(5,:) = exp(1j*2*pi*sig.centerFrequency*(3*d+dd)*cos(directions)/c);
   H(6,:) = exp(1j*2*pi*sig.centerFrequency*(4*d+dd)*cos(directions)/c);
   H(7,:) = exp(1j*2*pi*sig.centerFrequency*(5*d+dd)*cos(directions)/c);
   H(8,:) = exp(1j*2*pi*sig.centerFrequency*(6*d+dd)*cos(directions)/c);

%calculate pseudo-inverse in order to solve
%y=Hx->x=((H^(H)*H)^(-1))*H^(H)*y:
%W = inv((H'*H))*H'; (Apparently this way is slower and less accurate than below)
%Calculate the signals, y, from each reflection:
y = pinv(H)*sig.data;%inv((H'*H))*H'*sig.data; %x=Hy
%info.z = inv((H'*H))*H'*sig.data;

