function W = normgrad ( I )

der_x=[-1 0 -1];
der_y=[-1 0 -1]';

Wx=conv2(I,-der_x,'same');
Wy=conv2(I,-der_y,'same');

%Wn=Wx.^2+Wy.^2;

%W=zeros([size(I),2]);
%W(:,:,1)=(Wx.^2-Wy.^2);
%W(:,:,2)=2*Wx.*Wy;

%W=max(Wx,Wy);
W=sqrt(Wx.^2+Wy.^2);

