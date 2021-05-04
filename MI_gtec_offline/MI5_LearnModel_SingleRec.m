function [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]...
    = MI5_LearnModel_SingleRec(recordingFolder)


%% Read Features & Labels
load(strcat(recordingFolder, '\parameters.mat'));
load(strcat(recordingFolder, '\trials2remove.mat'));
TEMP = load(strcat(recordingFolder, '\MIFeatures.mat'));
MIFeatures = TEMP.MIFeatures;
TEMP = load(strcat(recordingFolder, '\trainingVec.mat'));
targetLabels = TEMP.trainingVec;
% k = 10; 
% % Test with LDA
% [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]= ...
%     myClassiff(k, MIFeatures, targetLabels, trials2remove);

% % Test with RF
% [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]= ...
%     randomForest(k, MIFeatures, targetLabels, trials2remove, recordingFolder);
% 
% 
%% Test data
% test prediction from linear classifier
%Printing the results
% disp(['Mean train accuracy - ' num2str(train_accuracy_m*100) '%'])
% disp(['Train accuracy standard deviation - ' num2str(train_accuracy_sd*100) '%'])
% disp(' ')
% disp(['Mean validation accuracy - ' num2str(val_accuracy_m*100) '%'])
% disp(['Validation accuracy standard deviation - ' num2str(val_accuracy_sd*100) '%'])




%% Read Features & Labels
trials2remove = logical(trials2remove);
k = 10;

%Removing bad trials
MIFeatures(trials2remove, :) = [];
targetLabels(trials2remove) = [];


% Test with boosting
datasetTable = [MIFeatures, targetLabels'];
[model, validationAccuracy] =...
    trainBaggingClassifier(datasetTable, k, 300);


%% Test data
% Printing the results
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

% Saving the model
save(strcat(recordingFolder,'\RF_model.mat'), 'model')

