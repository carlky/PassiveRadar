function [distance] = LatLong2distance(LatLong_1,LatLongt_2)
% ---------------------------------------------------------
% Distance between two points on a sphere
% LongLat = [Latitude, Longitude] [degree]
% Distance calculated using pythagoras since the distance along the line 
% through the points is wanted 
%
% If we should use the distance along the surface of a sphere the 
% Haversine distance must be used. 
% source: http://www.movable-type.co.uk/scripts/latlong.html
% ---------------------------------------------------------
radius=6371; 
lat1=LatLong_1(1)*pi/180; % Deg2rad
lat2=LatLong_2(1)*pi/180;
lon1=LatLong_1(2)*pi/180;
lon2=LatLong_2(2)*pi/180;
deltaLat=lat2-lat1;
deltaLon=lon2-lon1;

x=deltaLon*cos((lat1+lat2)/2);
y=deltaLat;
distance=radius*sqrt(x*x + y*y); %Pythagoran distance [km]

end

