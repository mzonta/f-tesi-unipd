fname=input('Nome File: ');
[X,M]=imread(fname);
colormap(M);

nfigure=0;

%ImG=ind2gray(X,M);
ImRGB=ind2rgb(X,M);

Im=ImRGB;

nfigure=nfigure+1;
figure(nfigure);
imshow(Im);

tic

LAM=l_anis_mis(Im);

tempo=toc;

disp('Tempo di esecuzione: ');
disp(tempo);

[rr,cc,pp]=size(LAM);

for p=1:pp
   
   nfigure=nfigure+1;
   figure(nfigure);
   imshow(LAM(:,:,p));
   
end


