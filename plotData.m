% ************************************************************
% DESCRIPTION:  A function that plots the data as a pretty graph
%
% INPUT:        direction:  array with all angles to target         
%               t_delay:    array with time delay between antennas
%               fig:        figure handle
%
% OUTPUT:       Pretty figures
% WRITTEN BY:   Johan Karlsson and Oskar Lindblad 
% STATUS:       Finished
% ************************************************************
function plotData(direction, t_delay, fig)

        L = 1000*haversine('57 41 38N, 012 03 32E', '57 41 28N, 011 058 30E'); %Antalet meter mellan oss och Brudaremossen
        %Av n�gon anledning fungerar det inte att ha kommatecken i
        %funktionen haversine
        
        
        c = 3e8; %Ljusets hastighet
        
        
        R_rx = ((c.*t_delay(1,:)).^2 + 2*c.*t_delay(1,:)*L)./(2*c.*t_delay(1,:) + 2*L.*(1-sin(direction(1,:))));
        
        %save('R_rx.mat', 'R_rx');
        %save('direction.mat', 'direction');
        
%         S = load('plot.mat', 'R_rx', 'direction'); %Ska h�mta b�da variablerna och l�gga dem i en struct
%         R_rx = S.R_rx;
        %R_rx = load('R_rx.mat');
        %direction = load('direction.mat');
%         
%         direction = S.direction;

p = polarplot(direction,R_rx,'rx');
        p.Color = [1 0 0];
        p.Marker = 'o';
        p.MarkerSize = 5;
        pax = gca; % GetCurrentAxis
        pax.ThetaColor = [0.1 0.1 1];
        pax.RColor = [0 1 0];
        pax.LineWidth = 1.5;
        pax.GridColor = [0 .7 0];
        set(pax,'Color',[0.15 0.15 0.15]);
        title('DETECTED TARGETS')
        % pause(0.1)
        hold on % to keep many     
%         colorbar %Borde nog ligga utanf�r plotfunktionen s� att inte den beh�ver uppdateras hela tiden
%         
         clear R_rx direction
end
