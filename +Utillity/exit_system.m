function exit_system(varargin)
% This callback exit from main GUI

% Extract GUI structure
GUI = varargin{1,end};

% Set exit value to exit
GUI.exitToggle.Value = 1;
GUI.commbx.Value = 0;
GUI.onbx.Value = 0;
GUI.offbx.Value = 0;
GUI.impscope.Value = 0;

% Resume running program
uiresume(GUI.fh);
end