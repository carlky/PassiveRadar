% ************************************************************
% DESCRIPTION:  A function that plots the data as a pretty graph
%
% INPUT:        direction:  array with all angles to target         
%               t_delay:    array with time delay between antennas
%               fig:        figure handle
%
% OUTPUT:       Pretty figures
% WRITTEN BY:   Johan Karlsson and Oskar Lindblad 
% STATUS:       Not finished
% ************************************************************



function plotData(direction, t_delay, fig)

        L = 1000*haversine('57 41 38N, 012 03 32E', '57 41 28N, 011 058 30E') %Antalet meter mellan oss och Brudaremossen
        %Av någon anledning fungerar det inte att ha kommatecken i
        %funktionen haversine
        
        
        c = 3e8; %Ljusets hastighet
        
        
        R_rx = ((c.*t_delay(1,:)).^2 + 2*c.*t_delay(1,:)*L)./(2*c.*t_delay(1,:) + 2*L.*(1-sin(direction(1,:))));
        
        save('R_rx.mat', 'R_rx');
        save('direction.mat', 'direction');
        
%         S = load('plot.mat', 'R_rx', 'direction'); %Ska hämta båda variablerna och lägga dem i en struct
%         R_rx = S.R_rx;
        R_rx = load('R_rx.mat');
        direction = load('direction.mat');
%         
%         direction = S.direction;

     
%         polarplot(direction,R_rx,'rx')
%         hold on
%         colorbar %Borde nog ligga utanför plotfunktionen så att inte den behöver uppdateras hela tiden
%         
         clear R_rx direction
end
