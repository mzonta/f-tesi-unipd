function Ni = ripart_G ( pesi,mu )

% RIPART_G Ripartisce i punti di G con pesi <pesi> in modo che ciascun
%          nuovo span abbia una densità pari a <mu>.
%          Ni (Ns x 1).


% N.ro di punti di G.
Np=length(pesi);

% A partire dalla densità <mu> e dai pesi <p> è possibile stabilire il n.ro di
% control points richiesto, ovvero il numero di spans <Ns> in cui suddividere G.
% - "Massa" totale.
Pt=sum(pesi); 
% - N.ro di spans.
%Ns=round(Pt/mu);

% Il valore di <Ni(i)> è il numero di punti di G associati aloo span i-esimo.
%Ni=zeros(Ns,1);

% Massa totale dello span i-esimo.
p_i(1)=0;
% Indice di span.
i=1;
% Indice posizione inizio span in G.
ko=0;
% Indice p.to di G.
k=0;

while k<Np
   
   if (p_i(i)+pesi(k+1)<=mu)
      
      % Lo span non ha ancora raggiunto la complessità limite.
      p_i(i)=p_i(i)+pesi(k+1);
      k=k+1;
       
   else
     
      % Lo span ha raggiunto la complessità limite.
      Ni(i,1)=k-ko;
      
      % Inizializzazioni per lo span successivo.
      ko=k;
      i=i+1;
      p_i(i)=0;
      
   end
      
end

if (ko<Np)

   Ni(i,1)=Np-ko;
   p_i(i)=sum(pesi(ko+1:Np));
   
end

%p_i

%mu_m=sum(p_i)/length(p_i)

%mu_var=sum(p_i.^2)/length(p_i)-mu_m^2



%figure

%plot(p_i);
%hold on;
%plot(mu_m*ones(1,length(p_i)),'r');
%plot((mu_m+2*sqrt(mu_var))*ones(1,length(p_i)),'c');
%plot((mu_m-2*sqrt(mu_var))*ones(1,length(p_i)),'c');

