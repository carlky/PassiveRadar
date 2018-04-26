%%
%Ex program:

%...get data
%-----------------------------------------------------------
d2 = 3*lambda/2; %Distance between the two antenna arrays
c =  2.99792458e8;
L = 100; %Distance between transmitter and antenna array (meters)...
ang = 90*(pi/180); %We need to know the angle to the transmitter
tmtFound = 0; %boolean (0=false,1=true), determines if the information 
%should be plotted later on.
%-----------------------------------------------------------

%Begin for-loop (for filtering angles)
%Beamforming, get directions
[pks,directions] = beamforming(sig,d2);
angles = directions;
vinklar = directions.*(180/pi);

%Code to determine if angles are consistent with an acual target location
%over time.

%end for-loop (filtering)
%-----------------------------------------------------------
%Now we need to know the the angle to the transmitter; this is ang and was
%defined earlier.
%Compare this angle to the angles determined by the beamformer, directions.
%Pick out the most resembling, or if no one is close, reject.

%reset
%Temporary holder of potential measured directions to transmmitter
angTmtArray = zeros(1,length(directions)); %Tmt stands for transmitter
%To hold measured direction to transmitter
angTmt = 0; 
%5 degrees tolerance to count measured direction as relevant
tol = 5*(pi/180); 
%Average peak corresponding to directions
avg = mean(pks); %(3/5)*(max(pks)-min(pks))/2
%Determine potential measured directions to transmitter
for i=1:length(directions)
    if directions(i)>(ang-tol) && directions(i)<(ang+tol) && pks(i)>avg
       angTmtArray(1,i) = directions(i);
    end
end
%If norm(angTmtArray)=0 (no angles within our tolerance), then no direction was found, so we should not
%continue from here on.
if norm(angTmtArray)==0 %Transmitter was not found
    tmtFound = 0;
else %Transmitter was found
    tmtFound = 1;
    %Remove zeros from angTmtArray:
    angTmtArray(angTmtArray==0) = []; %these are the potential angles to the transmitter
    %Choose the angle that is closest to ang:
    for i=1:length(angTmtArray)
        temp = abs(ang-angTmtArray(i));
        if temp<abs(angTmt-ang)
            angTmt = angTmtArray(i);
        end
    end
    %In the fomula for determining the distances to targets, it's assumed
    %that the transmitter lies at theta=90 degrees. This should be
    %compensated for:
    
    %Locate the corresponding position, index, in the directions array:
    angTmtLoc = find(directions==angTmt);
end


%-----------------------------------------------------------
%angles determined!
%Time to use the zero-forcer!
if tmtFound==1 %Then we use ZF, cross-correlation, find the directions to 
    %targets and plot the results!
    y=zeroForcer(sig,directions,d2);
    Fs = 2.0985e6;%Sample frequency (number of samples per second)

    tmtSig = y(angTmtLoc,:); %Pick out the transmitter signal.
    y(angTmtLoc,:)=[]; %remove transmitter signal from y-vector, the y-vector
    %now only holds target signals.
    directions(directions==angTmt)=[]; % remove transmitter direction
    %Transmitter direction is known in variable angTmt.

    %Find timedelays from all target signals compared to transmitter signal,
    %and determine the range and corresponding angles to the targets
    Rrx = zeros(1,length(directions)); %Distances to targets, not transmitter...
    for i=1:length(directions)
        [acorr,lag] = xcorr(tmtSig,y(i,:));
        [~,I] = max(abs(acorr));
        lagDiff = lag(I);
        timeDiff = lagDiff/Fs;
        RRR = c*abs(timeDiff)+L;
        Rrx(i) = (RRR^2-L^2)/(2*(RRR-L*sin(directions(i))));
    end
    %Now we need to plot all radius distances to targets, Rrx to corresponding
    %angles.
    hold on
    for i=1:length(directions)
        polarplot(directions(i),Rrx(i),'o')
    end
    hold off
end