function K = filtro_kl ( Map )

% Applica (approssimazione) trasformazione di K.L.
% *) Map (n x 3)
% +) K (n x 3)

% La trasformazione K.L. è approssiamta dall'operatore lineare H
H=[.333 .333 .333; .5 0 -.5; -.5 1 -.5];

K=(H*Map')';



