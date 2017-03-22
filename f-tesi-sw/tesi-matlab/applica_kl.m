% applica_kl.m

fnome=input('Nome file: ');
[X,Map]=imread(fnome);

% applicazione della trasformazione 
if isa(X,'uint8')
   
   X=double(X)+1;
   
end

KLMap=filtro_kl(Map);

k1=zeros(size(X));
k2=zeros(size(X));
k3=zeros(size(X));

k1(:)=KLMap(X,1);
k2(:)=KLMap(X,2);
k3(:)=KLMap(X,3);

scale=2;

kb1=blur(k1,scale);
kb2=blur(k2,scale);
kb3=blur(k2,scale);
