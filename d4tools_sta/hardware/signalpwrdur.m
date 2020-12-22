function	d = signalpwrdur(x, np, q)
%
%	d = signalpwrdur(x, np, q)
%	Estimate signal duration in a vector containing signal and noise.
%	The q*100% energy duration is returned. np is the estimated noise
%	power taken from a prior block with only noise.
%
%	This function mimics the assembly language function:
%		newpwr_dur() in misc_asm.s5x used in the clpar module of D3.
%	It is for testing and verification purposes only.

xx = cumsum(x.^2) ;
es = xx(end,:) - repmat(np*size(x,1),1,size(x,2)) ;	% estimated signal energy
thr = es/2 * q ;					% threshold
acc = repmat(-(es/2),size(x,1),1) ;
acc = acc+xx-repmat(np*(1:size(x,1))',1,size(x,2)) ;		% signal power accumulator
d = sum(abs(acc)<repmat(thr,size(x,1),1)) ;
