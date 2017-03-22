function Im = morf_oper ( I,tipo,nucleo,dim )

% MORF_OPER Esegue una trasformazione morfologica su un'immagine.
%        Im = MORF_OPER ( I,TIPO,NUCLEO ) Applica l'operatore morfologico
%        TIPO con maschera NUCLEO(DIM).

% Osservazione. Le dimensioni dei nuclei-maschere sono dispari.

switch lower(nucleo)
   
   case 'circolare',
   
      switch dim
         
         case 3,
         
            SE=[0 1 0;
               1 1 1;
               0 1 0];
         
         case 5,
            
            SE=[0 1 1 1 0;
               1 1 1 1 1;
               1 1 1 1 1;
               1 1 1 1 1;
               0 1 1 1 0];
         
         case 7,
            
            SE=[0 0 1 1 1 0 0;
               0 1 1 1 1 1 0;
               1 1 1 1 1 1 1;
               1 1 1 1 1 1 1;
               1 1 1 1 1 1 1;
               0 1 1 1 1 1 0;
               0 0 1 1 1 0 0];
            
         case 9,
            
            SE=[0 0 0 1 1 1 0 0 0;
               0 0 1 1 1 1 1 0 0;
               0 1 1 1 1 1 1 1 0;
               1 1 1 1 1 1 1 1 1;
               1 1 1 1 1 1 1 1 1;
               1 1 1 1 1 1 1 1 1;
               0 1 1 1 1 1 1 1 0;
               0 0 1 1 1 1 1 0 0;
               0 0 0 1 1 1 0 0 0];
            
         case 11,
            
            SE=[0 0 0 0 1 1 1 0 0 0 0;
               0 0 0 1 1 1 1 1 0 0 0;
               0 0 1 1 1 1 1 1 1 0 0;
               0 1 1 1 1 1 1 1 1 1 0;
               1 1 1 1 1 1 1 1 1 1 1;
               1 1 1 1 1 1 1 1 1 1 1;
               1 1 1 1 1 1 1 1 1 1 1;
               0 1 1 1 1 1 1 1 1 1 0;
               0 0 1 1 1 1 1 1 1 0 0;
               0 0 0 1 1 1 1 1 0 0 0;
               0 0 0 0 1 1 1 0 0 0 0];
                        
     end % dim
         
   case 'quadrato',
      
      SE=ones(dim);
         
end      

if (isbw(I))
   
   % Immagine binaria BW
   Im=morf_operBW(I,tipo,SE);
   
else
   
   % Immagine in scala di grigi
   Im=morf_operG(I,tipo,SE);
   
end
   
   
