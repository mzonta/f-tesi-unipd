function [Gi,Ge] = defGie ( Qi,Qe,Li,Le )

% DEFGIE Definisce le curve Gi e Ge ottenute da Qi e Qe effettuando rispettivamente
%        una contrazione e una dilatazione rispetto i baricentri.

Ni=length(Qi);
Ne=length(Qe);

Ti=Li*eye(Ni)+(1-Li)/Ni*ones(Ni);
Te=Le*eye(Ne)+(1-Le)/Ne*ones(Ne);

Gi=Ti*Qi;
Ge=Te*Qe;

