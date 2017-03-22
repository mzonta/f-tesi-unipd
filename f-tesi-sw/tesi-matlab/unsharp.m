function U = unsharp ( I,scale )

% UNSHARP Unsharp Masking ottenuta sottraendo l'immagine
%         filtrata con un filtro P.B. Gaussaino da quella 
%         originaria.

Ub=blur(I,scale);

U=I-Ub;