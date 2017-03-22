function [IV1,IV2,IV3] = pyramidv ( IV )

% PYRAMIDV Costruisce la piramide di immagini di un'immagine vettoriale.
%        [RGB1,RGB2,RGB3] = pyramid3 ( RGB ) ritorna i primi tre livelli 
%        della scomposizione a piramide dell'immagine IV.

% Dimensioni dell'immagine vettoriale IV
[rr,cc,pp]=size(IV);

for p=1:pp
   
   % Costruzione della piramide per l'intensità della componente (:,:,p) di IV
   [L1,L2,L3]=pyramid(IV(:,:,p));  
   
   IV1(:,:,p)=L1;
   IV2(:,:,p)=L2;
   IV3(:,:,p)=L3;
   
end







   


   