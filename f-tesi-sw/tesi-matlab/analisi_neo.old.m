function analisi_neo ( neo )

% ANALISI_NEO ( NEO ) Procedura principale che permette di realizzare l'analisi,
%                     individuazione e misure, del neo nell'immagine NEO (RGB).
%                     [ In futuro il file NEO sar� sostituito da bitmap in
%                       uscita dal frame-grabber ]
%
% Fase 1) Elaborazione dell'immagine:
%         - costruzione della piramide di immagini fino ad una risoluzione minima;
%         - binarizzazione della componente HUE dell'immagine a colori del livello
%           pi� basso (costituisce una prima segmentazione anche se non raffinata);
%           [ non si potrebbe considerare KL-Transform ? o Fisher Disr. Vector ? ]
%         - filtraggio con operatori mediana e morfologici per ottenere una unica
%           componente connessa, approssimazione del neo, possibilmente con contorni
%           sufficientemente smooth (� proprio necessario?).
%
% Fase 2) Applicazione dell'algoritmo di Yezzi per determinare il contorno dell'immagine
%         binaria fino a giungere ad un p.to di equilibrio.
%
% Fase 3) Proiettare il contorno trovato nell'immagine del livello superiore della 
%         piramide.
%         Osservazione. La curva ottenuta � una prima approssimazione del contorno
%         finale e quindi permette di considerare successivamente la versione locale
%         dell'implementazione dell'algoritmo di Yezzi direttamente sull'immagine
%         a colori.
%
% Fase 4) Applicazione dell'algoritmo di segmentazione a snake (Yezzi) fino a giungere
%         ad una nuova condizione di equilibrio.
%
% Fase 5) Se ci sono ancora livelli superiori disponibili si torna alla Fase 3)

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
nfigure=0;
tempototale=0;
visualizza=1;

%         ====================================
%          Fase 1) Elaborazione dell'immagine
%         ====================================

% - Costruzione della piramide di immagini a risoluzione decrescente.
% Problema. Quanti livelli ? 
% Risposta. Considerando che l'immagine di partenza sar� dell'ordine dei
%           576x768 pixel conviene portarsi nell'odine delle decine di pixel
%           per dimensione ovvero al livello L3 (considerando l'immagine L0).
tic

[L1,L2,L3]=pyramidv(neo); 

tempo=toc;
fprintf(1,'Tempo costruzione piramide = %g s \n\n',tempo);
tempototale=tempototale+tempo;

if (visualizza==1)
   
   nfigure=nfigure+1;
   figure(nfigure);
   imshow(L3);
   
end

tic
%
% - Calcolo della componente di Hue dell'immagine del livello L3.

% Nel caso di HUE
HSV=rgb2hsv(L3);
H=HSV(:,:,1);
% Osservazione. In futuro sarebbe conveniente costruire una funzione per il calcolo
% diretto della sola componente di Hue se non se ne fa niente delle altre.
%
tempo=toc;
fprintf(1,'Tempo calcolo di H = %g s \n\n',tempo);
tempototale=tempototale+tempo;

nfigure=nfigure+1;
figure(nfigure);
imshow(H);

tic
%
% - Binarizzazione.
% Problema. Con o senza isteresi ?
% Risposta. Da verificare...Nel caso di isteresi il procedimento � pi� lento.

% Istogramma di Hue.
[histH,binH]=imhist(H);
% Normalizzazione.
% histH_n=histH/prod(size(H));

% Calcolo del valore di soglia.
% Osservazione. Valutare le prestazioni dei diversi metodi.
sH=disc_analysis_bin(histH/prod(size(H))); 

fprintf(1,'Soglia stimata per la componente di Hue = %g \n\n',sH);

H_bin=im2bw(H,sH); % Binarizzazione senza isteresi.
% Osservazione. Per la successiva corretta applicazione degli operatori
% morfologici H_bin deve essere assumere valori "1" in corrispondenza
% dell'oggetto in esame. mentre la funzione IM2BW esegue produce l'opposto.
H_bin=not(H_bin);
%
tempo=toc;
fprintf(1,'Tempo per binarizzazione = %g s \n\n',tempo);
tempototale=tempototale+tempo;

nfigure=nfigure+1;
figure(nfigure);
imshow(H_bin);

tic
%
% - Riduzione dell'immagine binarizzata ad un'unica componente connessa.
% Osservazione1. Bisogna valutare la combinazione migliore degli operatori
% disponibili (mediana, morfologici, componenti connesse per immagini binarie).
% Osservazione2. Nell'applicazione degli operatori bisogna fare attenzione 
% anche alla scelta dello structuring element.
I_morf=H_bin;
clear H_bin; % Elimino la variabile H_bin
I_morf=morf_oper(I_morf,'closing','circolare',5);
I_morf=morf_oper(I_morf,'median','circolare',7);
%
tempo=toc;
fprintf(1,'Tempo applicazione operatori morfologici = %g s \n\n',tempo);
tempototale=tempototale+tempo;

nfigure=nfigure+1;
figure(nfigure);
imshow(I_morf);

tempoelim=tempototale;
fprintf(1,'\r');
fprintf(1,'Tempo totale elaborazione immagine = %g s \n',tempoelim);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         ========================================
%          Fase 2) Contorno dell'immagine binaria
%         ========================================

% Osservazione. Nota l'imagine binaria � semplice ricostruirne il profilo; da questi
% per� bisogna ricostruire la curva a B-spline che l'approssima, ovvero determinare
% i control points. Questo pu� essere effettuato in modo diretto o considerando
% la curva come un active contours (snake) che evolve fino ad ottenere l'approssimazione
% desiderata.
% # Metodo diretto: - si fissa a priori il numero dei c.ps. (oppure di campioni
%                     per span e si calcola il n.ro di c.ps.=n.ro di spans);
%                   - si suddivide il profilo in un numero di segmenti pari al
%                     numero dei c.ps.;
%                   - si ottengono i c.ps. come soluzione di un problema ai MQ.
% # Medoto indiretto: - si fissa una curva iniziale ricavata dalle informazioni
%                       sulla forma (individuare i parametri che la caratterizzano
%                       e la loro interpretazione);
%                     - far evolvere la curva-snake con la legge di aggiornamento 
%                       dell'algoritmo di Yezzi nel caso ottimale di immagine 
%                       perfettamente binaria.

% - Metodo diretto.
% Fissato il numero di punti per span
NpS=4; 

% - Definizione della rototraslazione per trasformare le coordinate definite nel
%   sistema "Immagine" a quelle definite in "Grafico".

[rr,cc]=size(I_morf);

% Matrice di rotazione
rot=[1 0; 0 -1];
% Vettore di traslazione
tras=[0; rr];

Q3=snake_zero(I_morf,NpS,rot,tras);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         =============================================
%          Fase 3) Proiezione del contorno nel livello 
%                  superiore della piramide
%         =============================================

% Osservazione. Si intende determinare il pixel e quindi le coordinate di un punto
% del contorno nell'immagine a risoluzione superiore.
% Data la struttura della piramide, c'� la possibilit� di segliere fra 4(?) pixel;
% quindi si deve stabilire quale sia il pixel pi� prossimo (def. PROSSIMITA')
% Oppure, pi� semplicemente, moltiplicare per 2 le coordinate. Tale semplificazione
% pu� essere valida tenedo presente che si � ottenuta comunque una approssimazione
% del bordo che potr� essere successivamente affinata "liberando" lo snake.

% L3 --> L2: Q2=2*Q3
% Q2=2*Q3;
% L2 --> L1: Q1=2*Q2
% ==> L3 --> L1: Q1=4*Q3;
Q1=4*Q3; %(Ns x 2)


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         ================================
%          Fase 4) EVOLUZIONE DELLO SNAKE
%         ================================

% Osservazione. Risalendo i livelli della piramide (verso L0) si ottiene via via
% una sempre miglior approssimazione del bordo dell'oggetto in esame; si pu� pensare di
% calcolare una feature che ....

%ImQ=L1;
K=kl_trasform(L1);
K=scalatura(K,'linearstretch');
K=sqrt(K(:,:,1).^2+K(:,:,2).^2);
K=scalatura(K(:,:,1),'linearstretch');

K=nonlinsharp(K,3,.9);
K=scalatura(K(:,:,1),'linearstretch');


ImQ=K;

g_dt=3e5; % momentaneamente inutile
g_curv=1000;
n_W=5;
Li=.9;
Le=1.05;
Qf=snake(ImQ,Q1,g_dt,g_curv,n_W,Li,Le,nfigure+1);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         =======================================
%          Fase 4) ELABORAZIONE CURVA RISULTANTE
%         =======================================

% - Visualizzazione Immagine originale + Snake
Ni=4*ones(length(Qf),1);
[A,As,Ass]=matrici_Bspline(Ni);

C=2*A*Qf; % Nel sistema di riferimento "Grafico"

[rr,cc,pp]=size(neo);
% Matrice di rotazione
% rot=[1 0; 0 -1];
% Vettore di traslazione
tras=[0; rr];

C_I=rot_tras(C,length(C),rot,tras);
Qf_I=rot_tras(2*Qf,length(Qf),rot,tras);

close all
figure
%nfigure=nfigure+1;
%figure(nfigure);
imshow(neo); 
hold on
p=plot([C_I(:,1);C_I(1,1)],[C_I(:,2);C_I(1,2)],'w-');
set(p,'linewidth',2);
q=plot(Qf_I(:,1),Qf_I(:,2),'r.');
set(q,'linewidth',10);






