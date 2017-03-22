function Q_snake = snake ( ImIn,Q,g_dt,g_curv,n_W,n_figure )

% *) ImIn: matrice intensità immagine
%          - (R x C) nel caso di immagine in scala di grigio o binaria.
%          - (R x C x ncomp) nel caso di immagine vettoriale
%            ( ncomp: il n.ro di valori per ogni pixel; associati all trasformazione
%                       sull'immagine realizzata in ingresso ) 
% *) g_dt: fattore di scala fra l'intensità della forza e lo spostamento effettivo.
%          [dell'ordine 1e5]
% *) g_curv: fattore di scala per peso curvatura.
%          [dell'ordine 100]
% *) Q: snake iniziale definito attraverso i suoi control points.
%
% *) Im_snake: restituisce immaggine con contorno individuato
%
% +) Modello snake: composizione di span definiti per mezzo di B-splines
%                   Ogni span è caratterizzato dalla shape matrix M 
%
%
% -1) L'utente individua un n.ro sufficientemente elevato di p.ti
%     vicini ai bordi dell'oggetto da selezionare.
% -2) I p.ti vengono ordinati in senso antiorario rispetto al loro baricentro.
% -3) Se il numero di p.ti non é ritenuto sufficiente se ne inseriscono 
%     automaticamente, secondo qualche criterio, altri in posizioni intermedie.
%Oss.: verificare se é possibile qualche metodo per inizializzazione automatica
%      o semi-automatica.
% -4) Costruzione delle matrici A e As: X=A*Q e dX/ds=As*Q
% -5) Preelaborazione dell'immagine:
%     -a) ottenere una miglior definizione dei bordi/rimozione elementi di disturbo;
%     -b) calcolo del gradiente;
% -6) Per ogni span si considerano dei campioni intermedi e per questi si 
%     calcolano gli incrementi dC/dt e quindi i nuovi punti di contatto.
% -7) Calcolati i nuovi p.ti si aggiorna snake trovando la spline che meglio
%     approssima i p.ti; in questo modo si introducono dei vincoli
%     di regolarità (smooth) sulla curva .
% -8) -a) Se in qualche p.to dello span la curvatura o la lunghezza dello span
%     stesso sono superiori ad una certa soglia si introducono in quei p.ti dei 
%     nuovi c.p./nodi per aumentare la definizione della curva.
%     -b) Si aggiornano le matrici A e As.
% -9) Si ripete dal passo 6) finchè non si ritiene snake in equilibrio.

%Note. Le dimensioni di ciascuna matrice/vettore sono indicate ad ogni definizione.


% =======================================================================================
%    -0) Definizione e inizializzazione delle variabili di uso generale
% =======================================================================================
%n_figure=0; % Contatore figura attiva

visualizza=4; % Stato di visualizzazione risultati parziali (per DEBUG)

visualizza_tempo=1; % Tempi parziali

No=4; % N.ro minimo di p.ti per definire l'area occupata dall'oggetto in esame

% Fattore generato dalla discretizzazione di dG/dt.
% Nel caso della discretizzazione secondo Eulero 
%
%                       dG/dt = ( G(t+dt) - G(t) ) / dt
% e quindi si ha 
%
%                G(t+dt) = G(t) + dt*(dG/dt) = G(t) + g_dt*(dG/dt).
%
% Att.ne. La scelta di tale "guadagno", ovvero del passo di discretizzazione,
%         condiziona la convergenza in quanto può portare lo snake a "saltare"
%         lo stato di minima energia.
%
% Riassumendo         g_dt = fscala*dt

% media_varianza: per la scelta del parametro statistico che caratterizza la ROI
%                 1 - media
%                 2 - varianza
media_varianza=1;


% SISTEMA DI RIFERIMENTO UTILIZZATO NELLA VISUALIZZAZIONE SU IMMAGINE BITMAP
   
% L'istruzione seguente considera il sistema di riferimento associato all'immagine
% definita dalla matrice ImIn (bitmap) definito nel seguente modo
%              (0,0) _________________ XI = Colonne
%                   | 
%                   |
%                   |    Immagine             XImax = C
%                   |     MATLAB        
%                   |                         YImax = R
%                   |
%                   | YI = Righe
    
% SITEMA DI RIFERIMENTO PER LA RAPPRESENTAZIONE DEI PUNTI COME GRAFICO SNAKE
           
% L'istruzione seguente considera il sistema di riferimento associato al grafico
% dello snake definito nel seguente modo
%                Y  |                              
%                   |                          Xmax = C
%                   |                          
%                   |    Grafico               Ymax = R 
%                   |  
%                   |
%                   | 
%              (0,0) --------------- X
     
% La matrice di rotazione e il vettore di traslazione trasformano le coordinate
% date nel sistema "Grafico" in quello "Immagine" per poterli sovrapporre.
     

% =======================================================================================
%    -1) ANALISI INGRESSI
% =======================================================================================

if (nargin<4)
   
   error('Dati in ingresso non sufficienti');
   
end

% R: n.ro di righe; C: n.ro di colonne; ncomp: n.ro di componenti per pixel.
vIm=size(ImIn);
R=vIm(1);
C=vIm(2);

if (length(vIm)==2)
   
   % Immagine in scala di grigio 
   ncomp=1;
   
else 
   
   % Immagine vettoriale
   ncomp=vIm(3);
   
end

% - Definizione della rototraslazione per trasformare le coordinate definite nel
%   sistema "Immagine" a quelle definite in "Grafico".

% Matrice di rotazione
rot=[1 0; 0 -1];
% Vettore di traslazione
tras=[0; R];

% **************************************************************************************

% ======================================================================================
%    -2)
%        
%    N.B. E' importante che i Control Points siano ordinati in senso ANTIORARIO
%         perché il calcolo successivo delle normali esterne è basato sull'hp
%         che l'orientamento (positivo) dello snake sia quello antiorario   
% ======================================================================================


% **************************************************************************************

% ======================================================================================
%    -3) COMPLETAMENTO C. P.
% ======================================================================================

% Momentaneamente sospeso.

% **************************************************************************************

% ======================================================================================
%    -4) COSTRUZIONE DELLE MATRICI [A As Ass]
%        Funzioni dei parametri (Ni) e della matrice (M) 
% ======================================================================================

% Calcolo del nuovo Ns
Ns=length(Q);

% Ni: vettore (1 x Ns) con il n.ro di intervalli in cui si suddivide ciascun span;
%     che coincide con il n.ro di campioni per span.
%     Da questo si ottengono Ni campioni per ogni span per cui calcolare
%     l'incremento che porta alla definizione del nuovo snake.

Ni=4*ones(1,Ns); %hp di Ni costante per ogni span

% Npunti: il n.ro totale di punti considerati per lo snake
Npunti=sum(Ni);

% A, As, Ass: (Npunti x Ns) lista matrici che legano i p.ti X a Q (Npunti=sum(Ni))
%        
%             X = A*Q    e    dX/ds = As*Q    e    d2X/ds2 = Ass*Q

% Costruzione delle nuove matrici A As Ass
[A, As, Ass]=matrici_Bspline(Ni);

% --------------------------------------------------------------------------------------

% Costruzione del grafico dello snake allo stato zero
G=A*Q; %(Npunti x 2) vettore p.ti snake


% Visualizzazione curva - snake nel sistema di riferimento "Grafico".
n_figure=n_figure+1;
figure(n_figure);
set(gca,'Xlim',[0 C]);
set(gca,'YLim',[0 R]);
hold on;
% - traccia C.P.
plot(Q(:,1),Q(:,2),'r*');
% - traccia grafico snake
%   (curva chiusa)
plot([G(:,1);G(1,1)],[G(:,2);G(1,2)],'k-');

title('Grafico iniziale');

% Visualizzazione immagine originale con snake
n_figure=n_figure+1;
figure(n_figure);
imshow(ImIn);
hold on;
% - Roto-traslazione inversa: per le proprietà della trasformazione considerata
%   l'inversa è uguale alla traslazione diretta.
G_I=rot_tras(G,length(G),rot,tras);
plot([G_I(:,1);G_I(1,1)],[G_I(:,2);G_I(1,2)],'w-');

title('Contorno iniziale');


% **************************************************************************************

% ======================================================================================
%   -5) PREELABORAZIONE DELL'IMMAGINE
% ======================================================================================

% E' effettuata precedentemente all'applicazione di <snake.m>.


% **************************************************************************************

% --------------------------------------------------------------------------------------
%                     INIZIO CICLO DI EVOLUZIONE PER LO SNAKE              
% --------------------------------------------------------------------------------------

% tempo_totale: tempo totale esecuzione cicli 
tempo_totale=0;

% Energia totale ad ogni passo.
E=zeros(1,200); % Per un massimo di 200 passi (eventualmente aumentabile)

% L=Lo+Le: ampiezza banda attorno snake di riferimento 
Le=input('Banda esterna (0 se tutto l''esterno della curva) = '); 
Li=input('Banda interna (0 se tutto l''interno della curva) = '); 

disp('Inizio evoluzione snake...');

% stop = 1 -> Continua l'evoluzione dello snake - stop = 0 Termina
stop=1;

% Contatore del numero di passi di evoluzione
contatore=0;


while (stop>0)
   
   %tic % Start cronometro
   
   contatore=contatore+1;
   
   %Nota. Ns, Ni, Npunti vengono aggiornati alla fine di ogni ciclo se si
   %      verificano delle variazioni nelle caratteristiche dello snake-Bspline
   
     
   % Vettore coordinate nuovi punti di contatto
   Gnc=zeros(Npunti,2);
   
   % Vettore dei nuovi control points
   Qn=zeros(Ns,2);
   
   % ================================================================================
   %    -6) CALCOLO DELLE FORZE ESTERNE CHE AGISCONO SULLO SNAKE 
   %        CALCOLO DEI NUOVI PUNTI DI CONTATTO PER LO SNAKE
   % ================================================================================
   
   tic
   
   % Rs: matrice dei vettori tg allo snake nei punti considerati dX/ds
   Rs=As*Q; %(Npunti x 2)
   
   % Rss: matrice dei vettori d2X/ds2 (per il calcolo della curvatura)
   Rss=Ass*Q; %(Npunti x 2);
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per il calcolo di Rs e Rss = %g s \n',tempo);
      
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   % Mne: matrice delle normali esterne 
   Mne=zeros(Npunti,2); %(Npunti x 2)
   
   % Vks: vettore curvature (modulo e segno)
   Vks=zeros(Npunti,1); %(Npunti x 1)
   
   tic
   
   for i=1:Npunti
   
      % -6a) Calcolo della normale esterna (vne) allo snake-spline nell'i-esimo punto. 
      %      Si ricava la normale esterna nell'hp di orientamento positivo antiorario
      %      per la curva, ovvero l'orientamento della superficie è positivo se uscente
      %      dallo schermo.

      rs=Rs(i,:); %(1 x 2)
      % Hp: Vettori Riga!
      % vne: versore normale esterna 
      %                      _    _                          _  _      _  _
      %                     | 0 -1 |                        | rx |    | ry |
      % vne =  rn*T con T = | 1  0 | in modo da ottenere da | ry | -> |-rx |    
      %                      -    -                          -  -      -  -
      % con rn versore tg (ottenuto normalizzando rs)
      
      rs_n=rs/norm(rs); %(1 x 2)
      
      % vne versore normale esterno nel punto i-esimo
      Mne(i,:)=[rs_n(2), -rs_n(1)]; %(1 x 2) vettore riga
                  
      % -6b) Calcolo della curvatura con segno nel punto i-esimo dello snake.
      
      rss=Rss(i,:);
      % ks: vettore curvatura con segno
      %
      %     ks = ( rs /\ rss ) / |rs|^3   ( /\ prodotto esterno )
      %
      %     Risulta ortogonale al piano immagine; quindi se lo si moltiplica per rs_n
      %     _                       _    _        _                 _
      %     ks = ks /\ rs_n   con   ks = k*vne,  |ks| = |ks| e sign(ks) = sign(ks)
      %                     
      %     quindi si può considerare per il solo modulo e segno quelli dati da ks   
      Vks(i)=(rs(1)*rss(2)-rs(2)-rss(1))/(norm(rs)^3);

   end
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per il calcolo delle normali esterne = %g s \n',tempo);
      
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   if (visualizza==2)
      
      %Gf=G+10*Mne; 
      Gf=G+10*Mne;
      % Visualizzazione delle normali esterne
      n_figure=n_figure+1;
      figure(n_figure);
      plot(G(:,1),G(:,2),'r');
      hold on;
      plot(Gf(:,1),Gf(:,2),'b.');
     
   end
   
   
   % -6c) Calcolo dei parametri statistici interni ed esterni allo snake.
   
   % Costruzione degli snakes interni ed esterni definiti rispetto allo
   % snake di riferimento
   
   % Gi(x,y) = G(x,y) - Li*ne      snake interno
   
   % Ge(x,y) = G(x,y) + Le*ne      snake esterno
   
   % con L=Li+Le ampiezza della fascia attorno allo snake di riferimento e ne normale esterna 
   
   Gi=zeros(Npunti,2);
   Ge=zeros(Npunti,2);
   
   tic
   
   % Gi e Ge definite nel sistema di riferimento "Grafico".
   
   for i=1:Npunti
      
      Gi(i,:)=G(i,:)-Li*Mne(i,:); %(Npunti x 2)
      
      Ge(i,:)=G(i,:)+Le*Mne(i,:); %(Npunti x 2)
      
   end
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per Gi e Ge = %g s \n');
       
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   % Considerando il poligono che approssima lo snake, i cui vertici sono costituiti
   % dai punti-campioni dello snake, si ottiengono le maschere che individua i pixel
   % compresi fra G e Gi ("interni") e fra Ge e G ("esterni").
   
   tic
   
   % G,Gi,Ge vanno considerate nel sistema di riferimento "Immagine".
   
   G_I=rot_tras(G,Npunti,rot,tras);
   Gi=rot_tras(Gi,Npunti,rot,tras);
   Ge=rot_tras(Ge,Npunti,rot,tras);
   
   Mask_G=zeros(R,C);
   Mask_G=double(roipoly(Mask_G,G_I(:,1),G_I(:,2)));
   
   if (Li>0)
      
      % Solo una parte della regione interna delimitata dalla banda Li
      Mask_Gi=zeros(R,C);
      Mask_Gi=double(roipoly(Mask_Gi,Gi(:,1),Gi(:,2)));
      
      % Maschera per area interna
      Mask_int=Mask_G.*not(Mask_Gi);
      
   else %(Li==0) 
      
      % Tutta la regione interna
      Mask_int=Mask_G;
      
   end
   
   if (Le>0)
      
      % Solo una parte della regione esterna delimitata dalla banda Le
      Mask_Ge=zeros(R,C);
      Mask_Ge=double(roipoly(Mask_Ge,Ge(:,1),Ge(:,2)));
   
      % Maschera per area esterna
      Mask_est=Mask_Ge.*not(Mask_G);
      
   else %(Le==0)
      
      % Tutta la regione esterna allo snake
      Mask_est=not(Mask_G);
      
   end
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per le <Maschere> = %g s \n',tempo);
      
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   if (visualizza==3)
      
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Mask_G);
      title('Maschera di riferimento G');
      
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Mask_int);
      title('Maschera per Area Interna');
      
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Mask_est);
      title('Maschera per Area Esterna');
            
   end
   
   tic
   
   % Considero il vettore di indici degli elementi di Mask_int e Mask_est non nulli
   ind_int=find(Mask_int);
   ind_est=find(Mask_est);
   
   % Aree in numero di pixel
   % Area interna = lunghezza vettore ind_int 
   A_i=length(ind_int);
   % Area esterna = lunghezza vettore ind_est
   A_e=length(ind_est);
   
   % Per il calcolo dei parametri (media, varianza, ecc.) bisogna considerare il caso generale 
   % di immagine vettoriale per cui i valori medi sono dei vettori di n.ro "ncomp" elementi
   
   if (media_varianza==1)
      
      Media_int=zeros(1,ncomp);
      Media_est=zeros(1,ncomp);
      
   else
      
      Varianza_est=zeros(1,ncomp);
      Varianza_est=zeros(1,ncomp);
      
   end
   
   
     
   for nv=1:ncomp
      
      Im_nv=ImIn(:,:,nv);
      % Matrice di pixel della parte di immagine interna allo snake
      %Im_int=Im_nv(ind_int); % (*) O4
      % Matrice di pixel della parte di immagine esterna allo snake
      %Im_est=Im_nv(ind_est); % (*) O4
      
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
      if (media_varianza==1)
         
         % Sfruttando i vettori di indici: ind_int e ind_est
         
         % Media dei valori interni allo snake
         Media_int(nv)=mean2(Im_nv(ind_int));
         % Media dei valori esterni allo snake
         Media_est(nv)=mean2(Im_nv(ind_est));
      
         % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
      else   
      
         % Somma degli scarti quadratici dei valori interni allo snake
         S_sq_i=sum(sum((Im_int-Media_int(nv)).^2));
         % Somma degli scarti quadratici dei valori esterni allo snake
         S_sq_e=sum(sum((Im_est-Media_est(nv)).^2));
      
         % Varianza dei valori interni allo snake
         Varianza_int(nv)=S_sq_i/A_i;            
         % Varianza dei valori esterni allo snake
         Varianza_est(nv)=S_sq_e/A_e;
         
      end
      
   end
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per indici,aree,medie-varianze = %g s \n',tempo);
      
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   tic
   
   % -6e) Le coordinate dei nuovi punti di contatto per lo snake al passo k+1-esimo 
         
   %      G(k+1) = G(k) + dG(k)
   
   % VdG: vettore dG/dt - utile per il confronto con il termine associato alla curvatura
   VdG=zeros(Npunti,1);
   
   for i=1:Npunti
      
      if (media_varianza==1)
         
         dG_M_A=0; % Valori normalizzati rispetto aree
         %dG_M=0; %  Valori non normalizzati rispetto aree
         
      else
         
         dG_V_A=0; %  Valori normalizzati rispetto aree
         dG_V=0; %  Valori non normalizzati rispetto aree
         
      end
      
      % Considerando il caso generale di immagine vettoriale
      for nv=1:ncomp
         
         % Pixel corrispondeti ai punti dello snake
         % Att.ne. Bisogna considerare la trasformazione tra coordinate XI-YI
         %         con Righe-Colonne: XI -> Righe, YI -> Colonne.  
         % G_I è definita nel sistema di riferimento "Immagine".
         rpx=ceil(G_I(i,2));
         cpx=ceil(G_I(i,1));
         
         % Valori grandezze
         %Ixy=ImIn(rpx,cpx,nv);
         k_W=(n_W-1)/2;
         W=ImIn(rpx-k_W:rpx+k_W,cpx-k_W:cpx+k_W,nv);
         Ixy=median(W(:));
         
         if (media_varianza==1)
            
            M_i=Media_int(nv);
            M_e=Media_est(nv);
            
         else
            
            V_i=Varianza_int(nv);
            V_e=Varianza_est(nv);
            
         end
         
         
         if (media_varianza==1)
            
            % Normalizzando rispetto aree
           
            dG_M_A=dG_M_A+(M_i-M_e)*((Ixy-M_i)/A_i+(Ixy-M_e)/A_e);
            
            % Senza normalizzazione rispetto aree

            %dG_M=dG_M+(M_i-M_e)*((Ixy-M_i)+(Ixy-M_e));
            
         else
            
            % Normalizzando rispetto aree
            
            dG_V_A=dG_V_A+(V_i-V_e)*(((Ixy-M_i)^2-V_i)/A_i+((Ixy-M_e)^2-V_e)/A_e);
         
            % Senza normalizzazione rispetto aree
         
            dG_V=dG_V+(V_i-V_e)*(((Ixy-M_i)^2-V_i)+((Ixy-M_e)^2-V_e));
            
         end
         
      end
      
      
      % Scelgo fra i parametri
      dG=dG_M_A;
      
      % Da indicazione della "forza" a cui è soggetto il campione i-esimo dello
      % snake; dalla loro entità posso ricavare informazioni sulla complessità
      % della forma dell'oggetto in esame e predisporre un numero adeguato di
      % g.d.l. (control points) allo snake stesso.
      VdG(i)=dG; 
      
      % Si considera il guadagno g_dt_i dipendente dalla curvatura, in modo che 
      % a punti con alta curvatura corrisponda un guadagno minore. 
      
      
      % G,Gnc definiti nel sistema di riferimento "Grafico".
      
      %Gnc(i,:)=G(i,:)+g_dt*(dG-g_curv*Vks(i))*Mne(i,:); %(Npunti x 2)
      %Gnc(i,:)=G(i,:)+g_dt*dG*Mne(i,:); %(Npunti x 2)
      Gnc(i,:)=G(i,:)+g_dt*guadagno(g_curv,Vks(i))*dG*Mne(i,:); %(Npunti x 2)

      
   end
   
   % Energia totale dello snake.
   E(contatore)=sum(VdG.^2);
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per le nuove coordinate = %g s \n',tempo);
      
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   if (visualizza==4)
      
      % Normalizzazione di VdG rispetto al suo valore massimo in valore assoluto.
      % Risulta pertanto -1 <= VdG <= 1.
      %VdG=VdG/max(abs(VdG));
      
      n_figure=n_figure+1;
      figure(n_figure);
      subplot(2,1,1);
      plot(VdG);
      title('Complessità Oggetto in esame');
      
      subplot(2,1,2);
      %plot(Vks);
      %title('Curvatura');
      plot(E);
      title('Energia Snake');
      
   end
  
   if (visualizza==5)
      
      % Visualizzazione vettori spostamento Gnc-G
      n_figure=n_figure+1;
      figure(n_figure);
      set(gca,'XLim',[0 C]);
      set(gca,'YLim',[0 R]);
      hold;
      Gg=rot_tras(G,Npunti,rot,tras);
      Gncg=rot_tras(Gnc,Npunti,rot,tras);
      plot(Gg(:,1),Gg(:,2),'ko');
      for i=1:Npunti
         l=line([Gg(i,1) Gncg(i,1)],[Gg(i,2) Gncg(i,2)]);
         set(l,'Color',[1 0 0]);
      end
      title('Vettori spostamento');
     
   end
  
   % ***********************************************************************************
   
   % ===================================================================================
   %    -7) COSTRUZIONE DELLO SNAKE A B-SPLINE CHE MEGLIO APPROSSIMA I NUOVI
   %        PUNTI DI CONTATTO -> NUOVI CONTROL POINTS
   % ===================================================================================
   
   tic
   
   % A partire dall'espressione X = A*Q, noti i punti X si vuole determinare Q 
   
   % Una soluzione risulta   Q = B*X, con B=inv(A'A)*A'
      
   B=inv(A'*A)*A'; %(Ns x Npunti)
      
   Qn=B*Gnc; %(Ns x 2)
   
   % Quindi ricalcolo il nuovo snake a B-spline.
   % definito nel sistema di riferimento "Grafico".
   
   G=A*Qn;
   
   Q=Qn;
   
   %
   tempo=toc;
   
   if (visualizza_tempo~=0)
      
      fprintf(1,'Tempo per i nuovi c.p. = %g s \n',tempo);
      
   end
   
   tempo_totale=tempo_totale+tempo;
   %
   
   % ********************************************************************************
         
   % ===================================================================================
   %    -8) OTTIMIZZAZIONE DEI CONTROL POINTS   
   %        In base alle proprietà geometriche dello snake-spline (smoothness - loop)         
   % ===================================================================================
   
   % procedura momentaneamente sospesa
   
   % ***********************************************************************************
   
   % ===================================================================================
   %    -9) RITORNA AL PASSO -6)
   %        Definizione delle condizioni di termine esecuzione evoluzione
   % ===================================================================================
   
   npassi_stop=10;
   
   %Visualizzazione del risultato dell'evoluzione (per fase di debug)
   if (rem(contatore,npassi_stop)==0)
      
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(ImIn); 
      hold on;
      % G_I = G nel sistema di riferimento "Immagine"
      G_I=rot_tras(G,length(G),rot,tras);
      plot([G_I(:,1);G_I(1,1)],[G_I(:,2);G_I(1,2)],'w-');
      
   end
   
   if (rem(contatore,npassi_stop)==0)
      stop=input('Continua -> 1 -+- Termina -> 0 ');
   end
   
   % ***********************************************************************************
   
end

%-------------------------- FINE CICLO EVOLUZIONE SNAKE --------------------------------

fprintf(1,'Tempo totale di evoluzione snake = %g s ...\n',tempo_totale);

fprintf(1,'...in un numero di %g passi.\n',contatore); 

Q_snake=Q;

close all

%OSSERVAZIONI CONCLUSIVE

% O1) Le diverse scelte e i parametri devono essere selezionabili con pulsanti, slider, ...

% O2) La matrice A (e quindi B) è costante se non varia il numero di campioni considerato; 
%     tale variazione potrebbe essere considerata nel momento in cui si voglia migliorare
%     la definizione dello span: in corrispondenza di span molto lunghi, oppure 
%     caratterizzati da elevata curvatura...

% O3) Per quanto riguarda la banda L si potrebbe rendere possibile un suo restringimento
%     quando si verifica che si è prossimi alla convergenza.

% O4) Considerare MATRICI SPARSE dove conveniente
%     Vedere se è conveniente introdurre test su sparseness dopo operazioni con full-matrix
%     ( Vedi operazioni con (*) O4 )

% O5) Permettere di impostare in modo diverso le "bande" interna ed esterna
