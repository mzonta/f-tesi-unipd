function gg = guadagno ( s,k )

% GUADAGNO Definisce la legge del guadagno in relazione ai diversi 
%          parametri che caratterizzano la curva.
%          (Vedi <snake.m>)
%
%          Parametri considerati:
%          - s: fattore di forma della gaussiana
%          - k: curvatura

gg=exp(-s*k^2);
