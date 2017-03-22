x = 0:0.01:3;
plot (x, erf (x));
hold on;
plot (x,x,"r");
axis ([0, 3, 0, 1]);
text (0.65, 0.6175, strcat('\leftarrow x = {2/\surd\pi',
' {\fontsize{16}\int_{\fontsize{8}0}^{\fontsize{8}x}}',
' e^{-t^2} dt} = 0.6175'));
xlabel=strcat('\leftarrow x = {2/\surd\pi',
' {\fontsize{16}\int_{\fontsize{8}0}^{\fontsize{8}x}}',
' e^{-t^2} dt} = 0.6175');
set(gca, 'xlabel', xlabel);