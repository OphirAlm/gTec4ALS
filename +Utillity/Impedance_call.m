function Impedance_call(varargin)
% Callback for impedance pushbutton.

% Extract Impedance object string
IMPobj = varargin{1,end};

% Open Impedance object
open_system(IMPobj);
end