%lancia_contour.m

f_nome=input('Nome File Immagine: ');

[X,M]=imread(f_nome);
%ImIn=ind2gray(X,M); % In scala di grigio (R x C)
ImIn=ind2rgb(X,M); % Immagine vettoriale (R x C x 3)

colormap(M);

Im_snake=contour_yezzi_band(ImIn);

