function pb_call(varargin)
% Callback for pushbutton.
ChunkDelayobj     = varargin{1,end-3};        % Get Buffer string
AMPobj      = varargin{1,end-2};        % Get Amplifier string
RestDelayobj = varargin{1,end-1};        % Get Amplifier string
S           = varargin{1,end};          % Get structure.

posHz       = S.Hz.Value;               % Get sampling rate value
Hz          = str2double(S.Hz.String(posHz,:));

ChunkSzCalc   = Hz*str2double(S.ChunkSz.String);
ChunkSz       = num2str(ChunkSzCalc);       % Get Buffer size (in sec) times sampling rate

ResSzCalc     = Hz*str2double(S.RSlength.String);
ResDelaySz    = num2str(ResSzCalc);            % Get resting state Buffer size (in sec) times sampling rate

% TODO: find the FUCKING name of the sampling rate parameter
% set_param(AMPobj,'',Hz);                % Set sampling rate 
set_param(ChunkDelayobj,'siz',ChunkSz);           % Set Buffer size
set_param(RestDelayobj,'siz',ResDelaySz);    % Set Buffer size

S.fh.Visible = 'off';

uiresume(S.fh);
end