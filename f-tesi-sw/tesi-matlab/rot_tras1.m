function Y = rot_tras ( X,Np,rot,tras )

% Effettua rototraslazione sui vettori in X
% X: (Npunti,2)
% Np: n.ro di punti
% rot: matrice di rotazione (2 x 2)
% tras: vettore di traslazione

% Si considerano coordinate omogenee 
v_uni=ones(1,Np);
Xom=[X'; v_uni]; %(3 x Np)

% Matrice di rototraslazione
MRT=zeros(3);
MRT(:,1:2)=[rot; 0 0];
MRT(:,3)=[tras; 1];

Yom=MRT*Xom; %(3 x Np)

Y=Yom(1:2,:)';


