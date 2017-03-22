function eq = equilibrio ( Et,Te,de )

% EQUILIBRIO Valuta lo stato di equilibrio raggiunto dal sistema.
%            Il sistema si considera in equilibrio quando l'energia Et
%            del sistema raggiunge il valore di minimo assoluto, per cui
%            dopo un certo istante questa rimane costante.
%
%            Per stabilire che <Et> ha raggiunto il minimo verifichiamo
%            quindi che negli ultimi <Te> passi di evoluzione la variazione
%            media relativa percentuale sia inferiore a <de>.
%            Con "variazione media relativa" si intende la media del modulo
%            delle variazioni fra due passi successivi di <Et> negli ultimi 
%            <Te> passi normalizzata rispetto all'ultimo valore assunto da Et.
%
% *) Et: vettore dell'energia del sistema negli ultimi Te+1 passi (1 x Te).
% *) Te: passi di calcolo considerati.
% *) de: tolleranza entro cui si considera equilibrio raggiunto (in % su Et).
%
% +) eq: vale <1> se in equilibrio, <0> altrimenti

eq=0; 

% Vettore del modulo delle variazioni.
DEtn=abs(diff(Et)); %(1 x Te-1)

% Media delle variazioni.
Mdetn=sum(DEtn)/Te;

% Variazione Media Relativa all'ultimo valore assunto da Et.
VMR=Mdetn/Et(Te);

VMR*100

% Se VRM percentuale inferiore a de% allora si è raggiunto lo stato di equilibrio.
if (VMR*100<de)
   
   eq=1;
   
end




