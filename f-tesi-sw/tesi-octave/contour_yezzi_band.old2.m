%function Im_snake = contour_yezzi_band ( ImIn )
% *) ImIn: matrice intensità immagine
%          - (R x C) nel caso di immagine in scala di grigio
%          - (R x C x nvalori) nel caso di immagine vettoriale
%            ( nvalori: il n.ro di valori per ogni pixel; associati all trasformazione
%                       sull'immagine realizzata in ingresso ) 
% *) Im_snake: restituisce immaggine con contorno individuato

% +) Modello snake: composizione di span definiti per mezzo di B-splines
%                   Ogni span è caratterizzato dalla shape matrix M 


% -1) L'utente individua un n.ro sufficientemente elevato di p.ti.
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

function Im_snake = contour_yezzi_band ( ImIn )

% =======================================================================================
%    -0) Definizione e inizializzazione delle variabili di uso generale
% =======================================================================================
n_figure=0; % Contatore figura attiva

visualizza=0; % Stato di visualizzazione risultati parziali (per DEBUG)

No=4; % N.ro minimo di p.ti per definire l'area occupata dall'oggetto in esame

% Fattore generato dalla discretizzazione di dG/dt.
% Nel caso della discretizzazione secondo Eulero 
%
%                       dG/dt = ( G(t+dt) - G(t) ) / dt
% e quindi si ha 
%
%                G(t+dt) = G(t) + (1/dt)*(dG/dt) = G(t) + g_dt*(dG/dt).
%
% Att.ne. La scelta di tale "guadagno", ovvero del passo di discretizzazione,
%         condiziona la convergenza in quanto può portare lo snake a "saltare"
%         lo stato di minima energia.
%
% Riassumendo         g_dt = 1/dt

% media_varianza: per la scelta del parametro statistico che caratterizza la ROI
%                 1 - se media
%                 2 - se varianza
media_varianza=1;

g_dt=.1e5; %.4e5; % media con area

%g_dt=3; %10 - 6 - 3 - 1 media senza area
%----------------------------------------------

%g_dt=.8e5; % varianza con area

% Fattore che pesa il contributo del termine di curvatura, ovvero associato
% alla condizione energetica di minima lunghezza dello snake.

%g_curv=.00002; %.00002; %Media con area

g_curv=0; %.1; % media senza area

%-----------------------------------------------
%g_curv=.00008; %Varianza



% =======================================================================================
%    -1) INTERFACCIA UTENTE: RICHIESTA CONTROL POINTS VICINI AL BORDO
%                            DELL'OGGETTO DI INTERESSE 
% =======================================================================================

% R: n.ro di righe; C: n.ro di colonne; colori: n.ro di valori definiti per ogni pixel.
vIm=size(ImIn);
R=vIm(1);
C=vIm(2);

if (length(vIm)==2)
   
   % Immagine in scala di grigio 
   nvalori=1;
   
else 
   
   % Immagine vettoriale
   nvalori=vIm(3);
   
end

% - Definizione dei control points del contorno di partenza
% Definizione della finestra di lavoro
n_figure=n_figure+1; % n_figure=1
figure(n_figure);
set(gcf,'MenuBar','none');
set(gcf,'NumberTitle','off');
set(gcf,'Name','SNAKE');
axis ij;
set(gca,'XTick',[]);
set(gca,'XTickLabel',[]);
set(gca,'XColor',[1 1 1]);
set(gca,'YTick',[]);
set(gca,'YTickLabel',[]);
set(gca,'YColor',[1 1 1]);

hold;
% Visualizzazione immagine bitmap
imshow(ImIn);

% Visualizzazione scala di riferimento per l'impostazione dei parametri spaziali
l_scala=line([10 20],[10 10]);
set(l_scala,'Color',[1 1 1]);
l_scala=line([10 10],[8 12]);
set(l_scala,'Color',[1 1 1]);
l_scala=line([20 20],[8 12]);
set(l_scala,'Color',[1 1 1]);

testo=text(12,6,'10');
set(testo,'Fontsize',[8]);
set(testo,'Color',[1 1 1]);



% Lettura del p.to nell'immagine originale

tasto=1;
conta_cp=0;

while (tasto~=27)
   
   conta_cp=conta_cp+1;
   
  
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
     
   % La trasformazione seguente mette in relazione le coordinate nei due sistemi di 
   % riferimento in modo che l'immagine (bitmap) e il grafico dello snake in x-y
   % siano confrontabili direttamente. 
      
   % Matrice di rotazione
   rot=[1 0; 0 -1];
   % Vettore di traslazione
   tras=[0; R];
      
   % Lettura coordinate punto sull'immagine da elaborare   
   [xI,yI,tasto]=ginput(1); 
   
        
   if (tasto~=27)
      
      % Se non si è premuto il tasto >Esc<
      
      % Le coordinate dei p.ti vengono definite nel sistema di riferimento XI-YI
      Q(conta_cp,:)=[xI yI];
      
   elseif ((tasto==27)&(conta_cp<4))

      % Si è premuto il tasto >Esc<: si verifica che si abbiano almeno 4 p.ti
      
      disp('Errore! Sono necessari almeno 4 punti.'); 
      disp('Premere un tasto per continuare.')
      pause
      
      tasto=1;
      
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

%Qsa=ordina_sa(Q);

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

% Ni: vettore (1 x Ns) con il n.ro di intervalli in cui si suddivide ciascun span.
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

% Visualizzazione curva - snake  
n_figure=n_figure+1;
figure(n_figure);
set(gca,'Xlim',[0 C]);
set(gca,'YLim',[0 R]);
hold;
% - traccia C.P.
Qg=rot_tras(Q,Ns,rot,tras);
plot(Qg(:,1),Qg(:,2),'r*');
% - traccia grafico snake
%   (curva chiusa)
Gg=rot_tras(G,Npunti,rot,tras);
plot(Gg(:,1),Gg(:,2),'k-');

title('Grafico iniziale');

% Visualizzazione immagine originale con snake
n_figure=n_figure+1;
imshow(ImIn);
hold on;
plot(G(:,1),G(:,2),'w-');

title('Contorno iniziale');


% **************************************************************************************

% ======================================================================================
%   -5) PREELABORAZIONE DELL'IMMAGINE
% ======================================================================================

%disp('Preelaborazione dell''immagine');

% -5a)

%ordine_m=input('Ordine del filtro mediano ( 0 per saltarlo ) = ');

%if (ordine_m~=0)
   
%   ImIn=medfilt2(ImIn,[ordine_m,ordine_m]);
   
   % Visualizzazione risultato applicazione median-filter
%   n_figure=n_figure+1;
%   figure(n_figure);
%   imshow(ImIn);
   
%end



% **************************************************************************************

% --------------------------------------------------------------------------------------
%                     INIZIO CICLO DI EVOLUZIONE PER LO SNAKE              
% --------------------------------------------------------------------------------------

% L=Lo+Le: ampiezza banda attorno snake di riferimento 

Le=input('Banda esterna (0 se tutto l''esterno della curva) = '); 
Li=input('Banda interna (0 se tutto l''interno della curva) = '); 

disp('Inizio evoluzione snake...');

% stop = 1 -> Continua l'evoluzione dello snake - stop = 0 Termina
stop=1;

% Contatore del numero di passi di evoluzione
contatore=0;


while (stop>0)
   
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
   
   % Rs: matrice dei vettori tg allo snake nei punti considerati dX/ds
   Rs=As*Q; %(Npunti x 2)
   
   % Rss: matrice dei vettori d2X/ds2 (per il calcolo della curvatura)
   Rss=Ass*Q; %(Npunti x 2);
   
   % Mne: matrice delle normali esterne 
   Mne=zeros(Npunti,2); %(Npunti x 2)
   
   % Vks: vettore curvature (modulo e segno)
   Vks=zeros(Npunti,1); %(Npunti x 1)
   
   for i=1:Npunti
   
      % -6a) Calcolo della normale esterna (vne) allo snake-spline nell'i-esimo punto. 
      %      Si ricava la normale esterna nell'hp di orientamento positivo antiorario
      %      per la curva, ovvero l'orientamento della superficie è positivo se uscente
      %      dallo schermo.

      rs=Rs(i,:); %(1 x 2)
      % vne: versore normale esterna 
      %                       _    _                          _  _      _  _
      %                      | 0 -1 |                        | rx |    | ry |
      % vne = - rn*T con T = | 1  0 | in modo da ottenere da | ry | -> |-rx |    
      %                       -    -                          -  -      -  -
      % con rn versore tg (ottenuto normalizzando rs)
      
      % Oss. Il segno negativo dipende dal fatto che nel sistema di rif. XI-YI
      %      l'asse ZI è entrante nel piano immagine mentre è uscente nel sistema
      %      di riferimento X-Y.
      %      Ciò significa che considerando il sistema XI-YI-ZI è ottenuto con una
      %      rotazione di "pi" rad alltorno all'asse X (o XI nel caso inverso):
      %                  _      _
      %                 | 1  0  0|      
      %         rot3D = | 0 -1  0|
      %                 | 0  0 -1|
      %                  -      -
      rs_n=rs/norm(rs); %(1 x 2)
      
      % vne versore normale esterno nel punto i-esimo
      Mne(i,:)=-[rs_n(2), -rs_n(1)]; %(1 x 2) vettore riga
            
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
   
   
   % -6c) Calcolo dei parametri statistici interni ed esterni allo snake.
   
   % Costruzione degli snakes interni ed esterni definiti rispetto allo
   % snake di riferimento
   
   % Gi(x,y) = G(x,y) - Li*ne      snake interno
   
   % Ge(x,y) = G(x,y) + Le*ne      snake esterno
   
   % con L=Li+Le ampiezza della fascia attorno allo snake di riferimento e ne normale esterna 
   
   Gi=zeros(Npunti,2);
   Ge=zeros(Npunti,2);
   
   for i=1:Npunti
      
      Gi(i,:)=G(i,:)-Li*Mne(i,:);
      
      Ge(i,:)=G(i,:)+Le*Mne(i,:);
      
   end
      
   % Considerando il poligono che approssima lo snake, i cui vertici sono costituiti
   % dai punti-campioni dello snake, si ottiengono le maschere che individua i pixel
   % compresi fra G e Gi ("interni") e fra Ge e G ("esterni").
   
   Mask_G=zeros(R,C);
   Mask_G=double(roipoly(Mask_G,G(:,1),G(:,2)));
   
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
   
   if (visualizza==3)
      
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Mask_int);
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Mask_est);
      title('Maschera per il calcolo di aree e medie');
      pause
      
   end
   
   % Aree in numero di pixel
   % Area interna = somma di tutti i pixel a "1" in Mask_int
   A_i=sum(sum(Mask_int));
   % Area esterna = Area totale - Area interna
   A_e=sum(sum(Mask_est));
   
   % Per il calcolo dei parametri (media, varianza, ecc.) bisogna considerare il caso generale 
   % di immagine vettoriale per cui i valori medi sono dei vettori di n.ro "nvalori" elementi
   
   if (media_varianza==1)
      
      Media_int=zeros(1,nvalori);
      Media_est=zeros(1,nvalori);
      
   else
      
      Varianza_est=zeros(1,nvalori);
      Varianza_est=zeros(1,nvalori);
      
   end
   
   % Oss. Non è possibile calcolare la media con "mean2" in quanto questa tiene conto di 
   %      tutti gli elementi delle matrici Im_int e Im_est e quindi anche dei valori nulli
   %      che invece non vanno considerati. 
   %      Analogamente per gli altri parametri statistici.
   
     
   for nv=1:nvalori
      
      % Matrice di pixel della parte di immagine interna allo snake
      Im_int=Mask_int.*ImIn(:,:,nv);
      % Matrice di pixel della parte di immagine esterna allo snake
      Im_est=Mask_est.*ImIn(:,:,nv);
      
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
      if (media_varianza==1)
         
         % Somma dei valori interni allo snake
         S_i=sum(sum(Im_int));
         % Somma dei valori interni allo snake
         S_e=sum(sum(Im_est));
   
         % Media dei valori interni allo snake
         Media_int(nv)=S_i/A_i;
         % Media dei valori esterni allo snake
         Media_est(nv)=S_e/A_e;
      
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
   
   % -6e) Le coordinate dei nuovi punti di contatto per lo snake al passo k+1-esimo 
         
   %      G(k+1) = G(k) + dG(k)
   
   % VdG: vettore dG/dt - utile per il confronto con il termine associato alla curvatura
   VdG=zeros(1,Npunti);
   
   for i=1:Npunti
      
      if (media_varianza==1)
         
         dG_M_A=0; % Valori normalizzati rispetto aree
         dG_M=0; %  Valori non normalizzati rispetto aree
         
      else
         
         dG_V_A=0; %  Valori normalizzati rispetto aree
         dG_V=0; %  Valori non normalizzati rispetto aree
         
      end
      
      % Considerando il caso generale di immagine vettoriale
      for nv=1:nvalori
         
         % Pixel corrispondeti ai punti dello snake
         % Att.ne. Bisogna considerare la trasformazione tra coordinate XI-YI
         %         con Righe-Colonne: XI -> Righe, YI -> Colonne.   
         rpx=ceil(G(i,2));
         cpx=ceil(G(i,1));
         
         % Valori grandezze
         Ixy=ImIn(rpx,cpx,nv);
         
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

            dG_M=dG_M+(M_i-M_e)*((Ixy-M_i)+(Ixy-M_e));
            
         else
            
            % Normalizzando rispetto aree
            
            dG_V_A=dG_V_A+(V_i-V_e)*(((Ixy-M_i)^2-V_i)/A_i+((Ixy-M_e)^2-V_e)/A_e);
         
            % Senza normalizzazione rispetto aree
         
            dG_V=dG_V+(V_i-V_e)*(((Ixy-M_i)^2-V_i)+((Ixy-M_e)^2-V_e));
            
         end
         
      end
      
      
      % Scelgo fra i parametri
      dG=dG_M_A;
       
      VdG(i)=dG;

      Gnc(i,:)=G(i,:)+g_dt*(dG-g_curv*Vks(i))*Mne(i,:); %(Npunti x 2)
      %Gnc(i,:)=G(i,:)+g_dt*dG*Mne(i,:); %(Npunti x 2)
   
   end
   
   if (visualizza==2)
      
      n_figure=n_figure+1;
      figure(n_figure);
      subplot(2,1,1);
      plot(VdG);
      title('Azione Immagine');
      subplot(2,1,2);
      plot(Vks);
      title('Azione curvatura');
      pause
      
   end
  
   if (visualizza==1)
      
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
      
   % A partire dall'espressione X = A*Q, noti i punti X si vuole determinare Q 
   
   % Una soluzione risulta   Q = B*X, con B=inv(A'A)*A'
      
   B=inv(A'*A)*A'; %(Ns x Npunti)
      
   Qn=B*Gnc; %(Ns x 2)
   
   % Quindi ricalcolo il nuovo snake a B-spline
   
   G=A*Qn;
   
   Q=Qn;
   
   % ********************************************************************************
         
   if (visualizza==2)
      
      % Confronto tra i p.ti di Gnc e lo snake-spline approssimazione
      n_figure=n_figure+1;
      figure(n_figure);
      set(gca,'XLim',[0 C]);
      set(gca,'YLim',[0 R]);
      hold;
      Gnc_c=[Gnc; Gnc(1,:)];
      Gnc_cg=rot_tras(Gnc_c,Npunti+1,rot,tras);
      Qng=rot_tras(Qn,Ns,rot,tras);
      plot(Gnc_cg(:,1),Gnc_cg(:,2),'k');
      plot(Qng(:,1),Qng(:,2),'r+');
      title('Confronto tra Gnc e c.p.');
      
   end
     
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
   
   npassi_stop=10;
   
   %Visualizzazione del risultato dell'evoluzione (per fase di debug)
   if (rem(contatore,npassi_stop)==0)
      Imp=ImIn;
      Npunti=length(G);
      for np=1:Npunti
         % In base alla trasformazione  XI-YI --> Bitmap 
         rpx=ceil(G(np,2));
         cpx=ceil(G(np,1));
         for nv=1:nvalori
            Imp(rpx,cpx,nv)=1; %.5;
         end
      end
      n_figure=n_figure+1;
      figure(n_figure);
      imshow(Imp); %imagesc(Imp);
   end
   
   if (rem(contatore,npassi_stop)==0)
      stop=input('Continua -> 1 -+- Termina -> 0 ');
   end
   
   % ***********************************************************************************
   
   
end

%-------------------------- FINE CICLO EVOLUZIONE SNAKE --------------------------------

% Chiude le finestre non utili 
close(4:n_figure-1);

n_figure=n_figure+1;
figure(n_figure);
set(gca,'Xlim',[0 C]);
set(gca,'YLim',[0 R]);
hold;
plot(G(:,1),G(:,2));

Im_snake=ImIn;
Npunti=length(G);
for np=1:Npunti
   rpx=ceil(G(np,2));
   cpx=ceil(G(np,1));
   for nv=1:nvalori
      Im_snake(rpx,cpx,nv)=1;
   end
end



%OSSERVAZIONI CONCLUSIVE

% O1) Le diverse scelte e i parametri devono essere selezionabili con pulsanti, slider, ...

% O2) La matrice A (e quindi B) è costante se non varia il numero di campioni considerato; 
%     tale variazione potrebbe essere considerata nel momento in cui si voglia migliorare
%     la definizione dello span: in corrispondenza di span molto lunghi, oppure 
%     caratterizzati da elevata curvatura...

% O3) Per quanto riguarda la banda L si potrebbe rendere possibile un suo restringimento
%     quando si verifica che si è prossimi alla convergenza.

% O4) Considerare MATRICI SPARSE dove conveniente

% O5) Permettere di impostare in modo diverso le "bande" interna ed esterna
