function toggle_call(varargin)
% This callback make sure that only one system is pressed

% Extract GUI structure
GUI = varargin{1,end};

% Extract toggled system
str = varargin{1,1}.String;

% For every system toggled, turn both other into untoggled
if strcmpi(str,'<html>Communication<br>System')
    GUI.onbx.Value = 0;
    GUI.offbx.Value = 0;
    GUI.impscope.Value = 0;
elseif strcmpi(str,'<html>Online<br>Training<br>System')
    GUI.commbx.Value = 0;
    GUI.offbx.Value = 0;
    GUI.impscope.Value = 0;
elseif strcmpi(str,'<html>Offline<br>Training<br>System')
    GUI.onbx.Value = 0;
    GUI.commbx.Value = 0;
    GUI.impscope.Value = 0;
elseif strcmpi(str,'<html>Signal<br>Check')
    GUI.onbx.Value = 0;
    GUI.commbx.Value = 0;
    GUI.offbx.Value = 0;
end

end