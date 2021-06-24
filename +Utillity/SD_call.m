function SD_call(varargin)
% Callback for signal display pushbutton.

% Extract Impedance object string
scopeObj = varargin{1,end};

% Open Impedance object
open_system(scopeObj);
end