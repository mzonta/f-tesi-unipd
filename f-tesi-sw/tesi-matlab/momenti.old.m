function momenti ( x,n )

% x: vettore valori
% n: ordine massimo dei momenti da calcolare

ordinario=1;
centrale=2;

L=length(x);

for k=1:n
   
   figure(ordinario);
   
   subplot(1,n,k);
   
   % Calcolo del momento ordinario di ordine k
   mo=sum(x.^k)/L;
   disp(mo);
   
   % Normalizzazione dei valori rispetto al momento ordinario di ordine k
   y=exp(x/mo);
   
   stem(y,'r');
   
   figure(centrale);
   
   subplot(1,n,k);
   
   % Calcolo del momento centrale di ordine k
   mc=sum((x-mo).^(k+1))/L;
   disp(mc);
   
   % Normalizzazione dei valori rispetto al momento centrale di ordine k
   y=exp(x/mc);
   
   stem(y,'b');

end
