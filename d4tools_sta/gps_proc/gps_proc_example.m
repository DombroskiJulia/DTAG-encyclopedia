% read in data example
[B,BH,H]=d3readbin('hs16_265c025.bin',[]);

% convert grab times into Matlab time
T = d3datevec([BH.rtime]) ;	% they are stored as Unix seconds + microseconds
T(:,6) = T(:,6) + 1e-6*[BH.mticks]' ;  % time of grab

% do the actual GPS processing
[P,SNR,DEL,DOP] = fast_fdoppX(B) ;	% do brute force satellite search

% assemble result structure
for k=1:size(P,1),
   Obs(k).sv = (1:32)' ;		% SV numbers
   Obs(k).snr = P(k,:)' ;		% snr of each SV
   Obs(k).del = DEL(k,:)' ;	% code delays (pseudo-range)
   Obs(k).dop = DOP(k,:)' ;	% dopplers (not actually used in the following processing)
   Obs(k).T = T(k,:) ;			% time (local clock) of the grab
end

% convert pseudo-ranges to positions
pos=[54.95 7.7];			% rough starting position for this data
[lat,lon,h,t,N] = gps_posns(Obs,pos,0) ;

% plot results
k=find(h>-100 & h<200 & N(:,4)<200);	% get rid of obviously bad ones
plot(lon(k),lat(k),'.-'),grid
