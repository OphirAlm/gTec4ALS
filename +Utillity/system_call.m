function system_call(varargin)
% This callback resumes progress of main GUI

% Extract GUI structure
S = varargin{1,end};

% Resume running program
uiresume(S.fh);
end