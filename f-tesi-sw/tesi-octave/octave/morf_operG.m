function Gm = morf_operG ( G,tipo,nucleo )

% MORF_OPER Esegue una trasformazione morfologica su un'immagine in scala di grigio.
%        Gm = MORF_OPER ( G,TIPO,NUCLEO ) Applica l'operatore morfologico
%        TIPO con maschera NUCLEO.

% Osservazione. Le dimensioni dei nuclei-maschere sono dispari.


% N.ro di elementi del <nucleo> diversi da "0"
n=nnz(nucleo);

switch lower(tipo)
    
   case 'dilation'
      
      % Dilation = Max 2D
      Gm=ordfilt2(G,n,nucleo); 
      
   case 'erosion'
      
      % Erosion = Min 2D
      Gm=ordfilt2(G,1,nucleo); 
      
   case 'closing',
      
      % Dilation
      Gd=ordfilt2(G,n,nucleo);
      
      % Erosion
      Gm=ordfilt2(Gd,1,nucleo);
      
   case 'opening',
      
      % Erosion
      Ge=ordfilt2(G,1,nucleo);
      
      % Dilation
      Gm=ordfilt2(Ge,n,nucleo);
      
   case 'median',
      
      k=(n+1)/2;
      % Mediana 2D
      Gm=ordfilt2(G,k,nucleo);
      
end

