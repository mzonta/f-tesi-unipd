function momenti ( x,n )

% x: vettore valori
% n: ordine massimo dei momenti da calcolare

toll=1e-3;
L=length(x);

mk=0;

for k=1:n
   
   figure(1);
   subplot(n,1,k);
   
   % Calcolo del momento ordine k
   mk=sum((x-mk).^k)/L;
   disp(mk);
   
   % Normalizzazione dei valori rispetto al momento ordinario di ordine k
   y=exp(x/mk);
   %y=x/mk;
   %y=log(x/mk+1);
   
   stem(y,'r');
   
   figure(2);
   subplot(n,1,k);
   
   z=abs(fft(y));
   length(find(z>toll))
   
   
   stem(z,'k');
   
      
end
