function    A = battag_cal(X,tag,range)
%
%    A = battag_cal(X,tag,range)
%

CAL.Be02c_8g = [129.6585 -0.2414; 122.0517 -0.0914; 131.6103 -0.3742] ;
CAL.B5029_8g = [127.4075 -0.2383; 120.2901 -0.1874; 132.6318 -0.4181] ;
CAL.B5032_8g = [127.4753 -0.2334; 122.8537 -0.1449; 130.3666 -0.3610] ;
CAL.B2035_8g = [128.0764 -0.2632; 120.4663 -0.1882; 130.0629 -0.4095] ;
CAL.B5004_8g = [132.2893 -0.1905; 122.0779 -0.0494; 132.8052 -0.3318] ;
CAL.B5027_8g = [130.1514 -0.2343; 121.4176 -0.0899; 132.5413 -0.3711] ;

calname = sprintf('B%s_%dg',tag,range) ;
if ~isfield(CAL,calname),
   fprintf('No calibration for %s, +/-%dg available\n',tag,range);
   A = X ;
   return
end

C = getfield(CAL,calname) ;
onz = ones(size(X,1),1) ;
A = X.*(onz*C(:,1)')+(onz*C(:,2)') ;
return
