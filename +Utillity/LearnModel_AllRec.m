function LearnModel_AllRec()
% Collect all the features from all the subfolders in the choosen
% directory, and trains a model with all the recordings that waasa found.
% The new model will be saved in a new subfolder in the choosen directory.

%% Read Features & Labels
recordingFolder = uigetdir('C:/Subjects/', ...
    'Choose Desired Directory');

%Initiallize
trials2remove = [];
MIFeatures = [];
targetLabels = [];

%Subject's main folder
folders = dir([recordingFolder]);
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

%% Read Features & Labels
trials2remove = logical(trials2remove);


k = 5;
trees_N = 500;

%Removing bad trials
MIFeatures(trials2remove, :) = [];
targetLabels(trials2remove) = [];


% Test with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    ModelFun.trainBaggingClassifier(datasetTable, k, trees_N);

%% Test data
%Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

%Saving the model
mkdir(strcat([recordingFolder,'\All_Recs- ' num2str(100 * validationAccuracy) '%']))
save(strcat([recordingFolder,'\All_Recs- ' num2str(100 * validationAccuracy) '%\RF_model.mat']), 'model')
