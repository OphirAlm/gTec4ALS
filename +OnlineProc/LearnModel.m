function [model, validationAccuracy]...
    = LearnModel(MIFeatures, targetLabels, trials2remove, recordingFolder)


%% Read Features & Labels
trials2remove = logical(trials2remove);
k = 10;
trees_N = 300;

%Removing bad trials
feature_mat(trials2remove, :) = [];
labels(trials2remove) = [];


% Test with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    ModelFun.trainBaggingClassifier(datasetTable, k, trees_N);


%% Test data
%Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

%Saving the model
save(strcat(recordingFolder,'\RF_model.mat'), 'model')






