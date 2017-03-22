function [Qi,Qe] = defQie ( Q )

% DEFQIE Definisce la curva interna Gi e quella esterna Ge che
%        contengono G; permettono di definire una regione 
%        nell'intorno di G.
%        In particolare tali curve sono definite attraverso i due
%        poligoni Qi e Qe formati dai control points che si trovano
%        all'interno e all'esterno rispettivamente di G, definita 
%        dai control points Q.
%        Per ottenere Qi e Qe si sfrutta la proprietà di "covex-hull"
%        dei control points stessi.
%
% *) Q: vettore control points (Nq x 2).


% Vettore flag indici.
indflag=ones(1,length(Q));

% Dato il vettore Q di c.ps. che definiscono G, ne considero la
% convex hull, ovvero quei c.ps che sono esterni alla curva.
indQe=convhull(Q(:,1),Q(:,2));
% Osservazione. Gli indici sono ordinati in modo che i corrispondenti
% punti in Q siano a sua volta ordinati in senso antiorario.
% I due indici estremi sono uguali per cui scarto l'ultimo.
indQe=indQe(1:length(indQe)-1);

% Qe: vettore dei vertici della convex hull "esterna".
Qe=Q(indQe,:);

% Si pongono a zero i flag relativi agli indici di Qe.
indflag(indQe)=0;
% I rimanenti sono gli indici di Qi, convex hull "interna"
indQi=find(indflag);

% Qi: vettore dei vertici della convex hull "interna".
Qi=Q(indQi,:);






