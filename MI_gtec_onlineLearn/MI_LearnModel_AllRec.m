function MI_LearnModel_AllRec(recordingFolder)


%% Read Features & Labels
%Initiallize
trials2remove = [];
MIFeatures = [];
targetLabels = [];
correctLabeled = [];

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
    TEMP_correctLabeled = load(strcat(curFolder, '\correctLabeled.mat'));
    TEMP_MIFeatures = load(strcat(curFolder, '\MIFeatures.mat'));
    TEMP_targetlabels = load(strcat(curFolder, '\trainingVec.mat'));
    %Stack files
    trials2remove = [trials2remove, TEMP_trials2remove.trials2remove];
    correctLabeled = [correctLabeled, TEMP_correctLabeled.correctLabeled];
    MIFeatures = [MIFeatures; TEMP_MIFeatures.MIFeatures];
    targetLabels = [targetLabels, TEMP_targetlabels.trainingVec];
end

%% Read Features & Labels
trials2remove = logical(trials2remove);
% correctLabeled = logical(abs(correctLabeled - 1));
% trials2remove = trials2remove & correctLabeled;
k = 5;

%Removing bad trials
MIFeatures(trials2remove, :) = [];
targetLabels(trials2remove) = [];


% Test with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    trainBoostClassifier(datasetTable, k, 300);

%% Test data
%Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

%Saving the model
mkdir(strcat([recordingFolder,'\All_Recs- ' num2str(100 * validationAccuracy) '%']))
save(strcat([recordingFolder,'\All_Recs- ' num2str(100 * validationAccuracy) '%\RF_model.mat']), 'model')
