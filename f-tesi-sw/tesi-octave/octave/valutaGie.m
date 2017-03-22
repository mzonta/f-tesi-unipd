function [Gi,Ge] = valutaGie ( Q,A,dLi,dLe,qr,Xmax,Ymax )

% VALUTAGIE Attraverso una contrazione e una dilatazione di G applicata ai c.ps. Q.
%
% *) Q: vettore dei control points.
% *) A: G=A*Q.
% *) dLi: quota di contrazione.
% *) dLe: quota di dilatazione.
% *) qr: risultato richiesto: (Gi&Ge) (Gi) (Ge) 
Nq=length(Q);

switch qr
   
case 'ie',
   
   Li=1-dLi;
   Le=1+dLe;

   Ti=Li*eye(Nq)+(1-Li)/Nq*ones(Nq);
   Te=Le*eye(Nq)+(1-Le)/Nq*ones(Nq);

   %Qi=Ti*Q; --> Gi=A*Qi;
   %Qe=Te*Q; --> Ge=A*Qe;

   Gi=A*Ti*Q;
   Ge=A*Te*Q;

case 'i',
   
   Li=1-dLi;
   
   Ti=Li*eye(Nq)+(1-Li)/Nq*ones(Nq);
   
   Gi=A*Ti*Q;
   
case 'e'
   
   Le=1+dLe;

   Te=Le*eye(Nq)+(1-Le)/Nq*ones(Nq);
   
   Ge=A*Te*Q;
   
end

if (dLe>0)
   
   Nge=length(Ge);
   
   for k=1:Nge
      
      if (Ge(k,1)>Xmax-1)
         
         Ge(k,1)=Xmax-1;
         
      end
      
      if (Ge(k,1)<1)
         
         Ge(k,1)=1;
         
      end
      
      if (Ge(k,2)>Ymax-1)
         
         Ge(k,2)=Ymax-1;
         
      end
      
      if (Ge(k,2)<1)
         
         Ge(k,2)=1;
         
      end
      
   end
   
end
   




