%function Im_snake = contour_grad ( ImIn )
% *) ImIn: matrice intensità immagine 
% *) Im_snake: restituisce immaggine con contorno individuato

% +) Modello snake: composizione di span definiti per mezzo di B-splines
%                   Ogni span è caratterizzato dalla shape matrix M 

% +) Xmax = R -+- Ymax = C

% -1) L'utente individua un n.ro sufficientemente elevato di p.ti.
%     vicini ai bordi dell'oggetto da selezionare.
% -2) I p.ti vengono ordinati in senso antiorario rispetto al loro baricentro.
% -3) Se il numero di p.ti non é ritenuto sufficiente se ne interiscono 
%     automaticamente, secondo qualche criterio, altri in posizioni intermedie.
%Oss.: verificare se é possibile qualche metodo per inizializzazione automatica
%      o semi-automatica.
% -4) Costruzione delle matrici A e As: X=A*Q e dX/ds=As*Q
% -5) Preelaborazione dell'immagine:
%     -a) ottenere una miglior definizione dei bordi/rimozione elementi di disturbo;
%     -b) calcolo del gradiente;
% -6) Per ogni span si considerano dei campioni intermedi e per questi si 
%     calcolano le forze che li attraggono verso gli edge vicini lungo normale.
%     Note tali forze si calcolano i nuovi p.ti di contatto per lo snake.
% -7) Calcolati i nuovi p.ti si aggiorna snake trovando la spline che meglio
%     approssima i p.ti; in questo modo si introducono dei vincoli
%     di regolarità (smooth) sulla curva .
% -8) -a) Se in qualche p.to dello span la curvatura o la lunghezza dello span
%     stesso sono superiori ad una certa soglia si introducono in quei p.ti dei 
%     nuovi c.p./nodi per aumentare la definizione della curva.
%     -b) Si aggiornano le matrici A e As.
% -9) Si ripete dal passo 6) finchè non si ritiene snake in equilibrio.

%Note. Le dimensioni di ciascuna matrice/vettore sono indicate ad ogni definizione.

function Im_snake = contour_grad ( ImIn )

% =======================================================================================
%    -0) Definizione e inizializzazione delle variabili di uso generale
% =======================================================================================
n_figure=0; %contatore figura attiva

% Fattore di scala tra la forza agente su un p.to dello snake e lo spostamento realizzato
c=1; %da valutare !!!!!!!

% Definizione della shape matrix - modella lo span secondo il modello:
%
% [xi(s) yi(s)] = [s^3 s^2 s 1]*M*[q(i-3) q(i-2) q(i-1) q(i)]'      (1)
%
% con 0 <= s < 1
%
% Qi=[q(i-3) q(i-2) q(i-1) q(i)]' vettore control points per lo span i-esimo
%
% Dato il vettore dei Control Points Q=[P1 P2 P3 P4 ... PN]'
% se si considera il vettore completo Qc=[Q Q(1:3)] si ottiene una curva chiusa 
% composta di N spans

M=[-1 3 -3 1; 3 -6 3 0; -3 0 3 0; 1 4 1 0]/6;

% No: n.ro minimo di Control Points richiesti per realizzare una buona approssimazione
%     dello snake_zero

No=10;

% =======================================================================================
%    -1) INTERFACCIA UTENTE: RICHIESTA CONTROL POINTS VICINI AL BORDO
%                            DELL'OGGETTO DI INTERESSE 
% =======================================================================================

[R,C]=size(ImIn);
Im_r=ones(R,C);

n_figure=n_figure+1;
figure(n_figure)
set(gcf,'MenuBar','none');
set(gcf,'NumberTitle','off');
set(gcf,'Name','INTERFACCIA UTENTE');

subplot(1,2,1);
set(gca,'XTick',[]);
set(gca,'XTickLabel',[]);
set(gca,'XColor',[1 1 1]);
set(gca,'YTick',[]);
set(gca,'YTickLabel',[]);
set(gca,'YColor',[1 1 1]);
subimage(ImIn);

subplot(1,2,2);
set(gca,'XLim',[0 R]);
set(gca,'YLim',[0 C]);
axis square;
axis ij;
set(gca,'XTick',[]);
set(gca,'XTickLabel',[]);
set(gca,'XColor',[1 1 1]);
set(gca,'YTick',[]);
set(gca,'YTickLabel',[]);
set(gca,'YColor',[1 1 1]);
hold

Q=zeros(No,2);

%leggo il p.to nell'immagine originale

tasto=1;
conta_cp=0;

while ((tasto~=27)|(conta_cp<No))
   
   conta_cp=conta_cp+1;
   
   %leggo il p.to nell'immagine originale
   subplot(1,2,1);
   [x,y,tasto]=ginput(1);
   
   if (tasto~=27)
      Q(conta_cp,:)=[x y];
      %che ricompare nell'immagine riflessa
      subplot(1,2,2);
      plot(x,y,'r+');
   end
  
end


% **************************************************************************************

% ======================================================================================
%    -2) ORDINAMENTO DEI C. P.s IN SENSO ANTIORARIO RISPETTO BARICENTRO
%        
%    N.B. E' importante che i Control Points siano ordinati in senso ANTIORARIO
%         perché il calcolo successivo delle normali esterne è basato sull'hp
%         che l'orientamento (positivo) dello snake sia quello antiorario   
% ======================================================================================

% processo momentaneamente sospeso

% **************************************************************************************

% ======================================================================================
%    -3) COMPLETAMENTO C. P.
% ======================================================================================

% processo momentaneamente sospeso

% **************************************************************************************

% ======================================================================================
%    -4) COSTRUZIONE DELLE MATRICI [A As]
%        Funzioni dei parametri (Ni Ns) e della matrice (M) 
% ======================================================================================

% Ns: n.ro di control points
Ns=length(Q);

% Ni: vettore (1 x Ns) con il n.ro di intervalli in cui è suddivide lo span
%     Da questo si ottengono Ni+1 campioni per ogni span per cui calcolare
%     l'incremento che porta alla definizione del nuovo snake

Ni=3*ones(1,Ns); %hp di Ni costante per ogni span

% Npunti: il n.ro totale di punti considerati per lo snake
Npunti=sum(Ni);

% A, As: (Npunti x Ns) lista matrici che legano i p.ti di ogni span Xi a Q (Npunti=sum(Ni))
%        
%        X = A*Q    e    dX/ds = As*Q

[A, As]=matrici_Bspline(Ni,M);

% --------------------------------------------------------------------------------------

% Costruzione del grafico dello snake al stato zero
G=A*Q; %(Npunti x 2) vettore p.ti snake

n_figure=n_figure+1;
figure(n_figure);
axis ij;
set(gca,'Xlim',[0 R]);
set(gca,'YLim',[0 C]);
hold
% - traccia C.P.
plot(Q(:,1),Q(:,2),'r*');
% - traccia grafico snake
plot(G(:,1),G(:,2),'k-');



% **************************************************************************************

% ======================================================================================
%   -5) PREELABORAZIONE DELL'IMMAGINE
% ======================================================================================

disp('Passo 5...');

% -5a)

ordine_m=input('Ordine del filtro mediano ( 0 per saltarlo ) = ');
if (ordine_m~=0)
   Im0=medfilt2(ImIn,[ordine_m,ordine_m]);
else
   Im0=ImIn;
end


%Oss.: Una volta ottenuta immagine bisogna eliminare bordi come nel caso successivo...


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% -5b) Calcolo del gradiente 

% Blurring image with 2D Gaussian filter
 
scale=input('Scala = ');
k_base=[1 2 1]/4;
k=k_base;
iter=round(2*scale^2)-1;
for i=1:iter
   k=conv(k,k_base);
end

halfklen=floor(length(k)/2);
actual_scale=sqrt(sum([-halfklen:halfklen].^2.*k));
fprintf(1,'Scala usata = %f\n', actual_scale);

Im_blur=conv2(conv2(Im0,k,'same'),k','same');

% Calcolo gradiente
   
der_x=[-1 0 1];
der_y=[-1 0 1]';

dx=conv2(Im_blur,-der_x,'same');
dy=conv2(Im_blur,-der_y,'same');

% Modulo gradiente
Im_grad=sqrt(dx.^2+dy.^2);
   
% Rimozione dei bordi dell'immagine (privi di informazioni su gradiente)
bordo=halfklen+2;
Im_g=Im_grad(bordo:R-bordo,bordo:C-bordo);

%n_figure=n_figure+1;
%figure(n_figure)
%surf(Im_g)

% **************************************************************************************

% --------------------------------------------------------------------------------------
%                     INIZIO CICLO DI EVOLUZIONE PER LO SNAKE              
% --------------------------------------------------------------------------------------

disp('Inizio evoluzione snake...');

% stop = 1 -> Continua l'evoluzione dello snake - stop = 0 Termina
stop=1;

% Contatore del numero di passi di evoluzione
contatore=0;

% L: "distanza" di ricerca dell'edge
L=5;
l_0=L+1;


while (stop>0)
   
   %Nota. Ns, Ni, Npunti vengono aggiornate alla fine di ogni ciclo se si
   %      verificano delle variazioni nelle caratteristiche dello snake-Bspline
   
     
   % Vettore coordinate nuovi punti di contatto
   Gnc=zeros(Npunti,2);
   
   % Vettore dei nuovi control points
   Qn=zeros(Ns,2);
   
   % ================================================================================
   %    -6) CALCOLO DELLE FORZE ESTERNE CHE AGISCONO SULLO SNAKE 
   %        (Forze che attraggono lo snake verso gli edge più vicini)
   %        CALCOLO DEI NUOVI PUNTI DI CONTATTO PER LO SNAKE
   % ================================================================================
   
   % -6a) Calcolo della normale esterna allo snake-spline in ogni punto 
   %      Si ricava la normale esterna nell'hp di orientamento positivo antiorario
   %      per la curva, ovvero l'orientamento della superficie è positivo se uscente
   %      dallo schermo.
      
   % Rt: matrice dei vettori tg allo snake nei punti considerati
   Rt=As*Q; %(Npunti x 2)
   
   % Rn: matrice di vettori normalizzati:
   %     Considerando che gli elementi lungo la diagonale principale della matrice 
   %     Rt*Rt' sono i quadrati dei vettori di Rt ottengo che le norme dei singoli
   %     vettori rt = Rt(i,:) risultano
   Norma_rt=sqrt(diag(Rt*Rt')); %(Npunti x 1)
   
   %     e quindi 
   Rn=[Rt(:,1)./Norma_rt Rt(:,1)./Norma_rt];  %(Npunti x 2)
   % Oss. Si è normalizzata una componente alla volta. 
   
   % M_ne: matrice dei versori normali esterni 
   %                      _    _                          _  _      _  _
   %                     | 0 -1 |                        | rx |    | ry |
   % M_ne = Rt*T con T = | 1  0 | in modo da ottenere da | ry | -> |-rx |    
   %                      -    -                          -  -      -  -
   
   M_ne=Rn*[0 -1; 1 0]; %(Npunti x 2)
   
   
      
   for i=1:Npunti
                  
      % vne versore normale esterno nel punto i-esimo
      vne=M_ne(i,:); %(1 x 2) vettore riga
            
      % -6b) Definite le seguenti funzioni:
      %      - V(z(l)) = |grad(I(z(l)))| con z=[x;y]+l*vne
      %      - D(l) = V(z(0))-V(z(l)) con -L <= l <= L
         
      % Vz è una funzione scalare di 2*L+1 elementi con l'elemento centrale nullo
      % (corrispondente a l=0)
      D_l=zeros(1,2*L+1);
               
      z_0=G(i,:);
      % Passaggio dalle coordinate xy alle agli indici ij nell'immagine bitmap
      % Oss. Si può fare di meglio che il semplice round?
      x_0=round(z_0(1));
      y_0=round(z_0(2));
      V_z0=Im_g(x_0,y_0);
         
      for l=1:L
         
                   
         z_lp=z_0+l*vne; %verso l'esterno della curva
         x_lp=round(z_lp(1));
         y_lp=round(z_lp(2));
         V_zp=Im_g(x_lp,y_lp); %V(z(-l))
            
         z_lm=z_0-l*vne; %verso l'interno della curva
         x_lm=round(z_lm(1));
         y_lm=round(z_lm(2));
         V_zm=Im_g(x_lm,y_lm); %V(z(l))
            
         D_l(l_0+l)=V_z0-V_zp;
         D_l(l_0-l)=V_z0-V_zm;
            
      end
         
      %      Questa funzione presenta degli avvallamenti per l tali che V(z(l))>V(z(0))
      %      in corrispondenza di punti a maggior gradiente valutabili attarverso
       
      %      (dD/dl) = (dV(z(l)/dl)
         
      dD_dl=-conv(D_l,-dx); %vettore di lunghezza pari a (2*L+1)+2
         
      % Si escludono dal risultato della convoluzione i primi e gli ultimi due termini
      % perchè risultano ottenuti dalla convoluzione con elementi nulli, per effetto
      % dello zero-padding, non appartenenti alla sequenza data D(l)
         
      dD_dl=dD_dl(3:2*L+1);
         
      %      che risulta positiva (espansione) se lo snake sta "scendendo" lungo
      %      l'avvallamento per raggiungere l'edge oppure negativa (contrazione)
      %      se lo snake sta ritornando verso l'edge
         
      %      Si considera una forza agente sullo snake di tipo elastico, proporzionale
      %      alla distanza fra snake e l'edge lungo la direzione fissata
         
      %      f = l_max*vne;
         
      %      dove per l_max corrisponde  max[(dD/dl)(l)]  
         
      [max_dD,l_m]=max(dD_dl);
         
      l_max=l_m-l_0;
         
      %      l_max è positiva per l'espansione oppure negativa se contrazione
         
      f=l_max*vne;
         
      % -6c) Le coordinate dei nuovi punti di contatto per lo snake al passo k+1-esimo 
         
      %      G(k+1) = G(k) + c*f 
      % Oss. Si dovrà valutare c in modo opportuno; eventualmente dipendente da condizioni
      %      geometriche dello snake (oppure altro)
        
      Gnc(i,:)=G(i,:)+c*f; %(Npunti x 2)
      
   end

   % ***********************************************************************************
   
   % ===================================================================================
   %    -7) COSTRUZIONE DELLO SNAKE A B-SPLINE CHE MEGLIO APPROSSIMA I NUOVI
   %        PUNTI DI CONTATTO -> NUOVI CONTROL POINTS
   % ===================================================================================
      
   disp('...Passo7)...');
      
   % A partire dall'espressione X = A*Q, noti i punti X si vuole determinare Q 
   
   % Una soluzione risulta   Q = B*X, con B=inv(A'A)*A'
      
   B=inv(A'*A)*A'; %(Ns x Npunti)
      
   Qn=B*Gnc; %(Ns x 2)
   
   % ********************************************************************************
         
     
   % Visualizzazione vettori spostamneto
   n_figure=n_figure+1;
   figure(n_figure);
   plot(G(:,1),G(:,2),'ko');
   hold
   for i=1:Npunti
      l=line([G(i,1) Gnc(i,2)],[G(i,2) Gnc(i,2)]);
      set(l,'Color',[1 0 0]);
   end
   set(gca,'XLim',[0 R]);
   set(gca,'YLim',[0 C]);
   
   % Confronto tra i p.ti di Gnc e lo snake-spline approssimazione
   n_figure=n_figure+1;
   figure(n_figure);
   plot(Gnc(1,:),Gnc(2,:),'k');
   hold
   plot(Qn(1,:),Qn(2,:),'r+');
   set(gca,'XLim',[0 R]);
   set(gca,'YLim',[0 C]);

   
     
   % ===================================================================================
   %    -8) OTTIMIZZAZIONE DEI CONTROL POINTS   
   %        In base alle proprietà geometriche dello snake-spline (smoothness)         
   % ===================================================================================
   
   % procedura momentaneamente sospesa
   
   % ***********************************************************************************
   
   % ===================================================================================
   %    -9) RITORNA AL PASSO -6)
   %        Definizione delle condizioni di termine esecuzione evoluzione
   % ===================================================================================
   
   % Aggiornamento delle variabili per il passo successivo
   G=Gnc;
   Q=Qn;
   
   %Visualizzazione del risultato dell'evoluzione (per fase di debug)
   if (rem(contatore,1)==0)
      Imp=ImIn;
      Npunti=length(G);
      for np=1:Npunti
         Imp(round(G(:,np)'))=1;
      end
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Imp);
   end
   
   stop=input('Continua -> 1 -+- Termina -> 0 ');
   
   % ***********************************************************************************

end

%-------------------------- FINE CICLO EVOLUZIONE SNAKE --------------------------------

Im_snake=ImIn;
Npunti=length(G);
for np=1:Npunti
   Im_snake(round(G(:,np)'))=1;
end



%OSSERVAZIONI CONCLUSIVE

% O1) Le diverse scelte e i parametri devono essere selezionabili con pulsanti, slider, ...

% O2) La matrice A (e quindi B) è costante se non varia il numero di campioni considerato; 
%     tale variazione potrebbe essere considerata nel momento in cui si voglia migliorare
%     la definizione dello span: in corrispondenza di span molto lunghi, oppure 
%     caratterizzati da elevata curvatura...
