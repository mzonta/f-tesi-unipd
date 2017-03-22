function p = pesi_comp ( G,wd,wc )

% PESI_COMP Associa a ciascun p.to della curva G un valore che pesa la complessità
%           della curva in quel punto.
%
%      Tale valore è definito come la combinazione lineare di due termini secondo
%      i coefficienti <wd> e <wc>.
%      I due termini considerati , <d> e <c>, tengono conto, rispettivamente, della 
%      distanza dei punti precedente e seguente a quello in esame e della 
%      curvatura nel punto considerato.
%      
%      N.B. I due parametri sono normalizzati rispetto un opportuno fattore di
%           forma <fforma> che li rende invarianti ai cambiamenti di scala.
%           (Le rototraslazioni non influiscono sui due parametri in quanto
%            non alterano le dimensioni).
%
% *) G (Np x 2).
% *) wd,wc coefficienti della combinazione lineare di <d> e <c>.
% Osservazione. Si possono individuare i due casi estremi:
% a) wd=0 ==> p = c, la complessità è definita dalla curvatura;
% b) wc=0 ==> p = d, la complessità è definita dalla distanza media tra
%                   i punti contigui.

% N.ro di punti.
Np=length(G);

% Si considera come fattore di forma il perimetro del poligono di vertici G(i).
fforma=sum(norm(diff([G; G(1,:)])));

% Vettore esteso dei punti di G; si prepone G(Np,:) e si pospone G(1,:) a G.
Ge=[G(Np,:); G; G(1,:)];

% Vettore <d>.
d=zeros(Np,1);

% Vettore <c>.
c=zeros(Np,1);

% Vettore pesi <p> normalizzati.
p=zeros(Np,1);

for i=1:Np
   
   % Per ogni punto di G; è traslato di una posizione in avanti in Ge.
   % u = G(i-1) - G(i)
   % v = G(i+1) - G(i)
   u=(Ge(i,:)-Ge(i+1,:))/fforma;
   v=(Ge(i+2,:)-Ge(i+1,:))/fforma;
   % Osservazione. I due vettori sono normalizzati rispetto al fattore di forma.
   
   % Distanza.
   d(i)=norm(u)+norm(v); 
   
   % Curvatura.
   c(i)=norm(u+v);
   
end

% Il vettore dei pesi è definito dalla combinazione lineare di <d> e <c>.
p=wd*d+wc*c;


fprintf(1,'Perimetro = %g \n',fforma);

figure

subplot(3,1,1);
plot(d);
title('Componente d');

subplot(3,1,2);
plot(c);
title('Componente c');

subplot(3,1,3);
plot(p);
title('Pesi p');

