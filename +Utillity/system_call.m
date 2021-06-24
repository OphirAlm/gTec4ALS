function system_call(varargin)
% This callback resumes progress of main GUI

% Extract GUI structure
GUI = varargin{1,end};

% Resume running program
uiresume(GUI.fh);
end