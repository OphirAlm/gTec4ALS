function LearnModel(recordingFolder)


%% Read Features & Labels
load(strcat(recordingFolder, '\parameters.mat'));
load(strcat(recordingFolder, '\trials2remove.mat'));
TEMP = load(strcat(recordingFolder, '\MIFeatures.mat'));
MIFeatures = TEMP.MIFeatures;
TEMP = load(strcat(recordingFolder, '\trainingVec.mat'));
targetLabels = TEMP.trainingVec;

%% Read Features & Labels
trials2remove = logical(trials2remove);
k = 10;
trees_N = 500;

%Removing bad trials
MIFeatures(trials2remove, :) = [];
targetLabels(trials2remove) = [];


% Test with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    ModelFun.trainBaggingClassifier(datasetTable, k, trees_N);


%% Test data
% Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

% Saving the model
save(strcat(recordingFolder,'\RF_model.mat'), 'model')

