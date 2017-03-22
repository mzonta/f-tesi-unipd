d = dir;
str = {d.name};

dir_corr=cd;

[s,v] = listdlg('Name','Cambia Directory',...
                'PromptString',dir_corr,... 
                'ListSize',[300,300],...
                'fus',20,...
                'ffs',20,...   
                'CancelString','Annulla',...
                'SelectionMode','single',...
                'ListString',str);
             
             
if (s==1)
   
   cd ..;
   
elseif (s>2)
   
   nuova_dir=str(s)
   
   cd nuova_dir;
   
end

             
