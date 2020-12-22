% Test vectors for cmul8 function

X=['12f7';'8745';'7034';'4567';'c3d1';'00e4';'1700';'6743'];
Y=['49b4975a';'3961f720';'d90fb6e7';'28bc66ae';'70e2c3aa';'60b21351';'0083d2f9';'b05352a0'];
x = [hex2dec(X(:,1:2)) hex2dec(X(:,3:4))] ;
k = find(x>=128) ;
x(k) = x(k)-256 ;
x = (x(:,1)+j*x(:,2))/128 ;

y = [hex2dec(Y(:,1:4)) hex2dec(Y(:,5:8))] ;
k = find(y>=32768) ;
y(k) = y(k)-65536 ;
y = (y(:,1)+j*y(:,2))/32768 ;

% dopp = 0
z = round(x.*conj(y)*32768)
Z = [real(z) imag(z)]
k = find(Z<0) ;
Z(k) = 65536+Z(k) ;
fprintf('0x%04X%04X\n',Z')

% dopp = 7
x=[x(end);x(1:end-1)];
z = round(x.*conj(y)*32768)
Z = [real(z) imag(z)]
k = find(Z<0) ;
Z(k) = 65536+Z(k) ;
fprintf('0x%04X%04X\n',Z')

