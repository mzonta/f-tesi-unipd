function V = camp_rc2 ( U )

% CAMP_RC2 Considera i pixel di riga e colonna dispari.

[rr,cc] = size(U);

r2=floor(rr/2);
c2=floor(cc/2);

ir=2*([1:r2]')-1;
ic=2*([1:c2])-1;

V=U(ir,ic);

