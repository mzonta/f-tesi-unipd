function Z = scalatura ( I,tipo )

% SCALATURA Esegue scalatura immagine

[rr,cc,pp]=size(I);

Z=I;

for p=1:pp
   
   Z_p_min=min(min(Z(:,:,p))); 
   
   switch lower(tipo)
      
   case 'traslazione',
      
      Z(:,:,p)=Z(:,:,p)-Z_p_min;
      
   case 'linearstretch',
      
      Z_p_max=max(max(Z(:,:,p)));
      
      if ((Z_p_max==1)&(Z_p_min==0))
         
         disp('Operazione non necessaria');
         
      else
         
         Z(:,:,p)=(Z(:,:,p)-Z_p_min)/(Z_p_max-Z_p_min);
         
      end
      
   end
   
end      
   
      
      
   