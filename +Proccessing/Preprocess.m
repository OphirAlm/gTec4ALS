%% Offline Preprocessing
function [MIData, removeTrial] = Preprocess(raw_EEG, maxAmp)
% Cleans the signal using laplace, arrange relevant electrodes and return
% the wanted EEG signal.
%
% INPUT:
%     - raw_EEG - Raw signal as recieved from the g.tec record.
%     - maxAmp - The amplitude which above or below (Negative) the trial 
%                will be classiffied as noisy (Defaults 150 micro-V).
%
% OUTPUT:
%     - MIData - Segmented EEG signal (trials in rows, sampels in columns)
%     - removeTrial - Vector of trials to remove (Noise\ Artifacts).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set defualt maxAmp value
if nargin < 2
    maxAmp = 150;
end

% update channel names
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

% Get number of channels
numChans = size(EEG_chans,1);

%% Laplace
% INSERT the chosen electrode (C03, C04, Cz must be first and in that
% order)
motorIndex = {'C03','C04','Czz', 'Fzz', 'FCz', 'FC4', 'FC3'};
EEG_chans_cell = cellstr(EEG_chans);
elecIndex = zeros(numChans, 1);
for i = 1 : length(motorIndex)
    elecIndex = elecIndex + strcmp(motorIndex(i), EEG_chans_cell);
end

% Laplace electorodes for C3, C4, Cz
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

% Convert to logical
refIndex_right = logical(refIndex_right);
refIndex_left = logical(refIndex_left);
refIndex_mid = logical(refIndex_mid);
elecIndex = logical(elecIndex);

% Compute laplacian
ref_right = mean(raw_EEG(refIndex_right, :, :), 1);
ref_left = mean(raw_EEG(refIndex_left, :, :), 1);
ref_mid = mean(raw_EEG(refIndex_mid, :, :), 1);

% Search for electrodes that needs laplacian
leftInd = strcmp(EEG_chans_cell, 'C03');
rightInd = strcmp(EEG_chans_cell, 'C04');
midInd = strcmp(EEG_chans_cell, 'Czz');

% Applly Laplacian
raw_EEG(leftInd, :, :) = raw_EEG(leftInd, :, :) - ref_left;
raw_EEG(rightInd, :, :) = raw_EEG(rightInd, :, :) - ref_right;
raw_EEG(midInd, :, :) = raw_EEG(midInd, :, :) - ref_mid;

% Get final results
MIData = raw_EEG(elecIndex,: , :);

%Label as noisy trial
over_max = max(MIData, [], 2) > maxAmp;
below_min = min(MIData, [], 2) < -maxAmp;
if sum(over_max & below_min) == 1
    removeTrial = 1;
else
    removeTrial = 0;
end

end
