function s = disc_analysis_bin ( q )

% DISC_ANALYSIS_BIN Binarization based on Discriminant Aalysis.
%        S = DISC_ANALYSIS_BIN ( Q ) calcola il valore di soglia
%        analizzando l'istogramma normalizzato Q...
        

disp('BINARIZATION BASED ON DISCRIMINANT ANALYSIS...');

% N.ro di livelli dell'istogramma
G=length(q);

disp(sum(q))

muT=0;
for w=1:G
   muT=muT+w*q(w);
end

Q=0;
Qa=0;
mua=0;
MAX=0;

for w=1:G
   
   Q=Qa+q(w);
   mu=mua+w*q(w);
   
   if ((Q>0)&(Q<1))
      
      T=(muT*Q-mu)^2/(Q*(1-Q));
      
   else
      
      T=0;
      
   end
   
   if (T>MAX)
      
      s=w;
      MAX=T;
      
   end
   
   Qa=Q;
   mua=mu;
   
end

% Dai calcoli precedenti risulta s in [1,G].
% Valore di soglia in [0,1]. 
s=s/(G-1);


   
