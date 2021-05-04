function Impedance_call(varargin)
% Callback for checkboxes.

% Extract Impedance object string
IMPobj = varargin{1,end};

% Open Impedance object
open_system(IMPobj);
end