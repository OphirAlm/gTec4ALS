function pb_call(varargin)
% Callback for pushbutton.
% Extract user's desired parameters and set Simulink objects accordingly

ChunkDelayobj = varargin{1,end-3};   % Get Delay Line string
AMPobj        = varargin{1,end-2};   % Get Amplifier string
RestDelayobj  = varargin{1,end-1};   % Get Resting state Delay Line string
S             = varargin{1,end};     % Get structure.

% Extract sampling rate
posHz         = S.Hz.Value;                
Hz            = str2double(S.Hz.String(posHz,:));

% Extract Delay Line size (in sec) 
% Multiply by sampling rate, for sampling units
ChunkSzCalc   = Hz*str2double(S.ChunkSz.String);
ChunkSz       = num2str(ChunkSzCalc);       

% Extract Resting state Delay Line size (in sec) 
% Multiply by sampling rate, for sampling units
ResSzCalc     = Hz*str2double(S.RSlength.String);
ResDelaySz    = num2str(ResSzCalc);   

% Set Simulink objects run time
% TODO: find the FUCKING name of the sampling rate parameter
% set_param(AMPobj,'',Hz);                % Set sampling rate
set_param(ChunkDelayobj,'siz',ChunkSz);   % Set Delay size
set_param(RestDelayobj,'siz',ResDelaySz); % Set resting Delay size

% Resume running program
uiresume(S.fh);
end