function    [CFG,fb,dtype] = getsensorcfg(xml)
%
%    [CFG,fb,dtype] = getsensorcfg(xml)
%

dtype = [] ;
if isfield(xml,'DGEN'),
   if strncmp(xml.DGEN,'D4',2)==1
      dtype = 4 ;
   else
      dtype = 3 ;
   end
end

if isempty(dtype) || dtype==3,
   [CFG,fb] = check_d3cfg(xml.CFG) ;
   if ~isempty(CFG),
      dtype = 3 ;
   end
end

if isempty(dtype) || dtype==4,
   [CFG,fb] = check_d4cfg(xml.CFG) ;
   dtype = 4 ;
end
return

function    [CFG,fb] = check_d3cfg(xmlcfg)
%
%    [CFG,fb] = check_d3cfg(d3)
%
CFG = [] ; fb = 0 ;
for k=1:length(xmlcfg),
   c = xmlcfg{k} ;
   if isfield(c(1),'PROC') && strncmp(c(1).PROC,'SENSOR',6)
      CFG = c(1) ;
      % find the sensor sampling rate
      switch CFG.MCLK.UNITS,
         case  'MHz'
            mf = 1e6 ;
         case  'kHz'
            mf = 1e3 ;
         case  'Hz'
            mf = 1 ;
         otherwise
            fprintf('Unknown unit in MCLK field "%s"\n',CFG.MCLK.UNITS) ;
            return
      end
      mclk = str2num(CFG.MCLK.MCLK)*mf ;
      fb = mclk/str2num(CFG.CLKDIV)/str2num(CFG.CHANS.N) ;
      break ;
   end
end
return

function [CFG,fb] = check_d4cfg(xmlcfg)
%
%  function [CFG,fb] = check_d4cfg(d3.CFG)
%
CFG = [] ; fb = 0 ;
for k=1:length(xmlcfg),
   c = xmlcfg{k} ;
   if isfield(c(1),'PROC') && (strncmp(c(1).PROC,'SENS',4) || strncmp(c(1).PROC,'ACC',3))
      CFG = c(1) ;
      sid = CFG.ID ;
      fb = str2num(CFG.FS.FS) ;      % find the sensor sampling rate
      break ;
   end
end

if isempty(CFG),
   return
end

% check for a decimator - need to do this because the channel assignments
% change
for k=1:length(xmlcfg),
   c = xmlcfg{k} ;
   if isfield(c(1),'PROC') && strncmp(c(1).PROC,'SDEC',4) && strncmp(c(1).SRC.ID,sid,length(sid))
      CFG.CHANS.CHANS = c(1).CHANS.CHANS ;
      CFG.CHANS.N = c(1).CHANS.N ;
      break ;
   end
end
return
