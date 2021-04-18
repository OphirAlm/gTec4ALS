function parameterSetting(SubID, Fs, trialLength)

if ~exist(Fs, 'var')
    Fs = 256;
end
if ~exist(trialLength, 'var')
    trialLength = 5;
end

f = 8:0.1:30;

startSessionQue = 111;
endTrialQue = 9;
startTrialQue = 1111;
endSessionQue = 99;
idleQue = 1;
leftQue = 2;
rightQue = 3;

window_sz = round(0.5*Fs);
overlap_sz = floor(0.49*Fs);

trials_N = 10;
max_trials = 10;
Font.axesmall = 13; %Axes font size
Font.axebig = 16; %Axes font size.
Font.label = 14; %Labels font size.
Font.title = 18; %Titles font size.

save(['c:/subjects/Sub' num2str(SubID) '/parameters']);

end