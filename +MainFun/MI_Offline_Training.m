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
bands{8} = [30, 40];


%% Run stimulation and record EEG data
[recordingFolder,subID] = OfflineProc.Training(bands);
disp('Finished Training.');

%% Run pre-processing pipeline on recorded data
OfflineProc.Preprocess(recordingFolder);
disp('Finished pre-processing the data.');


%% Extract features
OfflineProc.ExtractFeatures(recordingFolder);
disp('Finished extracting features.');

%% Train a model 
OfflineProc.LearnModel(recordingFolder);
disp('Finished training the model.');
