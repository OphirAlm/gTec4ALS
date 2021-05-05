function boostclass(k , feature_mat , labels , trials2remove)
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

t = templateTree('MaxNumSplits',5);
Mdl = fitcensemble(feature_mat,labels,'Method','AdaBoostM1','Learners',t,'CrossVal','on');

kflc = kfoldLoss(Mdl,'Mode','cumulative');
figure;
plot(kflc);
ylabel('10-fold Misclassification rate');
xlabel('Learning cycle');

%Validation accuracy
% val_accuracy_m = mean(validation_accuracy);
% val_accuracy_sd = std(validation_accuracy);
% 
% %Train accuracy
% train_accuracy = 1 - err;
% train_accuracy_m = mean(train_accuracy);
% train_accuracy_sd = std(train_accuracy);
