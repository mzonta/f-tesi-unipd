function s = recursive_bin ( hist_n,e )

% RECURSIVE_BIN Calcola valore di soglia...


disp('RECURSIVE BINARIZATION...');

% N.ro di livelli dell'istogramma
G=length(hist_n);

%e=input('Scarto convergenza calcolo soglia: ');
s=G/2;
stop=1;

while stop
   
   sa=s;
   
   mu0=0;
   q0=0;
   
   for u=1:floor(s)
      
      mu0=mu0+u*hist_n(u);
      q0=q0+hist_n(u);
      
   end
   
   mu1=0;
   q1=0;
   
   for u=floor(s+1):G
      
      mu1=mu1+u*hist_n(u);
      q1=q1+hist_n(u);
      
   end
   
   if ((q0~=0)&(q1~=0))
      
      s=.5*(mu0/q0+mu1/q1);
      
   elseif (q0~=0)
      
      s=mu0/q0;
      
   else
      
      s=q1/mu1;
      
   end
   
   stop=(abs(s-sa)>e);
   
end

% Dai calcoli precedenti risulta s in [1,G].
% Valore di soglia in [0,1]. 
s=s/(G-1);

