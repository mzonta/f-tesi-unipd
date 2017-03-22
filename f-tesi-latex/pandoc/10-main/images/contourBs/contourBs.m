load('ctrlpointsQ.mat')

Ni=20*ones(length(Q),1);
[A,As,Ass]=matrici_Bspline(Ni);

C=A*Q; % Nel sistema di riferimento "Grafico"

cm=mean(Q) % Centroide

komo1=0.8;
komo2=1.2;
Co1=komo1*C+(1-komo1)*cm;
Co2=komo2*C+(1-komo2)*cm;

close all
figure
axis([0 10 0 14])
set(gca,'xtick',[0:1:11])
set(gca,'ytick',[0:1:14])
axis off;

hold on;

p=plot([C(:,1);C(1,1)],[C(:,2);C(1,2)],'k-');
set(p,'linewidth',1);

%q=plot(Q(:,1),Q(:,2),'r.');
%set(q,'linewidth',10);

cmp=plot(cm(1),cm(2),'k.');
set(cmp,'markersize',12);
text(cm(1)+0.2,cm(2)+0.2,'C');

C1p=plot([Co1(:,1);Co1(1,1)],[Co1(:,2);Co1(1,2)],'k.');
set(C1p,'markersize',2);
C2p=plot([Co2(:,1);Co2(1,1)],[Co2(:,2);Co2(1,2)],'k.');
set(C2p,'markersize',2);

hold off;

print '-deps' '-S640,480' 'omotetia.eps';