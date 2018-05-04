function x2=circdelay_local(x,delay,N) 
% time shifting by a linear phase addition in the spectral domain.
% Parameter N is only used in the optimization, otherwise unnessesary
%
% Courtesy of Professor Thomas Eriksson, Chalmers University of Technology

x2=ifft(ifftshift(fftshift(fft(x)).*exp(1i*2*pi*delay*(-length(x)/2:length(x)/2-1)'/length(x))));
if nargin>2
    x2=x2(N); % this is just for the optimization fminbnd
end