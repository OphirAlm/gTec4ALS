function [firstDay,mode] = MI4_ExtractFeatures_Scaffolding(recordingFolder)
%% This function extracts features for the machine learning process.

%% Load previous variables:
load(strcat(recordingFolder,'FeatureParam'),'bands');
load(strcat(recordingFolder,'parameters.mat'));
load(strcat(recordingFolder,'MIData.mat'));                      % load the EEG data
load(strcat(recordingFolder,'trainingVec.mat'));                      % load the EEG data

%% set varibles
[chan_N, ~, trials] = size(MIData);                                            % get number of trials from main data variable
class_N = 4;
%% CSP Function
m = 2;
CSP_Struct = CSPextract(MIData, trials, trainingVec, bands, m, Hz);


%% Compute CSP Features
for i = 1 : length(CSP_Struct)
    for trial_i = 1 : trials
        for chan_i = 1 : chan_N
        MIDataFilt(chan_i, :, trial_i) = ...
            bpfilt(squeeze(MIData(chan_i,:,trial_i))',bands{i}(1), bands{i}(2), Hz)';
        end
    MIFeatures(trial_i, 1 + (i - 1) * m * 2 *class_N  : m * 2 *class_N + (i - 1) * m * 2 * class_N) = ...
        log(diag(CSP_Struct{i} * MIDataFilt(:, :, trial_i) * MIDataFilt(:, :, trial_i)' * CSP_Struct{i}')) ./ ...
        trace(CSP_Struct{i} * MIDataFilt(:, :, trial_i) * MIDataFilt(:, :, trial_i)' * CSP_Struct{i}');
    end
end

%% PCA (Not improving at the moment)
% [coeff, ~, ~, ~, explained, ~] = pca(MIFeatures);
% dim2take = find(cumsum(explained) >99.999, 1);
% pcaMat = coeff(:, 1 : dim2take);
% MIFeatures = MIFeatures * pcaMat;


%% saving
save(strcat(recordingFolder,'\MIFeatures.mat'),'MIFeatures');
save(strcat(recordingFolder,'\FeatureParam.mat'),'bands');
save(strcat(recordingFolder,'\CSP_Struct.mat'),'CSP_Struct');


