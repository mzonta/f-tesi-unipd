%ordina_cps.m
%chiamata da aggrn_cpsA.m
%ordina i control points in senso antiorario
function C_P_O = ordina_cps ( C_P_N )
m=length(C_P_N);
C_P_O=C_P_N;
%ripeti finchè non si hanno variazioni
variazioni=1;
while variazioni
   variazioni=0;
   %calcolo baricentro Zb=[xb,yb]
   xb=(sum(C_P_O(1,:)))/m;
   yb=(sum(C_P_O(2,:)))/m;
   %vettore dei "vettori orientati" centrati rispetto Zb 
   v_x=C_P_O(1,:)-xb;
   v_y=C_P_O(2,:)-yb;
   %per i primi m-1 spans
   for i=1:m-1
      %calcolo prodotto esterno
      p_e=v_x(i)*v_y(i+1)-v_x(i+1)*v_y(i);
      if p_e<0
         variazioni=1;
         xyp=C_P_O(:,i);
         C_P_O(:,i)=C_P_O(:,i+1);
         C_P_O(:,i+1)=xyp;
         %disp('Variazioni su ordinamento c-p 1');
         %pause
      end
   end
   %per l'ultimo span
   p_e=v_x(m)*v_y(1)-v_x(1)*v_y(m);
   if p_e<0
      variazioni=1;
      xyp=C_P_O(:,m);
      C_P_O(:,m)=C_P_O(:,1);
      C_P_O(:,1)=xyp;
   end
end



