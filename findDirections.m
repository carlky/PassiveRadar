function [pks,directions] = findDirections(sig,plotSteps)
%findDirections: Scanning the incoming signals in directions theta=0->2pi
%in order to find angles (directions) to potential targets, these includes
%angles to stationary targets. The problem is set up so that by maximizing
%the function M(theta), the angles are found. It's assumed that the
%incoming signals has a frequency of f=626 Hz. The function also returns
%the corresponding amplitudes (pks) to the detected angles (directions).

%sig is a struct with the following fields:
%centerFrequency [Hz]
%sampleRate [Hz]
%data, IQ-signal matrix, size [m x n], received data from m SDR's, and
%n is the number of data points reccorded from each SDR.

c = 3e8; %speed of light, [m/s]

%distance between antennas in meters:
%These values needs to be substituted by the ones we will actually use.
lambda = c/sig.centerFrequency; %in meters.
d1 = lambda/2; %d1 is the distance between antenna 1,2,3,4 respectively (or 5,6,7,8).
d2 = lambda/2; %d2 is the distance between the antenna array [1,2,3,4] and [5,6,7,8].

%g is the sum of the phase shifted signals from antennas 2 through 8 as compared to
%the received signal from antenna 1. Currently the array of antenna
%elements are assumed to be positioned accordingly: [4 3 2 1; 8 7 6 5].
%[1 2 3 4; 5 6 7 8]
g =@(theta) sig.data(3,:).*exp(-1j*2*pi*sig.centerFrequency*d1.*cos(theta)./c)+...
    sig.data(2,:).*exp(-1j*2*pi*sig.centerFrequency*2*d1*cos(theta)/c)+...
    sig.data(1,:).*exp(-1j*2*pi*sig.centerFrequency*3*d1*cos(theta)/c)+...
    sig.data(8,:).*exp(-1j*2*pi*sig.centerFrequency*d2*sin(theta)/c)+...
    sig.data(7,:).*exp(-1j*2*pi*sig.centerFrequency*(d1*cos(theta)+d2*sin(theta))/c)+...
    sig.data(6,:).*exp(-1j*2*pi*sig.centerFrequency*(2*d1*cos(theta)+d2*sin(theta))/c)+...
    sig.data(5,:).*exp(-1j*2*pi*sig.centerFrequency*(3*d1*cos(theta)+d2*sin(theta))/c);

%Setting up search parameters, scanning in directions theta=0 to
%theta=2*pi, theta=0 is in the direction of the 'x-axis', i.e. to the right
%of antenna elements 1 and 5.
n=200; %number of angles to search for, this can be changed (angular resolution)
theta_i = 0; %radians
theta_f = 2*pi; %radians
theta = linspace(theta_i,theta_f,n);

%Calculate M that is to be maximized, for further details consult the 
%beamforming section in the report.
M = zeros(1,length(theta));
for i=1:length(theta)
M(i) = real(sum(conj(sig.data(4,:)).*g(theta(i))));
end

%Plotting the function to maxzimize, M, versus the corresponding angles.
%This part should be removed in the final design, but it's instructive for
%illustrative purposes when testing the findDirections function.

% Default for plotSteps is false, unless an argument is provided
if ~exist('plotSteps','var')
    plotSteps = false;
end

if plotSteps
    findpeaks(M,theta,'threshold',0);
    title('maximize M')
    xlabel('\theta (radians)')
    ylabel('M(\theta) in V^2')
end

%Find peak values of M (pks), these corresponds to potential angles to
%targets (these includes static targets as well), the value in the findpeaks function 
%corresponding to 'threshold' filters out some unwanted signals, this can
%be changed...
[pks,directions] = findpeaks(M,theta,'threshold',0); 



