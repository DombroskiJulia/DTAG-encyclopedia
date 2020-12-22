function      [c,t,s,len,FS]=tagcue(cue,tag)
%
%      [c,t,s,len,FS]=tagcue(cue,tag)
%      Return cue information for a tag dataset:
%         tag  is the deployment name e.g., 'sw01_200'
%         cue is a 1 to 3 element vector interpreted as:
%             1-element: seconds since tag-on
%             2-element: data index in [chip,second]
%             3-element: time of day in [hour,min,sec]
%
%      Output arguments are:
%         c = [chip,audio-sample-in-chip,sensor-sample]
%         t = [year,month,day,hour,min,sec]
%         s = seconds since tag on
%			 len = [id,d,l,r]
%			 where d = data length in hours
%					 l = length of attachment in hours
%					 r = reason for release 0=unknown, 1=release,
%						  2=knock-off, 3=mechanical failure
%
%      Note: the output cue is rounded to the nearest block (0.3s
%      at 32kHz) before the input cue.
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: October 2002 -included bad blocks in chip-sample computation


switch tag
   case 'rw01_207'
 		id = 4 ;
		len = [5.5 -1 -1] ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ;
      tagon = [2001 7 25 20 14 0] ;
   case 'rw01_213a'
 		id = 5 ;
		len = [0.5 -1 -1] ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 1 12 57 21] ;
   case 'rw01_214'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 2 13 57 32] ;
   case 'rw01_216a'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 4 14 34 5] ;
   case 'rw01_216b'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; bl = 4096 ;
      tagon = [2001 8 4 18 29 51] ;
   case 'rw01_216c'
 		id = 6 ;
      st = [1,3000] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 4 20 7 17] ;
   case 'rw01_216d'
 		id = 6 ;
      st = [3,1] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 4 21 9 35] ;
   case 'rw01_220'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 8 21 39 18] ;
   case 'rw01_221'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 9 14 15 37] ;
   case 'rw01_227a'
  		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; bl = 2048 ;
      tagon = [2001 8 15 15 54 13] ;
   case 'rw01_227b'
  		id = 5 ;
      st = [2,1] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 15 17 43 13] ;
   case 'rw01_231a'
  		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 19 13 10 1] ;
   case 'rw01_231b'
 		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 19 16 31 48] ;
   case 'rw01_241'
  		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 29 15 7 57] ;
   case 'sw00_250'
  		id = 4 ;
      st = [1,32] ;  % starting chip and block
      fs = 16e3 ; bl = 1024 ;
      tagon = [2000 9 5 13 23 14] ;
   case 'sw01_199'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 17 17 42 34] ;
   case 'sw01_200'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 18 15 58 15] ;
   case 'sw01_203a'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 21 9 40 33] ;
   case 'sw01_203b'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 21 15 3 1] ;
   case 'sw01_204'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 22 14 18 14] ;
   case 'sw01_208a'
  		id = 6 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2001 7 26 9 5 41] ;
   case 'sw01_208b'
  		id = 6 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2001 7 26 16 42 40] ;
   case 'sw01_209a'
 		id = 6 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2001 7 27 8 55 24] ;
   case 'sw01_209c'
 		id = 6 ;
      st = [5 1] ;
      fs = 32e3 ; 
      tagon = [2001 7 27 13 58 48] ;
   case 'sw01_265'
  		id = 9 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2001 9 21 13 27 7] ;
   case 'sw01_275a'
 		id = 9 ;
      st = [1 1] ;
      fs = 32e3 ;
      tagon = [2001 10 1 10 9 30] ;
   case 'sw01_275b'
 		id = 9 ;
      st = [7 380] ;     % actual start was [2 1] at 10:30:14 on boat
      fs = 32e3 ;
      tagon = [2001 10 1 12 28 27] ;
   case 'pw02_091a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 4 1 12 59 19] ;
   case 'pw02_091b'
  		id = 8 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 4 1 13 45 10] ;
   case 'pw02_091c'
 		id = 10 ;
      st = [2 1] ;
      fs = 32e3 ;
      tagon = [2002 4 1 14 05 23] ;
   case 'sw02_189b'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 7 8 18 16 51] ;
   case 'sw02_191b'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 7 10 9 1 24] ;
   case 'sw02_235a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 8 23 10 16 32] ;
   case 'sw02_235b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 10 33 20] ;
   case 'sw02_235c'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 17 03 54] ;
   case 'sw02_236a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 24 17 18 41] ;
   case 'sw02_237a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 25 11 23 02] ;
   case 'sw02_237b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 25 12 13 22] ;
   case 'sw02_238a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 26 9 22 39] ;
   case 'sw02_238b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 26 16 23 45] ;
   case 'sw02_239a'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 27 10 40 4] ;
   case 'sw02_239b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 27 17 38 42] ;
   case 'sw02_240a'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 11 34 29] ;
   case 'sw02_240c'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 17 03 54] ;
   case 'sw02_248a'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 5 18 11 58] ;
   case 'sw02_249a'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 6 8 45 11] ;
   case 'sw02_253a'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 10 16 38 25] ;
   case 'sw02_254a'
 		id = 10 ;
      %st = [2 1540] ;   % corrupt data in chip 1 and early chip 2
		st = [2 1] ;
		oz = -522.58 ;		 % tag record second at start of offload
      fs = 32e3 ; 
      tagon = [2002 9 11 11 09 17.8] ; % corrected to end of corrupt data
   case 'sw02_254b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 11 10 28 41] ;
   case 'sw02_254c'
 		id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 11 10 34 05] ;
   case 'zc02_275a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 10 2 17 34 41] ;
   case 'pw03_074a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 64e3 ; 
      tagon = [2003 3 15 11 27 40] ;
   case 'pw03_076a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 64e3 ; 
      tagon = [2003 3 17 11 39 2] ;
   case 'pw03_076b'
 	  id = 13 ;
      st = [1 1] ;
      fs = 64e3 ; 
      tagon = [2003 3 17 11 41 37] ;
   case 'pw03_077a'
 	   id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2003 3 18 16 25 43] ;
   case 'pw03_077b'
 	   id = 13 ;
      st = [1 1] ;
      fs = 32e3 ; 
      tagon = [2003 3 18 16 39 8] ;
   case 'pw03_078a'
 	   id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2003 3 19 11 11 47] ;
   case 'pw03_078b'
 	   id = 13 ;
      st = [1 1] ;
      fs = 64e3 ; 
      tagon = [2003 3 19 16 33 38] ;
   case 'pw03_082a'
 	   id = 11 ;
      st = [1 4] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 4 6] ;
   case 'pw03_082b'
 	   id = 13 ;
      st = [2 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 0 16] ;
   case 'pw03_082c'
 	   id = 13 ;
      st = [3 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 37 21] ;
   case 'pw03_082d'
 	   id = 11 ;
      st = [2 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 42 29] ;
   case 'pw03_082e'
 	   id = 13 ;
      st = [9 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 13 03 41] ;
   case 'sw03_156a'
 	   id = 13 ;
      st = [1 1] ;
      fs = 32e3 ; 
      tagon = [2003 6 5 10 6 13] ;
   case 'sw03_162a'
 	   id = 204 ;
      st = [1 6] ;
      fs = 96e3 ; 
      tagon = [2003 6 11 17 26 11] ;
   case 'sw03_163a'
 	   id = 204 ;
      st = [1 6] ;
      fs = 96e3 ; 
      tagon = [2003 6 12 17 54 22] ;
   case 'sw03_164a'
 	   id = 202 ;
      st = [1 6] ;
      fs = 96e3 ; 
      tagon = [2003 6 13 9 47 46] ;
  
  otherwise
      fprintf('Unknown experiment - supported experiments are:\n') ;
      fprintf('  sw01_199  sw01_200  sw01_203a sw01_203b sw01_204\n') ;
      fprintf('  sw01_208a sw01_208b sw01_209a sw01_209b sw01_265\n') ;
      fprintf('  sw01_275a sw01_275b rw01_207  rw01_213a rw01_214\n') ;
      fprintf('  rw01_216a rw01_216b rw01_216c rw01_216d rw01_220\n') ;
      fprintf('  rw01_221  rw01_227a rw01_227b rw01_231a rw01_231b\n') ;
      fprintf('  rw01_241  pw02_091a pw02_091b pw02_091c\n') ;
      t = [] ; c = [] ;
      return ;
end

if ~exist('oz','var'),
	oz = 0 ;
end

bldur = 32*340/fs ;       % block duration in seconds
sfs = fs/680 ;            % raw sensor sampling rate in Hz
[bb bl] = badblock(id) ;  % retrieve bad blocks for this tag

% find start point in bad blocks
kb = min(find(bb(:,1)>=st(1) & bb(:,2)>=st(2))) ; 
cRT = [0;cumsum(bl(st(1):end)-hist(bb(kb:end,1),st(1):length(bl))')-st(2)+1]...
       *bldur+oz ; % cumulative record time

switch length(cue)
   case 1
       tcue = cue ;
   case 2
		 if cue(1)-st(1)+1 >= 1,
          tcue = cRT(cue(1)-st(1)+1)+cue(2) ;
		 else
			 tcue = -1 ;
		 end
   case 3
       tcue = etime([tagon(1:3),cue(:)'],tagon) ;
   otherwise
       fprintf('Cue must be 1- to 3- elements. See help tagcue\n') ;
       t = [] ; c = [] ;
       return ;
end

s = tcue ;
if tcue<0,
   fprintf('cue is before start of data set\n') ;
   t = [] ; c = [] ; len = [] ;
   return ;
end

t = datevec(datenum(tagon(1),tagon(2),tagon(3),tagon(4),tagon(5),tagon(6)+tcue)) ;
kl = max(find(cRT<=tcue)) ; 	% find which chip the tcue is in
c(1) = kl-1+st(1) ;
c(2) = fs*(tcue - cRT(kl))+1 ;
c(3) = tcue/sfs ;
len = [id,0,0,0] ;
FS = fs ;
