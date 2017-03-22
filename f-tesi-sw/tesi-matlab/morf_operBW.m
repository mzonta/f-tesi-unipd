function BWm = morf_operBW ( BW,tipo,nucleo )

% MORF_OPER Esegue una trasformazione morfologica su un'immagine binaria.
%        Bm = MORF_OPERBW ( BW,TIPO,NUCLEO ) Applica l'operatore morfologico
%        TIPO con maschera NUCLEO).

% Osservazione. Le dimensioni dei nuclei-maschere sono dispari.


switch lower(tipo)
    
   case 'dilation'
      
      % Dilation
      BWm=dilate(BW,nucleo);
      
   case 'erosion'
      
      % Erosion
      BWm=erode(BW,nucleo);
      
   case 'closing',
      
      % Dilation
      BWd=dilate(BW,nucleo);
      
      % Erosion
      BWm=erode(BWd,nucleo);
      
   case 'opening',
      
      % Erosion
      BWe=erode(BW,nucleo);
      
      % Dilation
      BWm=dilate(BWe,nucleo);
      
   case 'median',
      
      k=(prod(size(nucleo))+1)/2;
      % Mediana 2-D
      BWm=ordfilt2(BW,k,nucleo);
      
end

