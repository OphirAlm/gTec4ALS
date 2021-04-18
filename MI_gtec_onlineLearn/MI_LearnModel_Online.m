function [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]...
    = MI_LearnModel_Online(MIFeatures, targetLabels, trials2remove, recordingFolder)


%% Read Features & Labels
trials2remove = logical(trials2remove);
k = 10;
% Test with LDA
% [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]= ...
%     myClassiff(k, MIFeatures, targetLabels, trials2remove);

% Test with RF
[train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd]= ...
    randomForest(k, MIFeatures, targetLabels, trials2remove, recordingFolder);



%% Test data
% test prediction from classifier
%Printing the results
disp(['Mean train accuracy - ' num2str(train_accuracy_m*100) '%'])
disp(['Train accuracy standard deviation - ' num2str(train_accuracy_sd*100) '%'])
disp(' ')
disp(['Mean validation accuracy - ' num2str(val_accuracy_m*100) '%'])
disp(['Validation accuracy standard deviation - ' num2str(val_accuracy_sd*100) '%'])






