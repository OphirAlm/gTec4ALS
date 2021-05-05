function [train_accuracy_m , train_accuracy_sd , val_accuracy_m ,val_accuracy_sd] = ...
    LDA_classify(k , feature_mat , labels , trials2remove)
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



%Removing bad trials
feature_mat(trials2remove, :) = [];
labels(trials2remove) = [];

%Number of sampels.
sampels_N = size(feature_mat,1);
%Number of classes.
classes = unique(labels);
class_N = length(classes);

%Random order (for k-folds)
randOrder = randperm(sampels_N);
labels = labels(randOrder);
feature_mat = feature_mat(randOrder, :);

%Labels conversion
idle_idx = (labels == 4);
left_idx = (labels == 2);
right_idx = (labels == 1);
down_idx = (labels == 3);
labels_cell = cell(size(labels));
labels_cell(1, idle_idx) = {'Idle'};
labels_cell(right_idx) = {'Right'};
labels_cell(left_idx) = {'Left'};
labels_cell(down_idx) = {'Down'};


%Figure size
confus_fig_sz = [7.285,2.8575,19.685,13.0175];

%K-folds
samp_sz = round(sampels_N/k);


%Allocations
validation_accuracy = zeros(1 , k);
predictions = cell(samp_sz , k);
err = zeros(1 , k);
con_mat = zeros(k,class_N,class_N);

% Training classifier
for i = 1:k
    test_idx = (1:samp_sz) + samp_sz*(i-1);
    if max(test_idx) > sampels_N
%         test_idx = test_idx(1) : sampels_N;
        break
    end
    train_idx = setdiff(1:sampels_N, test_idx);
    [predictions(:,i) , err(i)]  = ...
        classify(feature_mat(test_idx , :) , feature_mat(train_idx , :) ...
        , labels_cell(train_idx) , 'linear');
    %Getting accuracy per fold.
    validation_accuracy(i) = mean(arrayfun(@strcmp , predictions(:,i) ...
        , labels_cell(test_idx)'));
    
    %Confusion matrix.
    %Labeling with binary [0,1] - left = 1 , right = 0.
    idle_pred_idx = 7*strcmp(predictions(:,i) ,'Idle');
    left_pred_idx = 6*strcmp(predictions(:,i) ,'Left');
    right_pred_idx = 2*strcmp(predictions(:,i) ,'Right');
    
    group_hat = idle_pred_idx + left_pred_idx + right_pred_idx;
    group =labels(test_idx);
    
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
train_accuracy = 1 - err;
train_accuracy_m = mean(train_accuracy);
train_accuracy_sd = std(train_accuracy);
