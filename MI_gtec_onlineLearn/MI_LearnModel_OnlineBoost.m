function [model, validationAccuracy]...
    = MI_LearnModel_OnlineBoost(MIFeatures, targetLabels, trials2remove, recordingFolder)


%% Read Features & Labels
trials2remove = logical(trials2remove);
k = 10;

%Removing bad trials
feature_mat(trials2remove, :) = [];
labels(trials2remove) = [];


% Test with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    trainBoostClassifier(datasetTable, 10, 300);



%% Test data
%Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

%Saving the model
save(strcat(recordingFolder,'\RF_model.mat'), 'model')






