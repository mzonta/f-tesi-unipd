function reticolo ( G,Xmax,Ymax,risoluzione,n_fig )

% *) Xmax,Ymax: dimensioni immagine
% *) risoluzione: n.ro di parti in cui si suddivide il singolo asse
%                 si ricavano 2*n_parti^2 "simplex"
% *) n_fig: contatore figure

passo_x=Xmax/risoluzione;
passo_y=Ymax/risoluzione;

figure(n_fig)
axes
set(gca,'XLim',[0 Xmax]);
set(gca,'YLim',[0 Ymax]); 

for k=0:risoluzione
   
   % Verticali a x=xk costante.
   xk=k*passo_x;
   line([xk xk],[0 Ymax],'Color','b');
   
   % Orizzontali a y=yk costante.
   yk=k*passo_y;
   line([0 Xmax],[yk yk],'Color','b');
   
end

% Diagonali "NE".
% - Diagonale principale
line([0 Xmax],[0 Ymax],'Color','b');

% - Diagonali inferiori e superiori.
for k=1:risoluzione-1 
   
   xk=k*passo_x;
   y=Ymax-k*passo_y;
   line([xk Xmax],[0 y],'Color','b');
   
   yk=k*passo_y;
   x=Xmax-k*passo_x;
   line([0 x],[yk Ymax],'Color','b');
   
end

Gn=intersezioni_reticolo(G,Xmax,Ymax,risoluzione);

hold on;
plot([G(:,1);G(1,1)],[G(:,2);G(1,2)],'k');
hn=plot(Gn(:,1),Gn(:,2),'r.');
set(hn,'markersize',12);

