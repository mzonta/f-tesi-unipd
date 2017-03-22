function neodemo ( azione,arg )

global titolo_demo f_salva f_chiudi f_stampa im_aperta menu_esegui; 
global v_par im_vis IM_IN;

% Titolo dell'applicazione.
titolo_demo='Demo Software Analisi Caratteristiche Geometriche Cute';

if nargin<1
   
   azione='inizializza';
   
end

if strcmp(azione,'inizializza')
   
   %old_fig=watchon;
   
   im_aperta=0;
   
   %================================================================
   %figNumber = figure(...
   figure(...
      'visible','on',...
      'NumberTitle','off',...
      'Name',titolo_demo,...
      'pointer','watch',...
      'MenuBar','none');

   wids = 0.26;
   %axes(...
   %   'position', [0.1 .22 .9*(.9-wids) .68], ...
   %   'vis','off');   
   axes(...
      'position',[.1 .1 .8 .8],...
      'visible','on',...
      'XTick',[],...
      'XTickLabel',[],...
      'XColor',[1 1 1],...
      'YTick',[],...
      'YTickLabel',[],...
      'YColor',[1 1 1]);
   
   % Men FILE 
   menu_File=uimenu('Label','File');
   
   f_apri=uimenu(menu_File,...
      'Label','Apri',...
      'Callback','neodemo(''apri_im'')');
   
   f_chiudi=uimenu(menu_File,...
      'Label','Chiudi',...
      'Callback','neodemo(''chiudi'')',...
      'Enable','off');
   
   f_stampa=uimenu(menu_File,...
      'Label','Stampa',...
      'Enable','off');
   f_stmp_im=uimenu(f_stampa,...
      'Label','Stampa Immagine',...
      'Callback','neodemo(''stampa_im'')');
   f_stmp_mis=uimenu(f_stampa,...
      'Label','Stampa Misure',...
      'Callback','neodemo(''stampa_mis'')');
   
   f_esci=uimenu(menu_File,...
      'Label','Esci',...
      'Callback','neodemo(''esci'')',...
      'Separator','on',...
      'Accelerator','Q');
   
   % Men ESEGUI
   menu_esegui=uimenu(...
      'Label','Esegui',...
      'Callback','neodemo(''esegui'',arg)',...
      'Enable','off');
   % Viene attivato dopo aver impostato i parametri e con immagine aperta.
   
   % Men PARAMETRI
   menu_parametri=uimenu(...
      'Label','Parametri');
   
   par_mis=uimenu(menu_parametri,...
      'Label','Parametri Misure',...
      'Callback','neodemo(''imp_par'')');
   
   tipo_mis=uimenu(menu_parametri,...
      'Label','Imposta Misure',...
      'Callback','neodemo(''imp_mis'')');
   
   % Men GUIDA
   menu_guida=uimenu('Label','Guida');
   
   % Men INFORMAZIONI
   menu_informazioni=uimenu(...
      'Label','Informazioni',...
      'Callback','neodemo(''note_info'')');
   
   %=======================================================================
   
   %load gprova;
   %plot([G(:,1);G(1,1)],[G(:,2);G(1,2)],'r-');
   
   % Imposta il puntatore del mouse nella finestra.
   set(gcf,'pointer','arrow');
   
   %watchoff(old_fig);
   
   %=======================================================================
   % Apre file immagine selezionato.
   
elseif strcmp(azione,'apri_im')
   
   % Apre il file selezionato.
   [file_im,file_path]=uigetfile('*.bmp;*.jpg;*.tif','Apri');
   
   % Imposta il puntatore del mouse nella finestra.
   set(gcf,'pointer','watch');
   
   file_nome=strcat(file_path,file_im);
   
   % Carica immagine.
   IM_IN=imread(file_nome);
   
   im_aperta=1;
   
   % Viene visualizzata sul pannello principale.
   im_vis=imshow(IM_IN);
   
   nuovo_nome=strcat(titolo_demo,'- [',file_im,']');
   set(gcf,'Name',nuovo_nome);
     
   % Attivare la voce "Salva Risultati".
   set(f_salva,'Enable','on');
   
   % Attivare la voce "Chiudi".
   set(f_chiudi,'Enable','on');
   
   % Attivare la voce "Stampa".
   set(f_stampa,'Enable','on');
   
   % Attivare la voce "Esegui".
   set(menu_esegui,'Enable','on');

   % Imposta il puntatore del mouse nella finestra.
   set(gcf,'pointer','arrow');
   
   %=======================================================================
   % Salva l'immagine ottenuta dall'elaborazione.
      
elseif strcmp(azione,'salva_im')
   
   %=======================================================================
   % Salva le misure ottenute dall'elaborazione.
      
elseif strcmp(azione,'salva_mis')
   
   %=======================================================================
   % Stampa l'immmagine corrente.      
   
elseif strcmp(azione,'stampa_im')
   
   printdlg;
   
   %=======================================================================
   % Stampa tabella dei risultati dell'elaborazione.      
   
elseif strcmp(azione,'stampa_mis')
   
   %=======================================================================
   % Chiude la figura aperta e si prepara per una nuova esecuzione.
      
elseif strcmp(azione,'chiudi')
   
   % Imposta il puntatore del mouse nella finestra.
   set(gcf,'pointer','watch');
   
   % Ripulisce l'immagine corrente, sia in video che in memoria.
   delete(im_vis);
   clear IM_IN;
   
   im_aperta=0;
   
   nessun_nome=strcat(titolo_demo,' -[Indefinito]');
   set(gcf,'Name',nessun_nome);
  
   % Disattivare la voce "Salva Risultati".
   set(f_salva,'Enable','off');
   
   % Disattivare la voce "Chiudi".
   set(f_chiudi,'Enable','off');
   
   % Disttivare la voce "Stampa".
   set(f_stampa,'Enable','off');
   
   % Disttivare la voce "Esegui".
   set(menu_esegui,'Enable','off');
   
   axes(...
      'position',[.1 .1 .8 .8],...
      'visible','on',...
      'XTick',[],...
      'XTickLabel',[],...
      'XColor',[1 1 1],...
      'YTick',[],...
      'YTickLabel',[],...
      'YColor',[1 1 1]);
   
   % Imposta il puntatore del mouse nella finestra.
   set(gcf,'pointer','arrow');
   
   %=======================================================================
   % Esci da NEODEMO. 
   
elseif strcmp(azione,'esci');
   
   if (im_aperta~=0)
      
      % C' un'immagine aperta e pu darsi che non siano stati salvati
      % i risultati....
      conferma_uscita=questdlg('Salvare prima di uscire ?','Attenzione!',...
         'Si','Annulla','No','No');
      
      if strcmp(conferma_uscita,'No');
         
         close all;
         clear all;
      
      elseif strcmp(conferma_uscita,'Si')
         
         uiputfile('*.neo','Salva');
         
      end
      
   else
   
      % Nessuna immagine aperta
      close all;
      clear all
      
   end
         
   %=======================================================================
   % Esecuzione delle operazioni secondo i parametri impostati.
elseif strcmp(azione,'esegui')
   
   %old_fig=watchon;
      
   ttlStr='Risultato elaborazione';
         
   pos=get(0,'DefaultFigurePosition');
   ris_fig=figure(...
      'Name',ttlStr,...
      'NumberTitle','off',...
      'Position',pos,...
      'MenuBar','none');
      
   % ...continuare....
   
   %watchoff(old_fig);
   
   %=======================================================================
   % Imposta parametri misure.
elseif strcmp(azione,'imp_par')
   
   % Si caricano i vettori par_Strs e par_default dal file "File_par0.mat".
   %load File_par0;
   par_default={0,'S/N',0};
   par_Strs={'primo','secondo','terzo'};
   
   
   ttl_par='Parametri di esecuzione';
   
   v_par=inputdlg(par_Strs,ttl_par,1,par_default);
   
   %=======================================================================
   % Imposta misure.
elseif strcmp(azione,'imp_mis')

   %=======================================================================
   % Guida in linea.
elseif strcmp(azione,'guida')
   
   ttlStr='Guida in linea';
   guidaStr='Aiutoooooo';
      
   %old_fig=watchon;
      
   pos=get(0,'DefaultFigurePosition');
   guida_fig=figure(...
      'Name',ttlStr,...
      'NumberTitle','off',...
      'Position',pos,...
      'MenuBar','none');
      
   uicontrol(...
      'Style','edit',...
      'Units','normalized',...
      'Position',[.05 .05 .9 .9],...
      'HorizontalAlignment','Left',...
      'BackgroundColor',[1 1 1],...
      'Max',30,'String',guidaStr);
      
   %watchoff(old_fig);
      
   %======================================================================
   % Informazioni su Autore, Q-MED, Frezza-UniPD
   
elseif strcmp(azione,'note_info')
   
   infottl='Informazioni Copyright';
   infoStr=... 
      ['                                                '
      '    Data: Aprile 2000                           '
      '                                                '
      '                                                '
      '    Copyright (c)                               '
      '    Autore: Massimiliano Zonta                  '
      '    Relatore: Prof. Ruggero Frezza              '
      '                                                '
      '    Universit degli Studi di Padova            '
      '    Dipartimento di Elettronica e Informatica   '
      '                                                '
      '    In collaborazione con                       '
      '    Quadra Medical di Romano d''Ezzelino (VI)    '];
       
      %old_fig=watchon;
      
   pos=[300 200 400 400];
   info_fig=figure(...
      'Name',infottl,...
      'NumberTitle','off',...
      'Position',pos,...
      'MenuBar','none');
      
   uicontrol(...
      'Style','edit',...
      'Units','normalized',...
      'Position',[.05 .2 .9 .7],...
      'HorizontalAlignment','Left',...
      'BackgroundColor',[1 1 1],...
      'Max',20,'String',infoStr);
   
   OKPos=[.4 .05 .2 .08];
   
   CloseString='set(gcf,''UserData'',''OK'');close(gcf)';
   
   uicontrol(info_fig,...
      'Style','pushbutton',...
      'Units','normalized',...
      'Position',OKPos,...
      'String','OK',...
      'Callback',CloseString,...
      'Tag','OK');
   
     
   %watchoff(old_fig);
    
   %======================================================================

   
end
