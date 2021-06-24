%% Offline Training Model Main Script
function MI_Offline_Training()
% MI_OFFLINE_TRAINING performs a simulation and data recording. Cleans the data,
% preprocesses it. Feature extracted, including attached parameters. A model is being
% trained over extracted features, and mean validation accuracy is printed.
%
% All data is being saved along the script in designated folder created by
% the script. Folder's final name consists of date (including hours and
% minutes), and mean validation accuracy.
%
%% Band

% frequency bands features
bands{1} = [9, 13];
bands{2} = [8, 10];
bands{3} = [10,12];
bands{4} = [12,15];
bands{5} = [15,18];
bands{6} = [18,25];
bands{7} = [25,30];
bands{8} = [30, 33];
bands{9} = [32, 36];
bands{10} = [35, 40];

%% Run stimulation and record EEG data
[recordingFolder, ~, EEG, trainingVec, restingStateBands, Hz, ~] = ...
    Proccessing.OfflineTraining(bands);

% End of Phase message
disp('Finished Training.');

%% Run pre-processing pipeline on recorded data
[MIData, trials2remove] = Proccessing.Preprocess(EEG);

% Save the files
save(strcat(recordingFolder,'\','MIData.mat'),'MIData');

% End of Phase message
disp('Finished pre-processing the data.');

%% Extract features
[MIFeatures, f] = Proccessing.ExtractFeatures(MIData, Hz, bands, restingStateBands);

% Save the files
save(strcat(recordingFolder,'\MIFeatures.mat'),'MIFeatures');
save(strcat(recordingFolder,'\FeatureParam.mat'),'bands', 'f');

% End of Phase message
disp('Finished extracting features.');

%% Train a model
[model, validationAccuracy]...
    = Proccessing.LearnModel(MIFeatures, trainingVec, trials2remove, recordingFolder);


% Printing the model accuracy
disp(['Mean validation accuracy - ' num2str(validationAccuracy * 100) '%'])

% Saving the model
save(strcat(recordingFolder,'\RF_model.mat'), 'model')

% End of Phase message
disp('Finished training the model.');
end