function LearnModel_AllRec_FromScratch()
% Collect all the features from all the subfolders in the choosen
% directory, and trains a model with all the recordings that waasa found.
% The new model will be saved in a new subfolder in the choosen directory.

%% Read Features & Labels
recordingFolder = uigetdir('C:/Subjects/', ...
    'Choose Desired Directory');

%Initiallize
EEG = [];
MIFeatures = [];
targetLabels = [];
Hz = 512;


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
    TEMP_EEG = load(strcat(curFolder, '\EEG.mat'));
    TEMP_targetlabels = load(strcat(curFolder, '\trainingVec.mat'));
    %Stack files
    EEG = cat(3, EEG, TEMP_EEG.EEG);
    targetLabels = [targetLabels, TEMP_targetlabels.trainingVec];
    if dir_i == 1
        load(strcat(curFolder,'\FeatureParam.mat'));
        load(strcat(curFolder, '\RestingSignal.mat'));
    end
        
end

rmv = targetLabels(targetLabels == 1);
% EEG(:, :, rmv) = [];
targetLabels(rmv) = 2;
%% Run pre-processing pipeline on recorded data
[MIData, trials2remove] = Proccessing.Preprocess(EEG);

%% Extract features
[MIFeatures, f] = Proccessing.ExtractFeatures(MIData, Hz, bands, RestingSignal);
%% Read Features & Labels
trials2remove = logical(trials2remove);


k = 5;
trees_N = 500;

%Removing bad trials
MIFeatures(trials2remove, :) = [];
targetLabels(trials2remove) = [];


% Test with bagging
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    ModelFun.trainBaggingClassifier(datasetTable, k, trees_N);

%% Test data
%Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

%Saving the model
mkdir(strcat([recordingFolder,'\All_Recs- ' num2str(100 * validationAccuracy) '%']))
save(strcat([recordingFolder,'\All_Recs- ' num2str(100 * validationAccuracy) '%\RF_model.mat']), 'model')
