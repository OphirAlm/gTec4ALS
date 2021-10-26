function [net, traininfo] = transferTrain(lgraph, inputSz, dataDirectory)

% Initial conditions
trainingSetup = load("C:\Users\ophir\Desktop\gTec4ALS\Drafts\trainingSetup_2021_08_08__12_41_17.mat");

% Load data
imdsTrain = imageDatastore(dataDirectory ,"IncludeSubfolders",true,"LabelSource","foldernames");
[imdsTrain, imdsValidation] = splitEachLabel(imdsTrain,0.8);

% Resize the images to match the network input layer.
augimdsTrain = augmentedImageDatastore([inputSz, 1],imdsTrain);
augimdsValidation = augmentedImageDatastore([inputSz, 1],imdsValidation);

% Training Parameters
opts = trainingOptions("sgdm",...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",0.00001,...
    "MaxEpochs",10,...
    "MiniBatchSize",1,...
    "Shuffle","every-epoch",...
    "Plots","training-progress",...
    "ValidationData",augimdsValidation);

[net, traininfo] = trainNetwork(augimdsTrain,lgraph,opts);


