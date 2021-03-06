function breakGUI()

% Set figure
GUI.fh    = figure('units','normalized',...
    'position',[0.66 0.6 0.3 0.2],...
    'menubar','none',...
    'name','Continue',...
    'numbertitle','off',...
    'resize','off');

% Set title text
GUI.title = uicontrol('style','text',...
    'unit','normalized',...
    'position',[0.1 0.6 0.8 0.3],...
    'string','Make sure you closed the dialog box before pressing "continue"',...
    'FontSize',18);

GUI.H = uicontrol('Style', 'PushButton', ...
              'String', 'Continue',...
              'FontSize',12, ...
              'Callback', 'delete(gcbf)',...
              'unit','normalized',...
              'position',[0.4 0.2 0.2 0.2]);
          
while (ishandle(GUI.H))
   pause(0.5);
end