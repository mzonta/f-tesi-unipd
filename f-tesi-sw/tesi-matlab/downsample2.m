function V = downsample2(U)

% DOWNSAMPLE2	9-point subsampling (see Burt,Adelson IEEE Tcomm 31, 532)
%		V = downsample2(U)
%		Call r,c the dimensions of the image U
%		then V has dimensions  p = 2*floor((r-1) / 4)+1 and
%		q = 2*floor((c-1) / 4)+1 so that both p and
%		q are odd. This simplifies the code.

%		(c) Pietro Perona,
%		California Institute of Technology
%		May 30 1993

[r,c] = size(U);

p = 2*floor((r-1) / 4)+1;
q = 2*floor((c-1) / 4)+1;

cp= 2*([1:p]'-1)+1;
cq= 2*([1:q]-1)+1;
e = cq+1; e(q) = e(q)-1;
w = cq-1; w(1) = w(1)+1;
n = cp-1; n(1) = n(1)+1;
s = cp+1; s(p) = s(p)-1;

% Interior
V = 0.25 * U(cp,cq) +...
	0.125*(U(n,cq) + U(s,cq) + U(cp,e) + U(cp,w)) + ...
	0.0625*(U(n,e) + U(s,e) + U(n,w) + U(s,w));


