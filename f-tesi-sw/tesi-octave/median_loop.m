function ML = median_loop ( I,n_iter,ord )

% MEDIAN_LOOP Applica N_ITER volte il filtro di mediana di ordine ORD all'immagine I.
%
%             ML=MEDIAN_LOOP(I,N_ITER,ORD); 

ML=I;

for i=1:n_iter
   
   ML=medfilt2(ML,[ord,ord]);
   
end
