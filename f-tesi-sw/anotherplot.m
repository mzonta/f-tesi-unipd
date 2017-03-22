x=[1 2 3];
y=[10 20 15;50 80 100];
h=bar(x,y');
set(h(1),"facecolor","r")
set(h(2),"facecolor","g")
box("off")
 
%make the legend
legend("x","y","location","northwest")
h2=legend('right');
%remember to use the handler from
%the last time you call legend()
set(h2,"fontweight","bold")
 
%change axis properties
h=get (gcf, "currentaxes");
set(h,"fontweight","bold")
set(h,"xtick",[1 2 3])
set(h,"xtick", [])
%set(h,"xticklabel",['\Delta \phi';'a' ;'f'])
set(h,"xlabel",'\Delta \phi')
set(h,"interpreter","tex")

text(1, 0, '\Delta \phi')

print -deps -color ticks.eps