function    gpscol(T,POS,colby)

%   gpscol(T,POS,colby)
%   Colours GPS track by variables resulting from find_dives, such as
%   dive depth, dive length, dive shape index (note: dive shape index must be
%   calculated separetly by function dsi).
%   T = structure resulting from find_dives.
%   POS = GPS positions structure.
%   colby = variable to colour the track with. For example:
%     colby=T.max if you want the track to be coloured by the max depth of each dive. 
%     colby=T.dive_shape_index if you want the track coloured by dive shape.
%
for ii=1:length(T.start),
T.dive_length=T.end-T.start;
T.POS=NaN*zeros(length(T.start),2);
mT(:,ii) = (T.start(ii)+T.end(ii))/2 ;    % 'middle' time of each dive
end

for ii=1:length(T.start),           % for each dive...
   tdiff = abs(POS.data(:,1)-mT(ii)) ;    % get the time offset between the dive time and each gps point
   [min_tdiff,ti]=min(tdiff);       % pick the closest gps point
   if min_tdiff<1200,               % if it is less than 20 minutes away, allocate it to the dive
      T.POS(ii,:)=POS.data(ti,2:3);
   end
end

fig=col_line(T.POS(:,2),T.POS(:,1),colby);
set(fig,'LineWidth',3);
caxis([min(colby) max(colby)])
plot_google_map('MapType', 'hybrid','ShowLabels',1);
c=colorbar;
