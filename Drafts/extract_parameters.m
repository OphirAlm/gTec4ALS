function [Hz, BufSz, nClass, subID, f, numTrials, RS_len, accumilationFlag] = extract_parameters(S)

posHz       = S.Hz.Value;                       % Get sampling rate value
Hz          = str2double(S.Hz.String(posHz,:));

BufSz       = str2double(S.ChunkSz.String);       % Get Buffer size (in sec) times sampling rate

nClass      = str2double(S.nCls.String);        % Get number of calsses
subID       = str2double(S.subID.String);       % Get subject ID number

f           = str2double(S.rng(1).String):0.1:str2double(S.rng(2).String); % Get frequency range

numTrials   = str2double(S.nTrial.String);      % Get number of trials

RS_len      = str2double(S.RSlength.String);    % Get resting state record length

accumilationFlag = S.accumbx.Value;
end