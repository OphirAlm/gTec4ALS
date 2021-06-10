function pb_call(varargin)
% Callback for confirmation pushbutton.
% Extract user's desired parameters and set Simulink objects accordingly

% Get objects' names 
ChunkDelayobj = varargin{1,end-3};   
AMPobj        = varargin{1,end-2};   
RestDelayobj  = varargin{1,end-1};   
% Get structure
S = varargin{1,end};     

%% Sampling rate
% Extract sampling rate position from list
posHz = S.Hz.Value;                
% Extract sampling rate
Hz    = str2double(S.Hz.String(posHz,:));

%% Trial length
% Extract Delay Line size (in sec) 
% Multiply by sampling rate, for sampling units
ChunkSzCalc = Hz*str2double(S.ChunkSz.String);
ChunkSz     = num2str(ChunkSzCalc);       

%% Resting state length
% Extract Resting state Delay Line size (in sec) 
% Multiply by sampling rate, for sampling units
ResSzCalc  = Hz*str2double(S.RSlength.String);
ResDelaySz = num2str(ResSzCalc);   

%% Set Simulink objects run time
% % % TODO: find the name of Simulink amplifier sampling rate parameter
% % % set_param(AMPobj,'',Hz);                % Set sampling rate
set_param(ChunkDelayobj,'siz',ChunkSz);   % Set Delay size
set_param(RestDelayobj,'siz',ResDelaySz); % Set resting Delay size

%% Resume running program
uiresume(S.fh);
end