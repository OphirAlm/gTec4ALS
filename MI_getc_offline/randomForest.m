function [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd] = ...
    randomForest(k , feature_mat , labels , trials2remove, recordingFolder)
%MATLAB R2019b
%
%Training and testing linear classifier from the feature matrix. giving
%back accuracy paramaters as output (validation and error mean & std, and a confusion matrix).
%
%samp_sz - Number of sampels per fold.
%k - Number of folds.
%feature_mat - The feature matrix.
%labels - Labels of the trials.
%Font - Structure of font size.
%
%[train_accuracy_m ,train_accuracy_sd] - mean and standard deviation of
%training sets accuracy.
%[val_accuracy_m ,val_accuracy_sd] - mean and standard deviation of
%validation sets accuracy.
%Confusion matrix - no need to pre-assign figure.
%
%--------------------------------------------------------------------------------


%Number of trees
nTrees = 500;
%Convert to logical

%Removing bad trials
feature_mat(trials2remove, :) = [];
labels(trials2remove) = [];

%Number of sampels.
sampels_N = size(feature_mat,1);
%Number of classes.
% classes = unique(labels);
% class_N = length(classes);

%Random order (for k-folds)
randOrder = randperm(sampels_N);
labels = labels(randOrder);
feature_mat = feature_mat(randOrder, :);

%Labels conversion
% idle_idx = (labels == 7);
% left_idx = (labels == 6);
% right_idx = (labels == 2);
% labels_cell = cell(size(labels));
% labels_cell(1, idle_idx) = {'Idle'};
% labels_cell(right_idx) = {'Right'};
% labels_cell(left_idx) = {'Left'};

%Figure size
% confus_fig_sz = [7.285,2.8575,19.685,13.0175];

%K-folds
samp_sz = round(sampels_N/k);


%Allocations
validation_accuracy = zeros(1 , k);
test_pred = zeros(samp_sz , k);
% train_pred = zeros(1 , k);
% con_mat = zeros(k,class_N,class_N);

% Training classifier
for i = 1:k
    test_idx = (1:samp_sz) + samp_sz*(i-1);
    if max(test_idx) > sampels_N
        %         test_idx = test_idx(1) : sampels_N;
        break
    end
    train_idx = setdiff(1:sampels_N, test_idx);
    B = TreeBagger(nTrees,feature_mat(train_idx , :),labels(train_idx),...
        'Method', 'classification', 'SplitCriterion', 'deviance',...
        'MinLeafSize',5);
    test_pred(:,i) = cellfun(@str2num, B.predict(feature_mat(test_idx , :)));
    train_pred(:,i) = cellfun(@str2num, B.predict(feature_mat(train_idx , :)));
    %     [predictions(:,i) , err(i)]  = ...
    %         classify(feature_mat(test_idx , :) , feature_mat(train_idx , :) ...
    %         , labels_cell(train_idx) , 'linear');
    %Getting accuracy per fold.
    validation_accuracy(i) = mean(test_pred(:,i) == labels(test_idx)');
    train_accuracy(i) = mean( train_pred(:,i) == labels(train_idx)');
    
    %Confusion matrix.
    %Labeling with binary [0,1] - left = 1 , right = 0.
%     idle_pred_idx = 7*strcmp(test_pred(:,i) ,'Idle');
%     left_pred_idx = 6*strcmp(test_pred(:,i) ,'Left');
%     right_pred_idx = 2*strcmp(test_pred(:,i) ,'Right');
%     
%     group_hat = idle_pred_idx + left_pred_idx + right_pred_idx;
%     group =labels(test_idx);
%     
    %     con_mat(i,:,:) = confusionmat(group,group_hat);
end

%Confusion matrix sum and plot
% figure('units' ,'centimeters','Position' ,confus_fig_sz); hold off
% con_mat = squeeze(sum(con_mat,1));
% cm = confusionchart(con_mat,classes ,'Title' , 'Confusion matrix');
% set(cm,'FontSize',Font.axesmall) %Axes font size.

%Validation accuracy
val_accuracy_m = mean(validation_accuracy);
val_accuracy_sd = std(validation_accuracy);

%Train accuracy
train_accuracy_m = mean(train_accuracy);
train_accuracy_sd = std(train_accuracy);

%Train model on entire data and save
model = TreeBagger(nTrees,feature_mat,labels,...
    'Method', 'classification');
save(strcat(recordingFolder,'\RF_model.mat'), 'model')
