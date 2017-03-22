function LAM = l_anis_mis ( Im,n )

% L_ANIS_MIS  Calcola una misura locale di anisotropia (DEFINIRE)

dimIm=size(Im);

if (length(dimIm)<3)
   
   dimIm=[dimIm,1];
   
end

LAM=zeros(dimIm);

T=2*(n-1);

% Applicazione ordine-filtro

minimo=1; % Minimo
massimo=n; % Massimo
mediana=(n+1)/2; % Mediana

W_min=zeros([dimIm(1:2),T]);
W_max=zeros([dimIm(1:2),T]);
W_mdn=zeros([dimIm(1:2),T]);

% Matrice dei supporti  
W=supporto_w(n);

% Immagine di livello p
Im_lp=zeros(dimIm(1:2));

% Osservazione. E' possibile evitare il ciclo <for p=1:dimIm(3)...> eseguendo
%               le operazioni direttamente sull'immagine vettoriale; questo
%               comporta però un aumento della memoria richiesta in quanto si
%               devono considerare contemporaneamente <T*dimIm(3)> matrici
%               bidimensionali <dimIm(1)*dimIm(2)>.
%               Se interessati ad eliminare tale ciclo occorre tenerne conto 
%               nella definizione di W_xxx la cui terza dimensione va moltiplicata
%               per dimIm(3).

for p=1:dimIm(3)
   
   Im_lp=Im(:,:,p);
   
   for t=1:T
      
      % Calcolo dei valori lungo le diverse direzioni
      W_loc(:,:,1)=W(:,:,t);
      
      %W_min(:,:,t)=ordfilt2(Im_lp,minimo,W_loc);
      %W_max(:,:,t)=ordfilt2(Im_lp,massimo,W_loc);
   
      %W_mdn(:,:,t)=ordfilt2(Im_lp,mediana,W_loc);
      
      H=W_loc/n;
      W_media(:,:,t)=filter2(H,Im_lp,'same');
      
      %W_media(:,:,t)=(W_max(:,:,t)+W_min(:,:,t))/2;    
      
   end
   
   % Matrici dei minimi e massimi

   %M_min=min(W_min,[],3);
   %M_max=max(W_max,[],3);

   %M_min=min(W_mdn,[],3);
   %M_max=max(W_mdn,[],3);
   
   M_min=min(W_media,[],3);
   M_max=max(W_media,[],3);

   % Local Anisotropy Measure
   LAM(:,:,p)=(M_max-M_min)./(M_max+M_min);
   
end



% ---------------------------------------------------------------------------
% Function: SUPPORTO_W
% ---------------------------------------------------------------------------

function W = supporto_w ( n )

% SUPPORTO_W Costruisce il supporto (la finestra di pixel prossimi a quello
%            considerato) su cui effettuare le misure.
%
%            W=SUPPORTO_W(N); [ N x N x T ]

k=(n-1)/2;
kc=k+1;
vv=[-k:k];
T=2*(n-1);

DX=zeros(2*k+1,T);
DY=zeros(2*k+1,T);

for t=1:n
   
   dy=1+k-t;
   
   for z=-k:k
      
      DX(z+kc,t)=z;
      DY(z+kc,t)=round(-z*dy/k);
      
   end
   
end

for t=n+1:T
   
   dx=t-n-k;
   
   for z=-k:k
      
      DX(z+kc,t)=round(-z*dx/k);
      DY(z+kc,t)=z;
      
   end
   
end   

% Costruzione della matrice delle maschere - DOMAIN

W=zeros(n,n,T);

for t=1:T
   
   for z=-k:k
      
      W(-DY(z+kc,t)+kc,DX(z+kc,t)+kc,t)=1; 
      
   end
   
end

