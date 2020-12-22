function    X = opennc(fname)

%    V = opennc(fname)
%		This is a wrapper on load_nc to enable opening
%		of nc files via the open function in Matlab.
%		This also allows nc files to be opened by dragging
%		them into the workplace.
%		Note that if open is called without an output
%		argument and fname points to an nc file, this function
%		will load the variables in the file into the base
%		workspace which may not necessarily be the calling
%		workspace. If loading an nc file within a function, use
%		load_nc or provide an output argument to open.
%
%		markjohnson@st-andrews.ac.uk
%		30 Dec 2018

X = load_nc(fname) ;
if nargout>0, return, end

vnames = fieldnames(X) ;
for k=1:length(vnames),
   assignin('base',vnames{k},X.(vnames{k})) ;
end
