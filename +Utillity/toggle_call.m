function toggle_call(varargin)
% This callback make sure that only one system is pressed

% Extract GUI structure
S = varargin{1,end};

% Extract toggled system
str = varargin{1,1}.String;

% For every system toggled, turn both other into untoggled
if strcmpi(str,'Communication system')
    S.onbx.Value = 0;
    S.offbx.Value = 0;
elseif strcmpi(str,'Online training system')
    S.commbx.Value = 0;
    S.offbx.Value = 0;
else
    S.onbx.Value = 0;
    S.commbx.Value = 0;
end

end