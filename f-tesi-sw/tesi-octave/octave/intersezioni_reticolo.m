function G_np = intersezioni_reticolo ( G,Xmax,Ymax,risoluzione )

% INTERSEZIONI_RETICOLO Determina i p.ti di intersezione fra la curva G() e il 
%                       reticolo di simplex.
%                        
% *) G: grafico curva. (Npunti x 2)
%       La curva è definita dalla poligonale i cui vertici sono i punti di G().
% *) Xmax,Ymax: dimensioni immagine nel sistema di rif. "Grafico".
% *) risoluzione: densità della griglia; definisce in quante parti suddividere
%                 ciascun asse => [2*risoluzione^2] simplexs

% Inizializzazione delle liste dei nuovi p.ti.
% - N.ro di intersezioni (punti) fra il reticolo e ciascun segmento.
N_ps=10;
% - N.ro totale delle intersezioni.
N_int=200;
% Osservazione. La lunghezza di tali liste può variare nel corso dell'elaborazione;
% comunque l'inizializzazione rende la procedura più efficiente.

% Curva chiusa.
G_c=[G; G(1,:)];

% Passi del reticolo lungo X e lungo Y
% - Per le rette Y=k. 
passo_x=Xmax/risoluzione;
% - Per le rette X=k.
passo_y=Ymax/risoluzione;
% - Per le rette Y=mX+q.
passo_q=passo_y;

% m: coefficiente angolare delle diagonali del reticolo.
m=Ymax/Xmax;

% Vettore dei p.ti di intersezione tra il reticolo e la curva = nuovi nodi
G_np=zeros(N_int,2); %(N_int x 2)

% Indice dell'ultima posizione nella lista.
N_np=0;

for i=1:length(G)
   
   % Per ogni segmento Pi - Pi+1 si individuano le rette che possono intersecarlo.
   
   % Contatore numero di intersezioni per il segmneto corrente.
   ind_s=0;
   % Vettore dei valori della parametro s in [0,1] lungo il segmento;
   % per il successivo ordinamento in senso antiorario dei punti ricavati.
   v_s=zeros(N_ps,1); %(N_ps x 1)
   % Vettore delle intersezioni tra segmento e reticolo.
   v_r=zeros(N_ps,2); %(N_ps x 2)
   
   % Segmento i-esimo PoPf i cui estremi rispettano ordine antiorario (positivo).
   % - Po: primo estremo del segmento i-esimo.
   xo=G_c(i,1);
   yo=G_c(i,2);
   % - Pf: secondo estremo del segmento i-esimo.
   xf=G_c(i+1,1);
   yf=G_c(i+1,2);
   
   % Ordinamento delle componenti X e Y (determina la bounding-box).
   v_x=[xo xf];
   v_y=[yo yf];
   [x_ord,ind_x]=sort(v_x);
   [y_ord,ind_y]=sort(v_y);
      
   
   % Calcolo delle intersezioni.
   % a) rette verticali a x=xk costante
   x_min=x_ord(1);
   x_max=x_ord(2);
   
   n_min_xk=ceil(x_min/passo_x);
   n_max_xk=floor(x_max/passo_x);
   % Osservazione. Se xk_min > xk_max nessuna intersezione.
   
   for n_x=n_min_xk:n_max_xk
      
      xk=n_x*passo_x;
         
      if (xk~=xf) % (#1)
      
         d1=xk-xo;
         d2=xf-xk;
         pd=d1*d2;
         
         if (pd>0)
            
            % xk è interno all'intervallo [Pi,Pi+1].
            ind_s=ind_s+1;
            s=(xk-xo)/(xf-xo);
            v_s(ind_s)=abs(s);
            v_r(ind_s,:)=[xk,(yf-yo)*s+yo];
            
         end
      
         if (pd==0)
            
            % Date le condizioni (#1) vale d1=0 -> xk=xo
            ind_s=ind_s+1;
            v_s(ind_s)=0;
            v_r(ind_s,:)=[xk,yo];
            
         end
         
      elseif (xo==xf)
         
         % Assieme alla ~(#1) -> xo=xf=xk
         ind_s=ind_s+1;
         v_s(ind_s)=.5;
         v_r(ind_s,:)=[xk,(yo+yf)/2];
         
      end
   
   end %fine a)
   
   
   y_min=y_ord(1);
   y_max=y_ord(2);
   
   % b) rette orizzontali a y=yk costante.   
   n_min_yk=ceil(y_min/passo_y);
   n_max_yk=floor(y_max/passo_y);
   % Osservazione. Se yk_min > yk_max nessuna possibile intersezione.
   
   for n_y=n_min_yk:n_max_yk
      
      yk=n_y*passo_y;
      
      if (yk~=yf) % (#1)
         
         d1=yk-yo;
         d2=yf-yk;
         pd=d1*d2;
      
         if (pd>0)
            
            % yk è interno all'intervallo Pi Pi+1.
            ind_s=ind_s+1;
            s=(yk-yo)/(yf-yo);
            v_s(ind_s)=abs(s);
            v_r(ind_s,:)=[(xf-xo)*s+xo,yk];
         end
      
         if (pd==0)
            
            % Date le condizioni (#1) vale d1=0 -> yk=yo.
            ind_s=ind_s+1;
            v_s(ind_s)=0;
            v_r(ind_s,:)=[xo,yk];
            
         end
      
      elseif (yo==yf)
      
         %assieme alla ~(#1) -> xo=xf=xk
         ind_s=ind_s+1;
         v_s(ind_s)=.5;
         v_r(ind_s,:)=[(xo+xf)/2,yk];
      
      end
   
   end %fine b)
   
     
   % c) rette diagonali
   
   y_x_min=v_y(ind_x(1));
   y_x_max=v_y(ind_x(2));
   
   q1=y_x_min-m*x_min;
   q2=y_x_max-m*x_max;
   q_min=min([q1,q2]);
   q_max=max([q1,q2]);
   % Noti q_min e q_max si può ricavare quali siano i qi interni all'intervallo 
   % [q_min,q_max] relativi alle diagonali del reticolo.
   n_min_q=ceil(q_min/passo_q);
   n_max_q=floor(q_max/passo_q);
      
   % Intersezioni con rette y=mx+q.
   for n_q=n_min_q:n_max_q
      
      q=n_q*passo_q; 
         
      % Si calcolano gli estremi del segmento di diagonale del reticolo.
      y_x3=m*x_min+q;
      y_x4=m*x_max+q;
         
      % Si considerano i seguenti p.ti:
      % - P1P2 sub span.
      P1=[x_min,y_x_min];
      P2=[x_max,y_x_max];
         
      % - P3P4 retta y=mx+q.
      P3=[x_min,y_x3];
      P4=[x_max,y_x4];
         
      % - Considerati i seguenti prodotti esterni:
      V1=det([P1-P3;P4-P3]);
      V2=det([P2-P3;P4-P3]);
            
      if (V1*V2<0) 
         
         % V1 eV2 hanno segni opposti.
         % Se V1 e V2 hanno segni opposti si ha intersezione "netta".
                  
         % Nel sistema di riferimento "Grafico" i punti che appartengono
         % ai segmenti P1P2 e P3P4 sono definiti in forma parametrica
         %
         %    P12(alfa) = P1 + alfa*v      v = P2 - P1
         %    
         %    P34(beta) = P3 + bata*w      w = P4 - P3
         %
         % dove v e w definiscono le direzioni delle rette su cui giacciono
         % i due segmenti.
         %
         % Il punto di intersezione fra i due segmenti soddisfa le condizioni:
         %
         %    P12(alfa) = P34(beta) ==> P1 + alfa*v = P3 + bata*w 
         %
         % che per ciascuna componente risultano
         %    _
         %   ( P1x + alfa*vx = P3x + bata*wx
         %   -
         %   ( P1y + alfa*vy = P3y + bata*wy
         %    -
         % quindi si risolve il sistema in <alfa> e <beta>.
         %
         % La soluzione utile è data dal valore di <alfa> associato al segmento
         % di curva P1P2.
         
         
         % Osservazione. Si ricorda che i vettori sono vettori riga.
         
         % Vettori direzioni delle rette secanti (devono essere vettori colonna):
         v=(P2-P1);
         w=(P4-P3);
         
         % Parametri delle rette r1 e r2
         alfa_beta=inv([v',-w'])*(P3-P1)';
         s=alfa_beta(1);
         
         % P.to di intersezione.
         ind_s=ind_s+1;
         v_s(ind_s)=s;
         v_r(ind_s,:)=P1+s*v;
         
      end
            
      if ((V1*V2==0)&(V2~=0))
         
         % V1=0 => P3P1 || P3P4 
         % Un estremo del sub-spans appartiene alla retta x=xk;
         % data la condizione [dsj~=1] si ha <dsj=0> => P_i=P1.
         
         % P.to di intersezione. 
         ind_s=ind_s+1;
         v_s(ind_s)=0;
         v_r(ind_s,:)=P1;
         
      end
            
      if ((V1==0)&(V2==0))
         
         disp('Attenzione Rischio');
         pause
         % Il sub-span giace sulla retta x=xk;
         % => si considera come p.to utile il p.to medio.
         
         % P.to di intersezione 
         ind_s=ind_s+1;
         v_s(ind_s)=.5;
         v_r(ind_s,:)=(P1+P2)/2;
         
      end

   end %fine c)
   
   % Determinate le possibili intersezioni tra il reticolo e il segmento
   % si passa ad ordinarle secondo sk crescenti (mantiene ordine antiorario).
   
   % o1) Ordinamento di v_s recuperando gli indici.
   [v_s_ord,v_s_ind]=sort(v_s(1:ind_s));
   
   % o2) Riordino di v_r e costruzione del vettore dei nuovi nodi.
   for k=1:ind_s
      
      G_np(N_np+k,:)=v_r(v_s_ind(k),:);
      
   end
   
   N_np=N_np+ind_s;
   
end %fine segmento

% Riduco la lista agli elementi non nulli
G_np=G_np(1:N_np,:);