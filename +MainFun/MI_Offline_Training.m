%% Offline Training Model Main Script

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
[recordingFolder,subID, EEG, trainingVec, RestingSignal, Hz, trialLength] = ...
    Proccessing.OfflineTraining;

% End of Phase message
disp('Finished Training.');

%% Run pre-processing pipeline on recorded data
[MIData, trials2remove] = Proccessing.Preprocess(EEG);

% Save the files
save(strcat(recordingFolder,'\','MIData.mat'),'MIData');

% End of Phase message
disp('Finished pre-processing the data.');

%% Extract features
[MIFeatures, f] = Proccessing.ExtractFeatures(MIData, Hz, bands, RestingSignal);

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
