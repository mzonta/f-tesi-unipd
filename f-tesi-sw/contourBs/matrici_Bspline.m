function [A,As,Ass] = matrici_Bspline ( Ni )

% *) Ni: vettrore (Ns,1) del n.ro di punti per ogni span
%
% +) A, As, Ass: matrici (Npunti x Ns) che legano i punti dello snake con i control points Q
%                - X = A*Q
%                - dX/ds = As*Q
%                - d2X/ds2 = Ass*Q

% M: shape-matrix per il modello di B-spline considerato
%
% [xi(s) yi(s)] = [s^3 s^2 s 1]*M*[q(i-3) q(i-2) q(i-1) q(i)]'      (1)
%
% con 0 <= s < 1
%
% Qi=[q(i-3) q(i-2) q(i-1) q(i)]' vettore control points per lo span i-esimo
%
% Dato il vettore dei Control Points Q=[P1 P2 P3 P4 ... PN]'
% se si considera il vettore completo Qc=[Q Q(1:3)] si ottiene una curva chiusa 
% composta di N spans
M=[-1 3 -3 1; 3 -6 3 0; -3 0 3 0; 1 4 1 0]/6;

% Ns: n.ro di spans
Ns=length(Ni); 

% K: matrice (Ns x Ns) di trasformazione tra le Hi
%                            _             _
%                           | 0 1 0 . . . 0 |
%                           | 0 0 1 0 . . 0 |
%                           | . . . . . . . |
%                       K = | 0 . . . . 1 0 |
%                           | 0 . . . . 0 1 |
%                           | 1 0 . . . . 0 |
%                            -             -

V_diagonale=ones(1,Ns-1); %vettore (1 x Ns) di 1
K=diag(V_diagonale,1); %matrice quadrata con sovradiagonale di 1
K(Ns,1)=1; %inserisco 1 in posizione (Ns,1) 

% Nota. Le matrici Hi selezionano i control points Qi in Q di ogni span
% H: lista delle matrici Hi (4 x Ns) che sono in n.ro pari a Ns
H=zeros(4,Ns^2);

% Definisco la prima matrice H1 (4 x Ns)
%                    _                 _ 
%                   | 1 0 . . .       0 |
%                   | 0 1 0 . .       0 |
%             H1 =  | 0 0 1 0 . . . . 0 | = [I(4) 0(4,Ns-4)]
%                   | 0 0 0 1 . . . . 0 |
%                    -                 -

H1=[eye(4),zeros(4,Ns-4)];
H(:,1:Ns)=H1;

% Mentre le successive Hi risultano Hi+1 = H1 * K^i

Ki=eye(Ns); % matrice identità di ordine Ns [I(Ns)] 

% A: (Npunti x 4) lista delle matrici Ai_c = Ai*Hi
Npunti=sum(Ni);
A=zeros(Npunti,Ns);
As=zeros(Npunti,Ns);
Ass=zeros(Npunti,Ns);
Ni_0=0;


for i=1:Ns
   
   Hi=H1*Ki;
   H(:,(i-1)*Ns+1:i*Ns)=Hi;
   
   % --------------------------------------------------------------------------------------

   % Ai: matrice (Ni x 4) definita a partire dai p.ti

   %   xi(s1)  = [s1]'*M*Qi
   %   xi(s2)  = [s2]'*M*Qi 
   %   ......  = .........
   %   xi(sNi) = [sN]'*M*Qi

   % risulta    Xi = Si*M*Qi = Ai*Qi = Ai*Hi*Q
   
   % Analogamente Ais = Sis*M dove Sis = dS/ds
   
   % Le matrici Ai e Ais (Ni x 4) sono fisse per ogni span se Ni è lo stesso per ogni span;
   % si potrebbe far variare Ni in base alle caratteristiche geometriche dello snake

   Ni_i=Ni(i);
   
   v_uni=ones(Ni_i,1); %(Ni x 1)
   v_zeri=zeros(Ni_i,1); %(Ni x 1)
   
   dsi=1/Ni_i;
   
   % vsi (Ni x 1) = [0 dsi 2*dsi ... (Ni-1)*dsi]'
   vsi=[0:dsi:(1-dsi/2)]'; 
   %Nota. Ponendo come estremo 1-dsi/2 ottengo che la sequenza non raggiunge 
   %      il valore 1 ma si ferma a 1-dsi.
   
   Si=[vsi.^3 vsi.^2 vsi v_uni]; %(Ni x 4)
   
   Sis=[3*vsi.^2 2*vsi v_uni v_zeri]; %(Ni x 4)
   
   Siss=[6*vsi 2*v_uni v_zeri v_zeri]; %(Ni x 4)
   
   % --------------------------------------------------------------------------------------
   %                     ^                     ^
   % Da   Xi = Ai*Hi*Q = Ai * Q    (Ni x 2)  ( Ai = Aic  (Ni x Ns) )
   
   % ottengo l'espressione
   
   %       _   _     _    _
   %      | X1  |   | A1c  |
   %      | X2  |   | A2c  |
   %      | .   |   |  .   |
   %      | .   | = |  .   | * Q  ->  X = A*Q   { X (Ni+Ns x 2); A (Ni*Ns x Ns); Q (Ns x 2) }
   %      | .   |   |  .   |
   %      | XNs |   | ANsc | 
   %       -   -     -    -
   %                                     ^                               ^
   % Analogamente per dX/ds = Ais*Hi*Q = Ais*Q  e  d2X/ds2 = Aiss*Hi*Q = Aiss*q
   
   A(Ni_0+1:Ni_0+Ni_i,:)=Si*M*Hi;
   
   As(Ni_0+1:Ni_0+Ni_i,:)=Sis*M*Hi;
   
   Ass(Ni_0+1:Ni_0+Ni_i,:)=Siss*M*Hi;
   
   %per il passo successivo
   Ki=Ki*K;
   Ni_0=Ni_0+Ni_i;
   
end
