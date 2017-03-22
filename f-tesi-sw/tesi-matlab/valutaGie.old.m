function [Gi,Ge] = valutaGie ( G,Vne,Vk,Xmax,Ymax,n_W,Limax,Lemax )

% G: grafico di riferimento.
% Vne: vettore normali esterne.
% Vk: vettore curvature.
% Xmax,Ymax: dimensioni finestra grafico.
% n_W: dimensione finestra locale per il calcolo intensità.
% Limax,Lemax: ampiezze massime.

% N.ro punti.
Npunti=length(G);

Gi=zeros(Npunti,2);
Ge=zeros(Npunti,2);

% Si introduce un valore di saturazione per la curvatura pari a (1/Limax)
Vk=min(abs(Vk),1/Limax);

% 



