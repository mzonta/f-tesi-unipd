function Ies = ext_sharp ( I,n )

% Extreme Sharpening per immagine scalare.

a=n^2;
c=(a+1)/2;

% - Local Anisotropy Measure
LAM=l_anis_mis(I,n);

% - Si considerano le matrici dei massimi e minimi locali.
W_loc=ones(n);
I_max=ordfilt2(I,a,W_loc);
I_min=ordfilt2(I,1,W_loc);

% - Si definisce media locale (I_max-I_min)/2 e si considera la matrice
%   differenza I_d=I-I_medie.
I_d=I-(I_max-I_min)/2;

% Extreme Sharpening
Ies=c*ones(size(I));
D=find(I_d); % Indici dei pixel a valori positivi (strettamente)
length(D)
Ies(D)=Ies(D)+(c-1)*LAM(D);


