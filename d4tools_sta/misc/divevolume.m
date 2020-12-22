load('dives265c.mat')%%% output of finddives function. This will be a matrix named T
load('F:\hs16\metadata\hs16_265cprh.mat')% this is a prh file but you can just decimate your pressure data and use that
trk=load('F:\hs16\metadata\hs16_265ctrk.txt'); % don't worry about this
fs=5;

%%%% compute sample numbers for start and end time of dives and compute
%%%% index of dive shape.


for  ii=(1:length(T));
    
SampleStart=T(ii, 1)*fs;
 
SampleEnd=T(ii, 2)*fs;
 
T(ii, 7)=nansum(p(SampleStart:SampleEnd))/(max(p(SampleStart:SampleEnd))*(SampleEnd-SampleStart)); % the 7th column of matrix T will be your dive shape index. 
% I found that values greater than .7 were generally u-shaped
 
end
 %% don't worry about anything below here
%%plot colours on gps trk of dive index-popi fix, 
trk(:,4)=0; %%% make a 4th column of zeros
TT=[]; % create matrix TT



for ii=(1:length(T));
    
 
StartTime=T(ii, 1);
EndTime=T(ii, 2);
 
% GpsDiff=StartTime-tkr(:,1);
 TRK_index=find(trk(:,1)>=(StartTime-35) & trk(:,1)<=EndTime); % -100 as there is offset between 
 TT=[TT;TRK_index];

    if length(TRK_index>0)
    trk(TRK_index, 4)=(T(ii,7));
    end
 
end

trk(trk==0)=NaN;
subplot(2,2,[1 3])

long=trk(:,3);lat=trk(:,2);idx=trk(:,4);
ushaped=trk(:,4) >= 0.71;vshaped=trk(:,4) <= 0.71;

fh1=scatter(long(ushaped),lat(ushaped),idx(ushaped),'m');, grid;
hold on
fh2=scatter(long(vshaped),lat(vshaped),idx(vshaped),'b');, grid;
xlabel 'Longitude'; ylabel 'Latitude'; set(gca,'fontsize',15);
set(gca,'YLim',[54.2 55.2]);
set(gca,'XLim',[7.37 9.5]);
plot_google_map('MapType', 'roadmap','ShowLabels',1);

subplot(2,2,2)
p1=p(65650:68170);
p1=p1*2;
t=(1:length(p1))/60;
plot(t,p1),grid
set(gca,'YDir','reverse','fontsize',15);
set(gca,'YLim',[-5 30]);
set(gca,'XLim',[0 42]);

subplot(2,2,4)
p2=p(1285153:1306544);
p2=p2*2;
t=(1:length(p2))/60;
plot(t,p2),grid
set(gca,'YDir','reverse','fontsize',15);
set(gca,'XLim',[0 152]);
set(gca,'YLim',[-5 30]);
ylabel 'Depth (m)'
xlabel 'Time (m)'






