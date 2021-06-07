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
                 'position',[0.3 0.3 0.4 0.3],...
                 'menubar','none',...
                 'name','User interface',...
                 'numbertitle','off',...
                 'resize','off');
             
% Set title text
GUI.title = uicontrol('style','text',...                 
                     'unit','normalized',...
                     'position',[0.2 0.7 0.6 0.15],...
                     'string','Choose a system to operate');
                 
% Set confirmation button
GUI.pb    = uicontrol('style','push',...                  
                    'unit','normalized',...
                    'position',[0.75 0.1 0.2 0.1],...
                    'string','Ok');
                 
% Set communication toggle button
GUI.commbx = uicontrol('style','togglebutton',...              
                    'string', 'Communication system',...
                    'unit','normalized',...
                    'position',[0.05 0.3 0.25 0.4]);
                 
% Set online toggle button
GUI.onbx = uicontrol('style','togglebutton',...              
                    'string', 'Online training system',...
                    'unit','normalized',...
                    'position',[0.35 0.3 0.25 0.4]);
                 
% Set offline toggle button
GUI.offbx = uicontrol('style','togglebutton',...              
                    'string', 'Offline training system',...
                    'unit','normalized',...
                    'position',[0.65 0.3 0.25 0.4]);
                
% Set toggle callbacks
set(GUI.commbx,'callback',{@Utillity.toggle_call,GUI});      
set(GUI.onbx,'callback',{@Utillity.toggle_call,GUI});        
set(GUI.offbx,'callback',{@Utillity.toggle_call,GUI});       

% Set confirmation button callback
set(GUI.pb,'callback',{@Utillity.system_call,GUI});   

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
    else
        % If no toggle button was chosen, print a question dialog for
        % verification - quit or choose
        
        % Set question dialog texts
        msg = 'Non of the systems were chosen. Would you like to quit?';
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