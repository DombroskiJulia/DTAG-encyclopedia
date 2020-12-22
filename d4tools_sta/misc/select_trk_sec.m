function [st,et] = select_trk_sec(fh2,m)

%UNTITLED3 allows you to choose sections of a gps track and recieve start
%and end points of the track to allow you to choose corresponding sensor
%data.
%   fig= name of plot

xaxlim=get(gca,'Xlim'); % Get xaxis limits
yaxlim=get(gca,'Ylim'); % Get y axis limits
[px,py,key]=zoombox(fh2,xaxlim,yaxlim); % Zoom to selected ARS

xid=m(:,3)>=min(px) & m(:,3)<=max(px); % Find sections of track within the x limits of ARS box
trk1=m(xid,:); % Select sections of original dataset within x limits of ARS box into a new dataset trk1
yid=trk1(:,2)>=min(py) & trk1(:,2)<=max(py);  % Find section of trk1 within y limits of ARS box
trk2=trk1(yid,:); %Select sections of trk1 within y limits of ARS box into new dataset trk1
st=min(trk2(:,1)); et=max(trk2(:,1)); % Find start and end times of selected ARS track

hold(gca,'on') % Plot slected track for confirmation
plot(trk2(:,3),trk2(:,2),'g+');


end

