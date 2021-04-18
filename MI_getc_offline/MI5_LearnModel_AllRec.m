function [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]...
    = MI5_LearnModel_AllRec(recordingFolder)

%DEBUG
Font = struct('axesmall', 13,...
    'axebig', 16,...
    'label', 14,...
    'title', 18); %Axes font size
load(strcat(recordingFolder, '\parameters.mat'));


%% Read Features & Labels
%Initiallize
trials2remove =[];
MIFeatures =[];
targetLabels =[];

%Subject's main folder
folders = dir([recordingFolder, '\', '..']);
pathSplit = regexp(recordingFolder,filesep,'split');
mainPath = fullfile(pathSplit(1), pathSplit(2), pathSplit(3));
mainPath = mainPath{1};

%Remove . & ..
folders([1, 2], :) = [];

N_folders = size(folders, 1);

for dir_i = 1 : N_folders
    %Enter specifics folder
    curFolder = [mainPath, '\', folders(dir_i).name];
    %Load files
    TEMP_trials2remove = load(strcat(curFolder, '\trials2remove.mat'));
    TEMP_MIFeatures = load(strcat(curFolder, '\MIFeatures.mat'));
    TEMP_targetlabels = load(strcat(curFolder, '\trainingVec.mat'));
    %Stack files
    trials2remove = [trials2remove, TEMP_trials2remove.trials2remove];
    MIFeatures = [MIFeatures; TEMP_MIFeatures.MIFeatures];
    targetLabels = [targetLabels, TEMP_targetlabels.trainingVec];
end
trials2remove = logical(trials2remove);
k = 10;
% Test with LDA
[train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]= ...
    myClassiff(k, MIFeatures, targetLabels, trials2remove, Font);

% Test with RF
% [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]= ...
%     randomForest(k, MIFeatures, targetLabels, trials2remove, Font);


%% Test data
% test prediction from linear classifier
%Printing the results
disp(['Mean train accuracy - ' num2str(train_accuracy_m*100) '%'])
disp(['Train accuracy standard deviation - ' num2str(train_accuracy_sd*100) '%'])
disp(' ')
disp(['Mean validation accuracy - ' num2str(val_accuracy_m*100) '%'])
disp(['Validation accuracy standard deviation - ' num2str(val_accuracy_sd*100) '%'])






