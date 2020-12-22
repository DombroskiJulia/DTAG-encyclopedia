function    G = ca_code(PRN)
%
%   G = ca_code(PRN)
%   Generates the C/A Gold code sequences for GPS
%   Algorithm taken from IS-GPS-200 Interface Specification
%   revision D, 7 Dec. 2004. PRN is the satellite number
%   1-32. G is a 1023 length binary vector.
%
%   implementation by Mark Johnson, WHOI
%   April 21, 2006

G = [] ;
if PRN<1 | PRN>36,
   fprintf('PRN must be 1 to 36\n') ;
   return
end

TAPS = [2 6;3 7;4 8;5 9;1 9;2 10;1 8;2 9;3 10;2 3;3 4;
        5 6;6 7;7 8;8 9;9 10;1 4;2 5;3 6;4 7;5 8;6 9;
        1 3;4 6;5 7;6 8;7 9;8 10;1 6;2 7;3 8;4 9;5 10;
        4 10;1 7;2 8] ;

% G1 PRN generator
X = ones(10,1) ;
G1 = zeros(1023,1) ;
for k=1:1023,
   G1(k) = X(10) ;
   X = [xor(X(10),X(3));X(1:9)] ;
end

% G2 PRN generator
X = ones(10,1) ;
G2 = zeros(1023,1) ;
for k=1:1023,
   G2(k) = mod(sum(X(TAPS(PRN,:))),2) ;
   X = [mod(sum(X([2 3 6 8 9 10])),2);X(1:9)] ;
end

G = xor(G1,G2) ;
