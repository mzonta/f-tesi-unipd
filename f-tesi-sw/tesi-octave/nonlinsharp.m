function NLS = nonlinsharp ( I,n,c )

% NONLINSHARP Non-linear Sharpening dell'immagine.

I_m=medfilt2(I,[n,n]);

NLS=c*I-(c-1)*I_m;
