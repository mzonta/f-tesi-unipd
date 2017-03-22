%lancia_contour.m

f_nome=input('Nome File Immagine: ');
f_formato=input('Formato file: ');

[X,M]=imread(f_nome,f_formato);
%ImIn=ind2gray(X,M); % In scala di grigio (R x C)
%ImIn=ind2rgb(X,M); % Immagine vettoriale (R x C x 3)

ImIn=X;
Im_snake=contour_yezzi(ImIn);

