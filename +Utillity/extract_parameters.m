function [Hz, chunckSz, nClass, subID, numTrials, RS_len, accumilationFlag]...
    = extract_parameters(S, system)
% This function extract User's defined parameters

% Extract sampling rate value
posHz       = S.Hz.Value;
Hz          = str2double(S.Hz.String(posHz,:));

% Extract Delay Line size (in sec)
chunckSz    = str2double(S.ChunkSz.String);

% Extract number of calsses
nClass      = str2double(S.nCls.String);

% Extract subject ID number
subID       = str2double(S.subID.String);

% For non-Communication systems
if ~strcmpi(system, 'Communication')
    % Extract number of trials
    numTrials   = str2double(S.nTrial.String);
else
    % Otherwise, not important
    numTrials = [];
end

% Extract Resting state Delay Line size (in sec)
RS_len      = str2double(S.RSlength.String);

% Extract whether to accumulate or not if online
if strcmpi(system, 'Online')
    accumilationFlag = S.accumbx.Value;
else
    % Otherwise, not important
    accumilationFlag = [];
end
end