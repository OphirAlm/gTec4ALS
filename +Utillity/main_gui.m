function system = main_gui()
% MAIN_GUI function main_gui creates a gui for choosing a system to
% operate. Systems possible for operation are: offline system, online system and
% communication system.
%
% OUTPUT:
%     - system - String containing the name of the chosen system (i.e.,
%           'Offline', 'Online, 'Communication'). If no system was chosen, system
%           is an empty string (i.e., '')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Boolean variable for user choice verification
chooseFlag = 0;

% Set figure
GUI.fh    = figure('units','normalized',...                   
                 'position',[0.2 0.3 0.5 0.4],...
                 'menubar','none',...
                 'name','User interface',...
                 'numbertitle','off',...
                 'resize','off');
             
% Set title text
GUI.title = uicontrol('style','text',...                 
                     'unit','normalized',...
                     'position',[0.2 0.75 0.6 0.2],...
                     'string','Choose a system to operate',...
                     'FontSize',22);
                 
% Set confirmation button
GUI.pb    = uicontrol('style','push',...                  
                    'unit','normalized',...
                    'position',[0.75 0.1 0.2 0.1],...
                    'string','Ok',...
                     'FontSize',14);
         
% Set exit button
GUI.exit    = uicontrol('style','push',...                  
                    'unit','normalized',...
                    'position',[0.5 0.1 0.2 0.1],...
                    'string','Quit',...
                     'FontSize',14);

% Set communication toggle button
GUI.exitToggle = uicontrol('style','togglebutton',...              
                    'Visible','off');
                
% Set communication toggle button
GUI.commbx = uicontrol('style','togglebutton',...              
                    'string', '<html>Communication<br>System',...
                     'FontSize',14,...
                    'unit','normalized',...
                    'position',[0.025 0.3 0.2 0.4]);
                 
% Set online toggle button
GUI.onbx = uicontrol('style','togglebutton',...              
                    'string', '<html>Online<br>Training<br>System',...
                     'FontSize',14,...
                    'unit','normalized',...
                    'position',[0.275 0.3 0.2 0.4]);
                 
% Set offline toggle button
GUI.offbx = uicontrol('style','togglebutton',...              
                    'string', '<html>Offline<br>Training<br>System',...
                     'FontSize',14,...
                    'unit','normalized',...
                    'position',[0.525 0.3 0.2 0.4]);
      
% Set impedance and scope toggle button
GUI.impscope = uicontrol('style','togglebutton',...              
                    'string', '<html>Signal<br>Check',...
                     'FontSize',14,...
                    'unit','normalized',...
                    'position',[0.775 0.3 0.2 0.4]);
                
% Set toggle callbacks
set(GUI.commbx,'callback',{@Utillity.toggle_call,GUI});      
set(GUI.onbx,'callback',{@Utillity.toggle_call,GUI});        
set(GUI.offbx,'callback',{@Utillity.toggle_call,GUI});       
set(GUI.impscope,'callback',{@Utillity.toggle_call,GUI});

% Set confirmation button callback
set(GUI.pb,'callback',{@Utillity.system_call,GUI});   

% Set exit button callback
set(GUI.exit,'callback',{@Utillity.exit_system,GUI}); 

% Loop until user descision
while ~chooseFlag
    % Wait for reaction
    uiwait(GUI.fh);
    
    % Set output variable according to toggle buttons value
    if GUI.commbx.Value == 1
        system = 'Communication';
        chooseFlag = 1;
    elseif GUI.onbx.Value == 1
        system = 'Online';
        chooseFlag = 1;
    elseif GUI.offbx.Value == 1
        system = 'Offline';
        chooseFlag = 1;
    elseif GUI.impscope.Value == 1
        system = 'impScope';
        chooseFlag = 1;
    elseif GUI.exitToggle.Value == 1
        system = '';
        chooseFlag = 1;
    else
        % If no toggle button was chosen, print a question dialog for
        % verification - quit or choose
        
        % Set question dialog texts
        msg = 'None of the systems were chosen. Would you like to quit?';
        title = 'No system chosen';
        choose = 'Choose a system';
        quit = 'Quit';
        
        % Print dialog
        answer = questdlg(msg,title, ...
            quit, choose, choose);
        % Handle response
        switch answer
            case quit
                system = '';
                chooseFlag = 1;
            case choose
                continue
        end
    end
end

% After determining user's choice, close gui
close(GUI.fh);
end