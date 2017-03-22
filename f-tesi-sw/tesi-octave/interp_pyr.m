function S = interp_pyr ( I )

% INTERP_PYR Interpola valori intensità da un livello superiore a uno inferiore.
%            ( Immagine bidimensionale )

% Dimensioni dell'immagine vettoriale I
[rr,cc]=size(I);

% Indici posizioni in I
ir=[1:rr]';
ic=[1:cc];

% - Definizione indici quadranti
% In alto a sinistra
qasr=2*ir-1; 
qasc=2*ic-1;
% In alto a destra
qadr=2*ir-1;
qadc=2*ic;
% In basso a sinistra
qbsr=2*ir;
qbsc=2*ic-1;
% In basso a destra
qbdr=2*ir;
qbdc=2*ic;

% Dimensioni di S
nr=2*rr;
nc=2*cc;

S=zeros(nr,nc);
 
% - Completamento dei quadranti in S
S(qasr,qasc)=I(ir,ic);
S(qadr,qadc)=I(ir,ic);
S(qbsr,qbsc)=I(ir,ic);
S(qbdr,qbdc)=I(ir,ic);







