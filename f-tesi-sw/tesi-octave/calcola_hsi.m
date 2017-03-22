function HSI = calcola_hsi ( M )

alfa=1;

l=length(M);

R=M(:,1);
G=M(:,2);
B=M(:,3);

% Hue 
H=zeros(l,1);

x=2*R-G-B;
y=sqrt(3)*(G-B);

H=-atan2(y,x);

H=alfa*scalatura(H,'linearstretch');

% Intensity
I=zeros(l,1);

I=sum(M,2)/3;

I=scalatura(I,'linearstretch');

% Saturation
S=ones(l,1);

S(1)=0;
S(2:l)=S(2:l)-min(M(2:l),2)'./I(2:l);

S=alfa*scalatura(S,'linearstretch');

% HSI
HSI=[H,S,I];


figure
hold on;
plot(H,'r');
plot(S,'g');
plot(I,'b');



