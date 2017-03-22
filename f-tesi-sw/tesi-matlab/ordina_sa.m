function P_osa = ordina_sa ( P )

% *) P: vettore dei p.ti da ordinare (np x 2)
%
% -) P_osa: vettore dei p.ti ordinati in senso antiorario (np x 2)
%
% Ordina il vettore di punti (P) in senso antiorario (rispetto al centroide Pc); è 
% importante per mantenere il senso di percorrenza della curva chiusa-snake positivo.
% L'ordinamento è antiorario rispetto all'usuale sistema di riferiemnto cartesiano X-Y.


% Dati gli np punti P, si considera il centroide Pc
np=length(P);
Pc=sum(P,1)/np; %(1 x 2)

% Rispetto a Pc si calcolano i vettori vi = Pi - Pc 
% V = [vi] (np x 2)
V=zeros(np,2);

% fase: (np x 1) vettore delle fasi
fase=zeros(np,1);

for i=1:np
   
   v_i=P(i,:)-Pc;
     
   V(i,:)=v_i;
   
   % Calcolo della fase del vettore come fosse la rappresentazione cartesiana 
   % di un numero complesso
   fase(i)=angle(v_i(1)+v_i(2)*sqrt(-1));
   
end

% Si procede all'ordinamento (crescente) del vettore delle fasi.
[f_ord, f_ind]=sort(fase);

% A partire dal vettore indici f_ind relativi agli elementi ordinati in f_ord
% ricostruisco il vettore di punti P_osa ordinati in senso antiorario.
P_osa=zeros(np,2); 

for i=1:np
   
   P_osa(i,:)=P(f_ind(i),:);
   
end
   
   



