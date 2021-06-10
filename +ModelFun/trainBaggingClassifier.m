function [trainedClassifier, validationAccuracy] =...
    trainBaggingClassifier(datasetTable, k, Ntrees)
%TRAINBAGGINGCLASSIFIER Trains a ML ensemble classifier using bagging tree method.
%
% INPUT:
%     - datasetTable - 
%     - k - Scalar for K-fold validation
%     - Ntrees - Scalar for number trees desired
%
% OUTPUT:
%     - trainedClassifier - The ensemble classifier
%     - validationAccuracy - The mean accuracy of K-fold validation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Input size
N = size(datasetTable, 2);

%Create predictors names
predictorNames = {};
for i = 1 : N
    predictorNames{i} = ['column_' num2str(i)];
end

% Convert input to table
datasetTable = table(datasetTable);
datasetTable.Properties.VariableNames = {'column'};

% Split matrices in the input table into vectors
for i = 1 : N
    datasetTable.(predictorNames{i}) = datasetTable.column(:,i);
end
%Remove this column
datasetTable.column = [];

%Split predictors and responses
response = datasetTable.(predictorNames{end});
responseName = predictorNames{end};
predictorNames = predictorNames(1 : N - 1);
predictors = datasetTable(:,predictorNames);
predictors = table2array(varfun(@double, predictors));
%Class names
classNames = unique(response)';

% Train a classifier
trainedClassifier = fitensemble(predictors, response, 'Bag', Ntrees, 'Tree', 'Type', 'Classification', 'PredictorNames', predictorNames, 'ResponseName', responseName, 'ClassNames', classNames);

% Perform cross-validation
partitionedModel = crossval(trainedClassifier, 'KFold', k);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

%% Uncomment this section to compute validation predictions and scores:
% % Compute validation predictions and scores
% [validationPredictions, validationScores] = kfoldPredict(partitionedModel);