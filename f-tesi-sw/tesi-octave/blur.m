function B = blur ( I,scale )

k_base=[1 2 1]/4;
k=k_base;
iter=round(2*scale^2)-1;
for i=1:iter
   k=conv(k,k_base);
end

bx=conv2(I,k,'same');

by=conv2(I,k','same');

Bxy=zeros([size(I),2]);
Bxy(:,:,1)=bx;
Bxy(:,:,2)=by;

B=zeros(size(I));
B=sqrt(bx.^2+by.^2);
%B=max(Bxy,[],3);

