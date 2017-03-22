function I_ff = filter_f ( I,f )

% I_FF = FILTER_F ( I,F ) 
% FILTER_F Prodotto scalare tra il vettore F (Discriminat Fisher Vector)
%          e ogni pixel (vettore) dell'immagine I.
%          L'immagine che ne risulta è scalare (come sola intensità).

I_ff=I;

[rr,cc,pp]=size(I_ff);

for p=1:pp
   
   I_ff(:,:,p)=I(:,:,p)*f(p);
   
end

I_ff=sum(I_ff,pp);
