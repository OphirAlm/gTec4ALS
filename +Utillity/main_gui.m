function system = main_gui()

S.fh    = figure('units','normalized',...                   % set figure
                 'position',[0.3 0.3 0.4 0.3],...
                 'menubar','none',...
                 'name','User interface',...
                 'numbertitle','off',...
                 'resize','off');
             
S.title = uicontrol('style','text',...                 % set Title text
                     'unit','normalized',...
                     'position',[0.2 0.7 0.6 0.15],...
                     'string','Choose a system to operate');
                 
S.pb    = uicontrol('style','push',...                  % set confirmation button
                    'unit','normalized',...
                    'position',[0.75 0.1 0.2 0.1],...
                    'string','Ok');
                 
S.commbx = uicontrol('style','togglebutton',...              % set Impedance checkbox
                    'string', 'Communication system',...
                    'unit','normalized',...
                    'position',[0.05 0.3 0.25 0.4]);
                 
S.onbx = uicontrol('style','togglebutton',...              % set Impedance checkbox
                    'string', 'Online training system',...
                    'unit','normalized',...
                    'position',[0.35 0.3 0.25 0.4]);
                 
S.offbx = uicontrol('style','togglebutton',...              % set Impedance checkbox
                    'string', 'Offline training system',...
                    'unit','normalized',...
                    'position',[0.65 0.3 0.25 0.4]);
                
                
set(S.commbx,'callback',{@Utillity.toggle_call,S});       % Set the callback, pass hands.
set(S.onbx,'callback',{@Utillity.toggle_call,S});       % Set the callback, pass hands.
set(S.offbx,'callback',{@Utillity.toggle_call,S});       % Set the callback, pass hands.

set(S.pb,'callback',{@Utillity.system_call,S});   % Set the callback, pass hands.

uiwait(S.fh);

if S.commbx.Value == 1
    system = 'Communication';
elseif S.onbx.Value == 1
    system = 'Online';
elseif S.offbx.Value == 1
    system = 'Offline';
else
    system = '';
end

close(S.fh);
end