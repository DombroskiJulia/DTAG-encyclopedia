function    save_gps_test_set(OBS,fname,THR)
%
%    save_gps_test_set(OBS,fname,THR)
%

MAX_SV = 10 ;
MIN_SV = 5 ;
if nargin<3,
   THR = 150 ;
end
fid = fopen(fname,'wt');
for k=1:length(OBS),
   snr = 10.^(OBS(k).snr/10) ;
   [snr,I] = sort(snr,1,'descend') ;
   ksv = min(MAX_SV,find(snr>THR,1,'last')) ;
   if isempty(ksv) || ksv<MIN_SV, continue, end
   M = [OBS(k).sv(I(1:ksv)) OBS(k).del(I(1:ksv))] ;
   fprintf(fid,'%d,%d,%d,%d,%d,%2.3f,%d,',OBS(k).T,ksv);
   for kk=1:ksv-1,
      fprintf(fid,'%d,%4.2f,',M(kk,:));
   end
   fprintf(fid,'%d,%4.2f\n',M(ksv,:));
end
fclose(fid);
