function Qo = snake_zero ( I,NpS,rot,tras )

% SNAKE_ZERO  Costruisce una curva iniziale, snake, a partire dalle informazioni
%             ricavabili dall'analisi dell'intensità dell'immagine.
%             Il risultato dipende dal tipo di immagine disponibile; risulta
%             migliore tanto più l'immagine si può ritenere binaria, ovvero
%             l'oggetto in esame appare distinto dallo sfondo.
%
%        Qo = SNAKE_ZERO ( I,NpS ) 
%        I: Immagine; NpS: n.ro di punti per span.
%
% Nota. Le coordinate sono definite nel sistema di riferimento "Grafico"
% (vedi note in Q_snake)

% 1) Immagine binaria:  possibile ricavarne il perimetro.

if (~isbw(I))
   
   error('Attualmente soluzione disponibile solo per immagini binarie.');
   
end

% - Ricavo il perimetro con metodo per immagini binarie.
%N=4: 4-connected -+- N=8: 8-connected
nc=4; 
BWp=bwperim(I,nc);
% Osservazione. La funzione BWPERIM ritorna un'immagine binaria con valori "1"
% in corrispondenza dei pixel del bordo dell'immagine originale; da questa si
% devono ricavare le coordinate pixel.

% - Calcolo delle coordinate pixel.
% Indici dei pixels p(i,j)=1
[indI,indJ]=find(BWp);
% indI corrisponde agli indici di riga = coordinate YI
% analogamente indJ = XI (nel sistema di rif. "Immagine")

% - Trasformazione delle coordinate nel sistema di riferimento "Grafico".
CI=[indJ,indI]; % Sist. Rifer. "Immagine"
C=rot_tras(CI,length(CI),rot,tras); % Sist. Rifer. "Grafico"

% - Ordinamento dei punti in senso antiorario.
C=ordina_sa(C); %(Np x 2)
Np=length(C); % N.ro di punti a disposizione

% - Costruzione della curva a B-spline che approssima la curva Co.
% Fissato il numero di punti per span si ricava che il numero di span risulta
Ns=floor(Np/NpS);
% Il n.ro di punti considerati per la nuova curva
Npo=Ns*NpS;
% Il numero di punti persi risulta Npp
Npp=Np-Npo;
% Osservazione. Questi punti possono essere scartati definitivamente oppure
% utilizzati per costruire uno span di "dimensioni ridotte"; questo dipende 
% dal numero di tali punti.
% Dato che comunque sto cercando un'approssimazione posso scartarli .
% Elimino i punti in eccesso "campionando" il vettore Np ogni NpS punti.
% (elimino i punti di indice NpS+1,2*Nps+2,3*Nps+3,...)
Co=zeros(Npo,2); %(Npn x 2)

i_o=1;
i_f=NpS;

for k=1:Npp
   
   Co((k-1)*NpS+1:k*NpS,:)=C(i_o:i_f,:);
   
   % Per il passo successivo
   i_o=i_f+2;
   i_f=i_f+NpS+1;
   
end

% Copio i rimanenti
Co(Npp*NpS+1:Npo,:)=C(i_o:Np,:);

figure
plot(C(:,1),C(:,2),'c.');
hold on;
%plot(Cn(:,1),Cn(:,2),'r');

% Calcolo dei c.ps relativi alla curva Cn
Ni=NpS*ones(Ns,1);
[A,As,Ass]=matrici_Bspline(Ni);

B=inv(A'*A)*A';

Qo=B*Co;

X=A*Qo;

plot(Qo(:,1),Qo(:,2),'r+');
plot(X(:,1),X(:,2),'k');


