function [Hz, trialLength, nClass, subID, numTrials, RS_len, accumilationFlag]...
    = extract_parameters(GUI, system)
% EXTRACT_PARAMETERS extract User's parameters' definition
%
% INPUT:
%     - GUI - Gui structure
%     - system - String of chosen system name
%
% OUTPUT:
%     - Hz - Sampling rate
%     - trialLength - Trial length
%     - nClass - Number of classes
%     - subID - Subject number
%     - numTrials - Number of trials, PER CLASS
%     - RS_len - Resting state length, in seconds
%     - accumilationFlag - Boolean variable for model creation data
%                          accumulation purpose

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract sampling rate value
posHz = GUI.Hz.Value;
Hz    = str2double(GUI.Hz.String(posHz,:));

% Extract Delay Line size (in sec)
trialLength = str2double(GUI.ChunkSz.String);

% Extract number of calsses
nClass = str2double(GUI.nCls.String);

% Extract subject ID number
subID = str2double(GUI.subID.String);

% Number of trials is important for non-Communication systems
if ~strcmpi(system, 'Communication')
    numTrials = str2double(GUI.nTrial.String);
else
    numTrials = [];
end

% Extract resting state delay Line size (in sec)
RS_len = str2double(GUI.RSlength.String);

% Accumulation is important for Online system only
if strcmpi(system, 'Online')
    accumilationFlag = GUI.accumbx.Value;
else
    accumilationFlag = [];
end
end