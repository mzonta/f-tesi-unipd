function f = fisher_dv ( I,BW )

% FISHER_DV Calcola il vettore discriminante di Fisher fra le due regioni 
%           If (foreground) e Ib (background) definite dalla maschera BW.

[rr,cc,pp]=size(I);

% - Foreground
If=zeros(rr,cc,pp);

% Definizione della regione If
for p=1:pp
   
   If(:,:,p)=I(:,:,p).*double(BW);
   
end

figure
imshow(If)

% Vettore media
mf=zeros(pp,1);

for p=1:pp
   
   np=length(find(If(:,:,p)));
   sp=sum(sum(If(:,:,p)));
   mf(p)=sp/np;
   
end

disp('Media If');
disp(mf);

% Matrice di covarianza
Cf=cov_im(If,mf);

% - Background
Ib=zeros(rr,cc,pp);

% Definizione della regione Ib
for p=1:pp
   
   Ib(:,:,p)=I(:,:,p).*double(not(BW));
   
end

figure
imshow(Ib)

% Vettore media
mb=zeros(pp,1);

for p=1:pp
   
   np=length(find(Ib(:,:,p)));
   sp=sum(sum(Ib(:,:,p)));
   mb(p)=sp/np;

end

disp('Media Ib');
disp(mb);

% Matrice di covarianza
Cb=cov_im(Ib,mb);


% Fisher Discriminant Vector
f=inv(Cf+Cb)*(mf-mb);




% ------------------------------------------------------------
% Function COV_IM
% ------------------------------------------------------------

function C = cov_im ( X,mx )

% COV_IM Calcola la matrice di covarianza dell'immagine X

[rr,cc,pp]=size(X);

X=double(X);

C=zeros(pp); %(pp x pp)

for i=1:pp
   
   for j=i:pp
      
      cij=sum(sum(X(:,:,i).*X(:,:,j)));
      
      C(i,j)=cij;
      C(j,i)=cij;
      
   end
   
end

C=C/(rr*cc)-mx*mx';

