%halftone image

T=[0 128 32 160 192 64 224 96 48 176 16 144 240 122 208 80];

n_figure=0;

%carica immagine
fnome=input('Nome file: ');
formato=input('Formato: ');
[X,M]=imread(fnome,formato);

%in scala di grigio
I=ind2gray(X,M);
[R,C]=size(I);

n_figure=n_figure+1;
imshow(I);


G=input('N.ro livelli = ');

Xi=(G-1)*I;
Xf=zeros(R,C);
buf=zeros(R,1);
for y=1:C
   buf=Xi(:,y);
   for x=1:R
      u=buf(x);
      i=rem(x,4);
      j=rem(y,4);
      s=i+1+(3-j)*4;
      if (u<=T(s))
         nu=0;
      else
         nu=255;
      end
      buf(x)=nu;
   end
   Xf(:,y)=buf;
end

n_figure=n_figure+1;
figure(n_figure)
imshow(Xf);
