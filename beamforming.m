function [pks,directions] = beamforming(sig,dd)
%findDirections: Scanning the incoming signals in directions theta=0->pi
%in order to find angles (directions) to potential targets, these includes
%angles to stationary targets. The problem is set up so that by maximizing
%the function M(theta), the angles are found. It's assumed that the
%incoming signals has a frequency of f=626 Hz. The function also returns
%the corresponding amplitudes (pks) of the detected angles (directions)
%corresponding to M(theta).

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
%dd = 3*lambda/2; %distance between the two antenna arrays, the gap.

%------------------------------------------------------------------
%Below: Beamforming:

%g is the sum of the phase shifted signals from antennas 2 through 8 as compared to
%the received signal from antenna 1. Currently the array of antenna
%elements are assumed to be positioned accordingly: [4 3 2 1] [8 7 6 5].
%[1 2 3 4; 5 6 7 8]
g =@(theta) sig.data(2,:).*exp(-1j*2*pi*sig.centerFrequency*d*cos(theta)/c)+...
    sig.data(3,:).*exp(-1j*2*pi*sig.centerFrequency*2*d*cos(theta)/c)+...
    sig.data(4,:).*exp(-1j*2*pi*sig.centerFrequency*3*d*cos(theta)/c)+...
    sig.data(5,:).*exp(-1j*2*pi*sig.centerFrequency*(3*d+dd)*cos(theta)/c)+...
    sig.data(6,:).*exp(-1j*2*pi*sig.centerFrequency*(4*d+dd)*cos(theta)/c)+...
    sig.data(7,:).*exp(-1j*2*pi*sig.centerFrequency*(5*d+dd)*cos(theta)/c)+...
    sig.data(8,:).*exp(-1j*2*pi*sig.centerFrequency*(6*d+dd)*cos(theta)/c);

%Setting up search parameters, scanning in directions theta=0 to
%theta=2*pi, theta=0 is in the direction of the 'x-axis', i.e. to the right
%of antenna elements 1 and 5.
n=200; %number of angles to search for, this can be changed (angular resolution)
theta_i = 0; %radians
theta_f = pi; %radians
theta = linspace(theta_i,theta_f,n);

%Calculate M that is to be maximized, for further details consult the 
%beamforming section in the report.
M = zeros(1,length(theta));
for i=1:length(theta)
M(i) = real(sum(conj(sig.data(1,:)).*g(theta(i))));
end

avg = (3/5)*(max(M)-min(M))/2;

%Plotting the function to maxzimize, M, versus the corresponding angles.
%This part should be removed in the final design, but it's instructive for
%illustrative purposes when testing the findDirections function.

findpeaks(M,theta,'MinPeakHeight',avg);
title('maximize M')
xlabel('\theta (radians)')
ylabel('M(\theta) in V^2')


%Find peak values of M (pks), these corresponds to potential angles to
%targets (these includes static targets as well), the value in the findpeaks function 
%corresponding to 'threshold' filters out some unwanted signals, this can
%be changed...
[pks,directions] = findpeaks(M,theta,'MinPeakHeight',avg); 

%ToDo: Define a 'pseudo-filter' to remove some noise angles that are bound
%to arise when using findpeaks. Use: 'MinPeakDistance', 'MinPeakHeight' or 'Threshold', 
%presumably the former two are preferable. 

