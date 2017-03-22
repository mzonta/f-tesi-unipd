I=apri('neo.bmp');

[L1,L2,L3]=pyramidv(I);

clear L2 L3

[L1,L2,L3]=pyramidv(L1);

[rr,cc,pp]=size(L3);
R=L3(:,:,1);
G=L3(:,:,2);
B=L3(:,:,3);

I1=zeros(rr*cc,1); I1=R(:); size(I1)
I2=zeros(rr*cc,1); I2=G(:); size(I2)
I3=zeros(rr*cc,1); I3=B(:); size(I3)

clear R G B;

m=zeros(rr*cc,1);
m=(I1+I2+I3)/3; size(m)

%C=(I1*I1'+I2*I2'+I3*I3')/3-m*m';
C=I1*I1';
C=C+I2*I2';
C=C+I3*I3';
C=C/3;
C=C-m*m'; size(C)


% Autovalori-Autovettori: sono dati secondo autovalori crescenti.
% Gli autovettori sono le colonne di A_vet.
[A_vet,A_val]=eig(C);

% Ordino le colonne di autovettori secondo auovalori decrescenti.
A=fliplr(A_vet);

% Porto gli autovettori nelle righe;
A=A';

Y1=A*(I1-m);
Y2=A*(I2-m);
Y3=A*(I3-m);

K1=zeros(rr,cc); K1(:)=Y1;
K2=zeros(rr,cc); K2(:)=Y2;
K3=zeros(rr,cc); K3(:)=Y3;









