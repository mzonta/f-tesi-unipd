function Z = scal_kl ( K )

% SCALATURA Esegue scalatura immagine

[rr,cc,pp]=size(K);

Z=K;

Z_min=min(min(K(:,:,1)));
Z_max=max(max(K(:,:,1)));

for p=1:pp
   
   Z(:,:,p)=(Z(:,:,p)-Z_min)/(Z_max-Z_min);
 
end      
   
      
      
   