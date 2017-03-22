x=[0 .5 1 1.5 2 4 8 16 14 10];

figure(1)
plot(x,'ko');

dx=[-1 0 1];
y=conv(x,-dx);
y=y(2:length(y)-1);

hold
plot(y(2:length(y)-1),'r+');