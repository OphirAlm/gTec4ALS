function MI3_SegmentData_Scaffolding(recordingFolder)
%% Segment data using markers
% This function segments the continuous data into trials or epochs in a matrix ready for classifier training.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Parameters and previous variables:
load(strcat(recordingFolder,'\parameters.mat'));
load(strcat(recordingFolder,'\MIData.mat'));                % load the filtered EEG data in .mat format
load(strcat(recordingFolder,'\trainingVec.mat'));                % load the training vector (which target at which trial)
load(strcat(recordingFolder,'\EEG_chans.mat'));                  % load the EEG channel locations
numChans = length(EEG_chans);                                    % how many chans do we have?
load(strcat(recordingFolder,'\EEG_events.mat'));                 % load the EEG event markers

%Ophir's edit:
%Removing anything before recording started
start_index = find(strcmp({EEG_event.type}, '111.0000000000000')==1);
if start_index ~= 1
    EEG_event(1:start_index) = [];
end
trials1 = length(trainingVec);                                  % derive number of trials from training label vector
events = struct('type', {EEG_event(1:end).type});

% Sagi's edit
% double event type vector
events_double = str2double({events.type});
% extract indices of start trials event and first end session event
marker1Index = find(events_double == startTrialQue);
marker3Index = find(events_double == endSessionQue,1);
% delete all indices larger than session end
marker1Index(marker1Index > marker3Index) = [];
% end - Sagi's edit

trials = length(marker1Index);                                    % derive number of trials from start markers

% Check for consistancy across events & trials
if trials ~= trials1
    disp('!!!! Some form of mis-match between number of recorded and planned trials.')
    return
end
MIData = [];                                                 % initialize main matrix


%% Main data segmentation process:
for trial = 1:trials
    [MIData] = sortElectrodes(MIData,EEG_data,EEG_event,Fs,trialLength,marker1Index(trial),numChans,trial);
end

%%
%Ophir's edit
motorIndex = {'C03','C04'};                 % INSERT the chosen electrode (for legend)
EEG_chans_cell = cellstr(EEG_chans);
elecIndex = zeros(numChans, 1);
for i = 1 : length(motorIndex)
    elecIndex = elecIndex + strcmp(motorIndex(i), EEG_chans_cell);
end

ref_chans_right = {'C02', 'FC4', 'C06', 'CP4'};
ref_chans_left = {'C01', 'FC3', 'C05', 'CP3'};
refIndex_right = zeros(numChans, 1);
refIndex_left = zeros(numChans, 1);

for i = 1 : length(ref_chans_right)
    refIndex_right = refIndex_right + strcmp(ref_chans_right(i), EEG_chans_cell);
    refIndex_left = refIndex_left + strcmp(ref_chans_left(i), EEG_chans_cell);
end
refIndex_right = logical(refIndex_right);
refIndex_left = logical(refIndex_left);
elecIndex = logical(elecIndex);

ref_right = mean(MIData(:, refIndex_right, :), 2);
ref_left = mean(MIData(:, refIndex_left, :), 2);

%% Visualization before electrode processing

data = permute(MIData(:,elecIndex,:), [1 3 2]);
idle_idx = find(trainingVec == 1);
left_idx = find(trainingVec == 2);
right_idx = find(trainingVec == 3);
trialT = length(MIData);

Visualize(data , left_idx, right_idx, idle_idx, Fs , f, window_sz ,...
    overlap_sz , motorIndex ,1:trialT , trials_N ,max_trials ,Font)
%% Clean electrodes of interest

MIData = MIData(:, elecIndex, :);
MIData(:, 1, :) = MIData(:, 1, :) - ref_left;
MIData(:, 2, :) = MIData(:, 2, :) - ref_right;

%% Visualization after electrode processing

data = permute(MIData, [1 3 2]);

Visualize(data , left_idx, right_idx, idle_idx, Fs , f, window_sz ,...
    overlap_sz , motorIndex ,1:trialT , trials_N ,max_trials ,Font)

%% Finding trials to remove
over_max = max(MIData, [], 3);
below_min = min(MIData, [], 3);
over_max = over_max >1000;
below_min = below_min < -1000;
trials2remove = over_max + below_min;
trials2remove = trials2remove(:, 1) + trials2remove(:, 2);
trials2remove = logical(trials2remove);

%end - Ophir's edit
data = permute(MIData(:,elecIndex,:), [1 3 2]);
idle_idx = find(trainingVec == 1);
left_idx = find(trainingVec == 2);
right_idx = find(trainingVec == 3);
trialT = length(MIData);
Font = struct('axesmall', 13,...
    'axebig', 16,...
    'label', 14,...
    'title', 18); %Axes font size
Fs = 256;
f = 8:0.1:30;
window_sz = round(0.5*Fs);
overlap_sz = floor(0.49*Fs);

Visualize(data , left_idx, right_idx, idle_idx, Fs , f, window_sz ,...
    overlap_sz , motorIndex ,1:trialT , 10 ,10 ,Font)
%%

save(strcat(recordingFolder,'\MIData.mat'),'MIData');
save(strcat(recordingFolder,'\trials2remove.mat'),'trials2remove');

end
