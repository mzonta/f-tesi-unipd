x_2=0.5;
x_1=1;
x=0.7;
x1=0.9;
x2=0.4;

xv=[x_2 x_1 x x1 x2]

u_2=-2;
u_1=-1;
u=0;
u1=1;
u2=2;
u3=3;
u4=4;

uv=[u_1 u u1 u2 u3]


plot(uv, xv, 'k.-');

axis([-2 4 0 1.1]);
axis off;

set(gca, 'xticklabel',[]);
text(u_2,-0.1,'u_{i-2}','VerticalAlignment','Top')
text(u_1,-0.1,'u_{i-1}','VerticalAlignment','Top')
text(u,-0.1,'u_{i}','VerticalAlignment','Top')
text(u1,-0.1,'u_{i+1}','VerticalAlignment','Top')
text(u2,-0.1,'u_{i+2}','VerticalAlignment','Top')
text(u3,-0.1,'u_{i+3}','VerticalAlignment','Top')
text(u4,-0.1,'u_{i+4}','VerticalAlignment','Top')

text(u_1-0.3,x_2+0.1,'x_{i-2}','VerticalAlignment','Top')
text(u-0.1,x_1+0.1,'x_{i-1}','VerticalAlignment','Top')
text(u1,x+0.1,'x_{i}','VerticalAlignment','Top')
text(u2-0.1,x1+0.1,'x_{i+1}','VerticalAlignment','Top')
text(u3,x2+0.1,'x_{i+2}','VerticalAlignment','Top')


hold on;
plot([u_2 u_1 u u1 u2 u3 u4], [0 0 0 0 0 0 0], 'k+');
plot([u_1 u u1], [0 x_1 0], 'k--');
plot([u u1 u2], [0 x 0], 'k-.');

hold off;


print('linearBs.eps', '-depslatexstandalone', '-S400,200');
