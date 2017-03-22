function LSD = loc_stand_dev ( I,n )

% LOC_STAND_DEV Local Sandard Deviation come rapporto tra le deviazione standard
%               e la media nella finestra W ( n x n pixel )

tic

% Calcolo della media in W
% - Nucleo del filtro di media
hm=ones(n)/n^2;
% - Applicazione del filtro
I_m=filter2(hm,I);

% Calcolo della deviazione standard in W
% - Energia di ogni pixel
E=I.^2;
% - Media dell'energia in W
E_m=filter2(hm,E);
% - Deviazione standard in W
S=sqrt(abs(E_m-I_m.^2));

% Oss. Si considera l'ABS perchè si possono ottenere dei piccolissimi valori 
%      negativi in <E_M-I_M.^2>, anche se in teoria non dovrebbe verificarsi.
%      Questo probabilmente dovuto alle approsimazioni nel filtraggio.
%      Tale risultato scompare all'aumentare delle dimensioni di W.

% Local Sandard Deviation
LSD=S./I_m;

tempo=toc





