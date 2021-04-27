
clc; clear; close all;
% subID = 2;
% recordingFolder = ['C:/Subjects/Sub' n um2str(subID) '/'];
% recordingFolder = ['C:\Subjects\Sub999\18-Mar-2021 15-28\'];

%% Band 

% frequency bands features
bands{1} = [9, 13];
bands{2} = [8, 10];
bands{3} = [10,12];
bands{4} = [12,15];
bands{5} = [15,18];
bands{6} = [18,25];
bands{7} = [25,30];


%% Run stimulation and record EEG data
[recordingFolder,subID] = MI_Training_4Class(bands);
disp('Finished stimulation and EEG recording. Stop the LabRecorder and press any key to continue...');

%% Run pre-processing pipeline on recorded data
MI2_Preprocess_Scaffolding(recordingFolder);
disp('Finished pre-processing pipeline.');


%% Extract features and labels
MI4_ExtractFeatures_Scaffolding(recordingFolder);
disp('Finished extracting features and labels.');

%% Train a model using single recording
MI5_LearnModel_SingleRec(recordingFolder);

%% Train a model using all subject's recording
% MI_LearnModel_AllRec(recordingFolder);
