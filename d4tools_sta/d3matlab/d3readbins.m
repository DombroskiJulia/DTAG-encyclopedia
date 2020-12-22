function    [B,BH,H] = d3readbins(recdir,prefix)
%
%    [B,BH,H]=d3readbins(recdir,prefix)
%     Read data from a set of D3 bin files.
%     fname is the full path and filename of the file to read
%     blk is the block number to read or 
%     blk = [start_block, number_of_blocks] or
%     blk = [] to read all blocks.
%
%     B is a matrix containing the data from the requested block
%        (if one block is requested) or a cell array of matrices
%        (if multiple blocks are requested).
%     BH is a structure array containing the block headers for each
%        requested block. Fields are:
%        blk      block number
%        rtime    Unix time of the first sample in the block
%        mticks   time offset from rtime in microseconds of the first 
%                 sample in the block
%        n        number of data points in the block
%        ns       number of samples per channel in the block
%     H is a structure array containing the file header with fields:
%        nblks    number of blocks in the file
%        fs       sampling rate in Hz
%        nbits    number of bits per sample
%        nchs     number of channels
%
%     NOTE: currently only supports 16 bit data.
%
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

%     BIN files have a header of 28 bytes containing:
%     byte 1-8    8-byte data source name
%     byte 9-12   number of blocks in the file
%     byte 13-16  configuration number
%     byte 17-20  sampling rate in Hz
%     byte 21-24  number of bits per word
%     byte 25-28  number of channels per sample
%
%     Blocks of data follow the header. Each block has
%     a 20 byte block header containing:
%     byte 1-4    4-byte flag ("blck")
%     byte 5-8    block number (first block is 0)
%     byte 9-12   rtime (Unix seconds)
%     byte 13-16  mticks (microseconds)
%     byte 17-20  number of 16-bit words in the block

B = {} ; BH = [] ; H = [] ;
suffix = 'bin' ;

if nargin<1,
   help d3readbins
   return
end

fn = getrecfnames(recdir,prefix) ;
if isempty(fn), return, end

% read in bin data from each file
for k=1:length(fn),
   fprintf('Reading file %s.%s\n', fn{k},suffix) ;
   ffn = [recdir '/' fn{k} '.' suffix] ;
   if ~exist(ffn,'file')
      continue
   end

   [b,bh,h] = d3readbin(ffn,[]) ;
   if length(b)==0,
      continue
   end
   if ~iscell(b),
      b = {b} ;
   end
   [B{end+(1:length(b))}] = deal(b{:}) ;
   if isempty(H),
      H = h ;
      BH = bh ;
   else
      H.nblks = H.nblks + length(b) ;
      [BH(end+(1:length(bh)))] = deal(bh) ;
   end
end

