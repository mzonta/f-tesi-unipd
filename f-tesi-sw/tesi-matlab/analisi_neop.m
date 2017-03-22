function analisi_neop ( neo )

% ANALISI_NEO ( NEO ) Procedura principale che permette di realizzare l'analisi,
%                     individuazione e misure, del neo nell'immagine NEO (RGB).
%                     [ In futuro il file NEO sarà sostituito da bitmap in
%                       uscita dal frame-grabber ]
%
% Fase 1) Elaborazione dell'immagine:
%         - costruzione della piramide di immagini fino ad una risoluzione minima;
%         - binarizzazione della componente HUE dell'immagine a colori del livello
%           più basso (costituisce una prima segmentazione anche se non raffinata);
%           [ non si potrebbe considerare KL-Transform ? o Fisher Disr. Vector ? ]
%         - filtraggio con operatori mediana e morfologici per ottenere una unica
%           componente connessa, approssimazione del neo, possibilmente con contorni
%           sufficientemente smooth (è proprio necessario?).
%
% Fase 2) Applicazione dell'algoritmo di Yezzi per determinare il contorno dell'immagine
%         binaria fino a giungere ad un p.to di equilibrio.
%
% Fase 3) Proiettare il contorno trovato nell'immagine del livello superiore della 
%         piramide.
%         Osservazione. La curva ottenuta è una prima approssimazione del contorno
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


%         ====================================
%          Fase 1) Elaborazione dell'immagine
%         ====================================

% - Costruzione della piramide di immagini a risoluzione decrescente.
% Problema. Quanti livelli ? 
% Risposta. Considerando che l'immagine di partenza sarà dell'ordine dei
%           768x576 pixel conviene portarsi nell'odine delle decine di pixel
%           per dimensione ovvero al livello L3 (considerando l'immagine L0).

[L1,L2,L3]=pyramidV(neo); 

nfigure=nfigure+1;
figure(nfigure);
imshow(L3);


% - Calcolo della componente di Hue dell'immagine del livello L3.

% Nel caso di HUE
HSV=rgb2hsv(L3);
H=HSV(:,:,1);
% Osservazione. In futuro sarebbe conveniente costruire una funzione per il calcolo
% diretto della sola componente di Hue se non se ne fa niente delle altre.

nfigure=nfigure+1;
figure(nfigure);
imshow(H);

% - Binarizzazione.
% Problema. Con o senza isteresi ?
% Risposta. Da verificare...Nel caso di isteresi il procedimento è più lento.

% Istogramma di Hue.
[histH,binH]=imhist(H);
% Normalizzazione.
histH_n=histH/prod(size(H));

% Calcolo del valore di soglia.
% Osservazione. Valutare le prestazioni dei diversi metodi.
sH=disc_analysis_bin(histH_n); 

disp('Soglia stimata per la componente di Hue');
disp(sH);

H_bin=im2bw(H,sH); % Binarizzazione senza isteresi.
% Osservazione. Per la successiva corretta applicazione degli operatori
% morfologici H_bin deve essere assumere valori "1" in corrispondenza
% dell'oggetto in esame. mentre la funzione IM2BW esegue produce l'opposto.
H_bin=not(H_bin);

nfigure=nfigure+1;
figure(nfigure);
imshow(H_bin);

% - Riduzione dell'immagine binarizzata ad un'unica componente connessa.
% Osservazione1. Bisogna valutare la combinazione migliore degli operatori
% disponibili (mediana, morfologici, componenti connesse per immagini binarie).
% Osservazione2. Nell'applicazione degli operatori bisogna fare attenzione 
% anche alla scelta dello structuring element.
I_morf=morf_oper(H_bin,'closing','circolare',5);
I_morf=morf_oper(I_morf,'median','circolare',7);

nfigure=nfigure+1;
figure(nfigure);
imshow(I_morf);

save bw I_morf;

%   TRASFORMAZIONE DI FISHER
%   ------------------------
% - Con la binarizzazione precedente si è fornita una prima grossolana segmentazione;
%   un successivo raffinamento è quello di applicare la trasformazione di Fisher.

% - - La trasformazione su L1 e quindi si deve magnificare la maschera I_morf.
I_morf=interp_pyr(I_morf); %L3->L2
I_morf=interp_pyr(I_morf); %L2->L1

% - - L1 e I_morf devono avere dimensioni congruenti.
dimL=size(L1);
dimIm=size(I_morf);
dim=[dimL(1:2); dimIm];
dim_min=min(dim,[],1);
% - - - Ridimensionamento.
I_morf=I_morf(1:dim_min(1),1:dim_min(2));
L1=L1(1:dim_min(1),1:dim_min(2),:);

% - - Calcolo del Fisher Discriminant Vector <f> su L1.
f=fisher_dv(L1,I_morf);

disp('Fisher Discriminant Vector');
disp(f);

% - - Appllicazione della trasformazione di Fisher all'immagine vettoriale L3.
% Risulta immagine scalare (tipo intensità).
I_tf=filter_f(L1,f);
% Osservazione. Per le successive elaborazioni è opportuno scalarla in modo
% che assuma valori in [0,1].
I_tf=scalatura(I_tf,'linearstretch');

nfigure=nfigure+1;
figure(nfigure);
imshow(I_tf);

% - - Operatori morfologici sulla componente di Fisher.
%I_tf=morf_oper(I_tf,'median','circolare',7);
I_tf=morf_oper(I_tf,'closing','quadrato',1);

nfigure=nfigure+1;
figure(nfigure);
imshow(I_tf);

% Istogramma di I_tf.
[histF,binF]=imhist(I_tf);
% Normalizzazione.
histF_n=histF/prod(size(I_tf));

% Calcolo del valore di soglia.
% Osservazione. Valutare le prestazioni dei diversi metodi.
sF=disc_analysis_bin(histF_n); 

disp('Soglia stimata per la componente di Fisher');
disp(sF);

F_bin=im2bw(I_tf,sF); % Binarizzazione senza isteresi.
% Osservazione. Per la successiva corretta applicazione degli operatori
% morfologici H_bin deve essere assumere valori "1" in corrispondenza
% dell'oggetto in esame. mentre la funzione IM2BW esegue produce l'opposto.
F_bin=not(F_bin);

nfigure=nfigure+1;
figure(nfigure);
imshow(F_bin);

% - Riduzione dell'immagine binarizzata ad un'unica componente connessa.
% Osservazione1. Bisogna valutare la combinazione migliore degli operatori
% disponibili (mediana, morfologici, componenti connesse per immagini binarie).
% Osservazione2. Nell'applicazione degli operatori bisogna fare attenzione 
% anche alla scelta dello structuring element.
%I_morf=morf_oper(F_bin,'median','circolare',5);
I_morf=morf_oper(F_bin,'closing','circolare',7);

nfigure=nfigure+1;
figure(nfigure);
imshow(I_morf);

nfigure=nfigure+1;
figure(nfigure);
imshow(L1);

% TRASFORMAZIONE DI KARHUNEN-LOEVE
% --------------------------------

K=kl_trasform(L3);
% Osservazione. Per le successive elaborazioni è opportuno scalarla in modo
% che assuma valori in [0,1].
% Si considera la sola prima componente.
K=scalatura(K,'linearstretch');
%K=sqrt(K(:,:,1).^2+K(:,:,2).^2+K(:,:,3).^2);
K=sqrt(K(:,:,1).^2+K(:,:,2).^2);
K=scalatura(K,'linearstretch');

nfigure=nfigure+1;
figure(nfigure);
imshow(K);

% - - Operatori morfologici sulla componente principale di K-L.
K=morf_oper(K,'median','circolare',7);
%K=morf_oper(K,'dilation','circolare',3);
%K=nonlinsharp(K,5,.8);
%K=ext_sharp(K,5);
K=scalatura(K,'linearstretch');

nfigure=nfigure+1;
figure(nfigure);
imshow(K);

% Istogramma di I_tf.
[histK,binK]=imhist(K);

nfigure=nfigure+1;
figure(nfigure);
%stem(binK,histK);
plot(histK);

histK=conv(histK,[0.0625 0.2500 0.3750 0.2500 0.0625]);

nfigure=nfigure+1;
figure(nfigure);
%stem(binK,histK);
plot(histK);


% Normalizzazione.
histK_n=histK/prod(size(K));

% Calcolo del valore di soglia.
% Osservazione. Valutare le prestazioni dei diversi metodi.
sK=disc_analysis_bin(histK_n); 

disp('Soglia stimata per la componente di K-L');
disp(sK);

K_bin=im2bw(K,sK); % Binarizzazione senza isteresi.
% Osservazione. Per la successiva corretta applicazione degli operatori
% morfologici H_bin deve essere assumere valori "1" in corrispondenza
% dell'oggetto in esame. mentre la funzione IM2BW esegue produce l'opposto.
K_bin=not(K_bin);

nfigure=nfigure+1;
figure(nfigure);
imshow(K_bin);

% - Riduzione dell'immagine binarizzata ad un'unica componente connessa.
% Osservazione1. Bisogna valutare la combinazione migliore degli operatori
% disponibili (mediana, morfologici, componenti connesse per immagini binarie).
% Osservazione2. Nell'applicazione degli operatori bisogna fare attenzione 
% anche alla scelta dello structuring element.
I_morf=K_bin;
I_morf=morf_oper(I_morf,'median','circolare',5);
I_morf=morf_oper(I_morf,'closing','circolare',7);

nfigure=nfigure+1;
figure(nfigure);
imshow(I_morf);


disp('Fine Elaborazione Immagine');

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         ========================================
%          Fase 2) Contorno dell'immagine binaria
%         ========================================

% Osservazione. Nota l'imagine binaria è semplice ricostruirne il profilo; da questi
% però bisogna ricostruire la curva a B-spline che l'approssima, ovvero determinare
% i control points. Questo può essere effettuato in modo diretto o considerando
% la curva come un active contours (snake) che evolve fino ad ottenere l'approssimazione
% desiderata.
% # Metodo diretto: - si deve fissare a priori il numero dei c.ps.;
%                   - si suddivide il profilo in un numero di segmenti pari al
%                     numero dei c.ps.;
%                   - si ottengono i c.ps. come soluzione di un problema ai MQ.
% # Medoto indiretto: - si fissa una curva iniziale ricavata dalle informazioni
%                       sulla forma (individuare i parametri che la caratterizzano
%                       e la loro interpretazione);
%                     - far evolvere la curva-snake con la legge di aggiornamento 
%                       dell'algoritmo di Yezzi nel caso ottimale di immagine 
%                       perfettamente binaria.

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         =============================================
%          Fase 3) Proiezione del contorno nel livello 
%                  superiore della piramide
%         =============================================

% Osservazione. Si intende determinare il pixel e quindi le coordinate di un punto
% del contorno nell'immagine a risoluzione superiore.
% Data la struttura della piramide, c'è la possibilità di segliere fra 4(?) pixel;
% quindi si deve stabilire quale sia il pixel più prossimo (def. PROSSIMITA')
% Oppure, più semplicemente, moltiplicare per 2 le coordinate. Tale semplificazione
% può essere valida tenedo presente che si è ottenuta comunque una approssimazione
% del bordo che potrà essere successivamente affinata "liberando" lo snake.

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

%         ====================================================
%          Fase 4) 
%         ====================================================

% Osservazione. Risalendo i livelli della piramide (verso L0) si ottiene via via
% una sempre miglior approssimazione del bordo dell'oggetto in esame; si può pensare di
% calcolare una feature che 


pause
close all






