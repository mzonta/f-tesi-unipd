%carica immagine
fnome=input('File immagine: ');
[X,M]=imread(fnome,'tif');
%converti in scala di grigio
GX=ind2gray(X,M);

ordine_m=input('Ordine del filtro mediano ( 0 per saltarlo ) = ');
if (ordine_m~=0)
   GX=medfilt2(GX,[ordine_m,ordine_m]);
end

%blurring image with 2D Gaussian filter
scale=input('Scala = ');
k_base=[1 2 1]/4;
k=k_base;
iter=round(2*scale^2)-1;
for i=1:iter
   k=conv(k,k_base);
end

halfklen=floor(length(k)/2);
actual_scale=sqrt(sum([-halfklen:halfklen].^2.*k));
fprintf(1,'Scala usata = %f\n', actual_scale);

GXblur=conv2(conv2(GX,k,'same'),k','same');

%calcolo gradiente
%der_x=[-1 0 1];
%der_y=[-1 0 1]';

%dx=conv2(GXblur,-der_x,'same');
%dy=conv2(GXblur,-der_y,'same');

op = [-1 -2 -1; 0 0 0; 1 2 1]/8; % Sobel approximation to derivative
dx = abs(filter2(op',GXblur)); dy = abs(filter2(op,GXblur));


%modulo gradiente
Mgrad=sqrt(dx.^2+dy.^2);

[r,c]=size(Mgrad);
bordo=halfklen+2;
Mg=Mgrad(bordo:r-bordo,bordo:c-bordo);

imshow(1-40*exp(Mg).*Mg);
%imshow(20*Mgrad);