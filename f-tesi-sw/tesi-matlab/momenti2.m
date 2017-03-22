function momenti2 ( I,n )

%L=prod(size(I));
[rr,cc]=size(I);
I=double(I);


mkc=0;
mkr=0;

for k=1:n
   
   % Calcolo del momento ordine k
   mkc=sum(((I-mkc).^k),1)/cc;
   mkr=sum(((I-mkr).^k),2)/rr;
   %disp(mk);
   
   % Normalizzazione dei valori rispetto al momento ordinario di ordine k
   Yc=exp(I/mkc);
   Yr=exp(I/mkr);
   %y=x/mk;
   %y=log(x/mk+1);

   figure(2*k-1);
   % Linear Stretching in [0,1]
   Ymin=min(min(Yc));
   Ymax=max(max(Yc));
   Yc=(Yc-Ymin)/(Ymax-Ymin);
   imshow(Yc);
   
   figure(2*k);
   % Linear Stretching in [0,1]
   Ymin=min(min(Yr));
   Ymax=max(max(Yr));
   Yr=(Yr-Ymin)/(Ymax-Ymin);
   imshow(Yr);
 
end
