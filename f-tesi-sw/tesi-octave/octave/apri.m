function RGB = apri ( fnome )

RGB=imread(fnome);

% N.B. Non è necessario passare attraverso [X,M]; anzi sconveniente.
% Inoltre per ottenere immagine a colori occorre che questa sia
% a 24 bit.