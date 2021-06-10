function [model, validationAccuracy]...
    = LearnModel(MIFeatures, targetLabels, trials2remove, recordingFolder)
% LEARNMODEL Trains ML Model according to the extracted features.
%
% INPUT:
%     - MIFeatures - Matrix of the features per trial (trials in rows 
%                    features in columns)
%     - targetLabels - Vector of labels per trial.
%     - trials2remove - Vector of trials to remove (Noise\ Artifacts).
%     - recordingFolder - Folder to save in the new model.
%
% OUTPUT:
%     - model - ML Object.
%     - validationAccuracy - Cross validation mean accuracy of the model.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read Features & Labels
trials2remove = logical(trials2remove);
k = 10;
trees_N = 300;

% Removing bad trials
MIFeatures(trials2remove, :) = [];
targetLabels(trials2remove) = [];

% Train with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    ModelFun.trainBaggingClassifier(datasetTable, k, trees_N);


%% Test data
%Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

%Saving the model
save(strcat(recordingFolder,'\RF_model.mat'), 'model')






