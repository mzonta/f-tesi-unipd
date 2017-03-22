function K = KL_trasform ( X,im_colori )

% KL_TRASFORM Applica trasformazione di K. L.

if nargin==1
   
   % Si calcola la sola trasformata.
   im_colori=0;
   
end


X=double(X);

[rr,cc,pp]=size(X);

% Vettore media
mx=zeros(pp,1);

for i=1:pp
   
   mx(i)=mean2(X(:,:,i));
   
end

% Matrice di covarianza
C=cov_im(X,mx);

% Autovalori-Autovettori: sono dati secondo autovalori crescenti.
[A_vet,A_val]=eig(C);

% A_kl: matrice le cui righe sono gli autovettori ordinati secondo autovalori decrescenti.
A_kl=zeros(pp); %(pp x pp)

for i=1:pp
   
   % Tenendo presente le strutture di A_vet, A_val e A_kl:
   A_kl(i,:)=A_vet(:,pp-i+1)'; 
   
end

% Si Applica ora la trasformazione:
K=zeros(rr,cc,pp);

M_mx=ones(rr,cc,pp);

for i=1:pp
   
   M_mx(:,:,i)=mx(i)*M_mx(:,:,i);
   
end

Xd=X-M_mx; % (rr x cc x pp)

% Buffer di riga: contiene una riga di pixel (pp-dimensionali)
buf_riga=zeros(pp,cc); % (pp x cc)

for r=1:rr
   
   for i=1:pp
      
      buf_riga(i,:)=Xd(r,:,i);
      
   end
   
   buf_out=A_kl*buf_riga; % (pp x cc)
   
   for i=1:pp
      
      K(r,:,i)=buf_out(i,:);
      
   end
   
end

%--------------------------------------------------------------------------
if im_colori
   
   % Ricostruzione dell'immagine a colori a partire dalle prime due
   % componenti della trasformata K.
   
   % Considero le prime due righe di A_kl
   Ar=A_kl(1:pp-1,:); 

   buf_riga=zeros(pp-1,cc);
   
   for r=1:rr
      
      for i=1:pp-1
         
         buf_riga(i,:)=K(r,:,i);
      
      end
   
      buf_out=Ar'*buf_riga;
   
      for i=1:pp
       
         Y(r,:,i)=buf_out(i,:);
      
      end
   
   end
   
   % Immagine a colori ricostruita.
   K=Y+M_mx;

end


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
