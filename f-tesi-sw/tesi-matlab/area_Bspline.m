function A = area_Bspline ( Q )

% Calcola area delimitata dalla curva definita dai c.ps Q

T=[0 3.1 2.8 .1;
   -3.1 0 18.3 2.8;
   -2.8 -18.3 0 3.1;
   -.1 -2.8 -3.1 0];

Ns=length(Q);

A=0;

for i=1:Ns
   
   % utilizzando matrice che estrae i c.ps. di ciascun span dal vettore completo (vettori colonna)
   Qx=... % (4 x 1)
   Qy=... % (4 x 1)
   
   A=A+Qx'*T*Qy; 
   
end
   
   