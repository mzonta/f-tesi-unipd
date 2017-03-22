%function bh = bin_hys ( I,R,C,G,t,n_figure )
% *) I: matrice intensità
% *) R,C: dimensioni matrice Xi
% *) G: n.ro livelli
% *) t: valore di soglia
% *) n_figure: contatore figure
% -) bh: ritorna valore esecuzione binarizzazione 
function bh = bin_hys ( I,R,C,G,t,n_figure )

Xi=(G-1)*I;

opz=1;

while opz==1
   
   hys=input('Isteresi = '); %potrebbe essere calcolato automaticamente
   
   %costruisco immagine binaria
   Xf=zeros(R,C);
   disp('...Costruzione immagine binaria...');
   
   %binarizzazione con isteresi
   g=zeros(1,C);
   buf=zeros(1,C);
   buf_out=zeros(1,C);
   for i=1:R
      buf=Xi(i,:); %legge la riga i-esima
      for j=2:C
         sc=t+hys;
         if ((g(j)+g(j-1)+buf(j-1))>(G-1))
           sc=t-hys;
         end
         if (buf(j)>sc)
           buf_out(j)=G-1;
           g(j)=G-1;
         else
           buf_out(j)=0;
           g(j)=0;
         end
      end
      Xf(i,:)=buf_out;
   end
   
   n_figure=n_figure+1;
   figure(n_figure)
   imshow(Xf(:,2:C));
  
   disp('...Esecuzione terminata');  
  
   opz=input('Continuare 1 - Terminare 0 '); 
   
end

bh=1;