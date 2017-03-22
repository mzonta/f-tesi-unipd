n_figure=0;

fnome=input('Nome File: ');
[X,M]=imread(fnome);

% Immagine RGB
RGB=ind2rgb(X,M);

% Si considera l'applicazione ripetuta di un filtro di media
%RGB=median_loop(RGB,3,3); %3 iterazioni, ordine 3

% Trasformazione di K.L.
K=KL_trasform(RGB);

%K=median_loop(K,3,3);

% Scalatura e Visualizzazione risultati
Kz=scalatura(K,'linearstretch');

[rr,cc,pp]=size(Kz);

for p=1:pp
   
   figure(n_figure+p)
   imshow(Kz(:,:,p))
   
end

n_figure=n_figure+pp;

disp('Pausa...');
pause

% Local Anisotropy Measure
LAM=l_anis_mis(Kz);

% Scalatura e Visualizzazione dei risultati
LAMz=scalatura(LAM,'linearstretch');
[rr,cc,pp]=size(LAMz);

for p=1:pp
   
   n_figure+p;
   figure(n_figure)
   imshow(LAMz(:,:,p))
   
end

   