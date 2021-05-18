%% Offline Preprocessing
function Preprocess(recordingFolder)
%% Some parameters (this needs to change according to your system):

highLim = 30;                               % filter data under 30 Hz- common 40, we changed it due to noisy data
lowLim = 8;                               % filter data above 0.5 Hz

load([recordingFolder, 'parameters.mat']);
load([recordingFolder, 'trainingVec.mat']);
TEMP = load([recordingFolder,'EEG.mat']);
MIData = TEMP.EEG;



% update channel names - each group should update this according to
% their own openBCI setup.


EEG_chans(1,:) = 'FC3';
EEG_chans(2,:) = 'FCz';
EEG_chans(3,:) = 'FC4';
EEG_chans(4,:) = 'C05';
EEG_chans(5,:) = 'C03';
EEG_chans(6,:) = 'C01';
EEG_chans(7,:) = 'Czz';
EEG_chans(8,:) = 'C02';
EEG_chans(9,:) = 'C04';
EEG_chans(10,:) = 'C06';
EEG_chans(11,:) = 'CP3';
EEG_chans(12,:) = 'CP1';
EEG_chans(13,:) = 'CPz';
EEG_chans(14,:) = 'CP2';
EEG_chans(15,:) = 'CP4';
EEG_chans(16,:) = 'Fzz';

numChans = size(EEG_chans,1);


%% Bandpass filter

% for n = 1:size(MIData,3)
%     for m = 1:size(MIData,1)
%         MIData(m,:,n) = bpfilt(MIData(m, :, n)',lowLim, highLim,Fs,0);
%     end
% end

%% Laplace

motorIndex = {'C03','C04','Czz', 'Fzz', 'FCz', 'FC4', 'FC3'};     
EEG_chans_cell = cellstr(EEG_chans);
elecIndex = zeros(numChans, 1);
for i = 1 : length(motorIndex)
    elecIndex = elecIndex + strcmp(motorIndex(i), EEG_chans_cell);
end

ref_chans_right = {'C02', 'FC4', 'C06', 'CP4'};
ref_chans_left = {'C01', 'FC3', 'C05', 'CP3'};
ref_chans_mid = {'C01', 'FCz', 'C02', 'CPz'};
refIndex_right = zeros(numChans, 1);
refIndex_left = zeros(numChans, 1);
refIndex_mid = zeros(numChans, 1);

for i = 1 : length(ref_chans_right)
    refIndex_right = refIndex_right + strcmp(ref_chans_right(i), EEG_chans_cell);
    refIndex_left = refIndex_left + strcmp(ref_chans_left(i), EEG_chans_cell);
    refIndex_mid = refIndex_mid + strcmp(ref_chans_mid(i), EEG_chans_cell);
end
refIndex_right = logical(refIndex_right);
refIndex_left = logical(refIndex_left);
refIndex_mid = logical(refIndex_mid);
elecIndex = logical(elecIndex);

ref_right = mean(MIData(refIndex_right, :, :), 1);
ref_left = mean(MIData(refIndex_left, :, :), 1);
ref_mid = mean(MIData(refIndex_mid, :, :), 1);

% Search for electrodes that needs laplacian
leftInd = strcmp(EEG_chans_cell, 'C03');
rightInd = strcmp(EEG_chans_cell, 'C04');
midInd = strcmp(EEG_chans_cell, 'Czz');


% Applly Laplacian
MIData(leftInd, :, :) = MIData(leftInd, :, :) - ref_left;
MIData(rightInd, :, :) = MIData(rightInd, :, :) - ref_right;
MIData(midInd, :, :) = MIData(midInd, :, :) - ref_mid;

% Get final results
MIData = MIData(elecIndex,: , :);


%% Finding trials to remove
over_max = max(MIData, [], 2);
below_min = min(MIData, [], 2);
over_max = squeeze(over_max > 150);
below_min = squeeze(below_min < -150);
trials2remove = over_max + below_min;
trials2remove = trials2remove(1, :) + trials2remove(2, :) + trials2remove(3, :);
trials2remove = logical(trials2remove);

save(strcat(recordingFolder,'\trials2remove.mat'),'trials2remove');


%% Save the data into .mat variables on the computer

save(strcat(recordingFolder,'\','MIData.mat'),'MIData');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
                
end
