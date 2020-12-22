function    v = e48(decade)
%
%    v = e48(decade)
%

v = [100  121  147  178  215  261  316  383  464  562  681  825 ...
     105  127  154  187  226  274  332  402  487  590  715  866 ...
     110  133  162  196  237  287  348  422  511  619  750  909 ...
     115  140  169  205  249  301  365  442  536  649  787  953] ;

v = sort(v)/100 ;
if nargin>=1,
   v = v*10^decade ;
end
