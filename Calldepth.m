%%Getting call depth
%J. Dombroski 
%December 16, 2020

%Raven table must be in your path. If not, include the full address for the
%table. Make sure it is saved as txt and check which delimiter is being
%used. Change the function acordingly 
load_nc('mn19_175isens10.nc')
T = readtable('mn19_175i002_SGW_4jdcalls.txt', 'ReadVariableNames', 1,  'Delimiter', 'tab'); %read table 
%reading Raven table. Must make sure where begin time (in seconds) is on
%4th colunm;

callt=table2array(T(:,4));%get 4th column with call time in seconds
callT=round(callt); %rounding seconds to be able to get samples
fs=48% frequency sample of audio data 
FS=ones(1,length(callT))*fs; %allocating space for table 
callts=(round(callT.*FS')); %transforming time in seconds in time in samples 
pp=(1:length(P.data))'; %creating dummy x variable same length as P.data 
PR=[pp, P.data]; 
calld=PR(callT,2); %from pressure, get values in samples defined in callts  

%make plot 
plot(P.data)
hold
plot(callts,calld, 'ro')

%% plot different call types with diferent colours 

%first part must be ran for this one to work
%You have to standardize the call categories. Perhaps using a 2-letter code
%is a good idea. 
%in the example I used the 'Frequency' category just because it was easy

calltype=categorical(table2array(T(:,10))) %getting call types and making them categorical change colunm number acordingly to where category is 
CA=ismember(calltype, {'L'}) %from call types, getting the ones that are type 'L' %change if necessary
ts=callts(CA) %time in samples of the calls type ´L´ - x variable
calldtypeL=PR(ts,2); %presure values for calls type L - y variable 

CB=ismember(calltype, {'S'}) %from call types, getting the ones that are type 'S' %change if necessary
tss=callts(CB) %time in samples of the calls type ´S´ - x variable
calldtypeH=PR(tss,2); %presure values for calls type S - y variable 

%making plot
plot(P.data, 'k')
axis ij
hold
plot(ts, calldtypeL, 'bo')
plot(tss, calldtypeH, 'ro')


%%
%color code presure sensor
B = readtable('mn19_175i_Beh.txt', 'Delimiter', 'tab'); %read table 
behtst=table2array(B(:,4));
behtsen=table2array(B(:,5));

fs=10 %frequency sample for pressure data 
FSB=ones(1,length(behst))*fs; %allocating space for table 
behtype=categorical(table2array(B(:,3))) %transforming beh type in categorical variable 
summary(behtype)
BB=ismember(behtype, {'Bottom'})



