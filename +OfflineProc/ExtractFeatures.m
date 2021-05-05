function ExtractFeatures(recordingFolder)
%% This function extracts features for the machine learning process.

%% Load previous variables:
load(strcat(recordingFolder,'FeatureParam'),'bands');
load(strcat(recordingFolder,'parameters.mat'));
load(strcat(recordingFolder,'EEG_chans.mat'));                   % load the openBCI channel location
load(strcat(recordingFolder,'MIData.mat'));                      % load the EEG data
load(strcat(recordingFolder,'restingSignal.mat'));                      % load the EEG data
% targetLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\trainingVec'))));


%% set varibles
% get number of trials from main data variable
trials = size(MIData, 3);                                            
% get number of channels from main data variable
numChans = size(MIData, 1);                   
% Choose frequencies range
f = 4 : 0.1 :40;
% how many bands overall exist
numFeatures = length(bands);       
% init features+labels matrix
MIFeaturesLabel = NaN(trials,numChans,numFeatures);                      

%% Extract Resting State Power Bands
restingStateBands = EEGFun.restingState(RestingSignal, bands, Hz);
%% Extract features (powerbands in alpha, beta, delta, theta, gamma bands)
for channel = 1:numChans
    n = 1;
    %Power and total power
    tot_power = bandpower(squeeze(MIData(channel,:,:)),Hz,[f(1), f(end)]);
    alpha_power = bandpower(squeeze(MIData(channel,:,:)),Hz,[8, 12]);
    beta_power = bandpower(squeeze(MIData(channel,:,:)),Hz,[12, 30]);
    theta_power = bandpower(squeeze(MIData(channel,:,:)),Hz,[4, 8]);
    mu_power = bandpower(squeeze(MIData(channel,:,:)),Hz,[9, 13]);
    gamma_power = bandpower(squeeze(MIData(channel,:,:)),Hz,[30, 40]);
    
    %Band power features  
    for feature = 1:numFeatures
        % Extract bandpower
        MIFeaturesLabel(:, channel, n) = ...
            bandpower(squeeze(MIData(channel, :, :)),Hz,bands{feature});
        % Extract relaitve band power to the resting state power.
        MIFeaturesLabel(:, channel, n + 1) = ...
            MIFeaturesLabel(:, channel, n) ./ restingStateBands(channel, feature);
        % Extract relaitve band power
        MIFeaturesLabel(:, channel, n + 2) = ...
            MIFeaturesLabel(:, channel, n) ./ tot_power';
        MIFeaturesLabel(:, channel, n + 3) = ...
            MIFeaturesLabel(:, channel, n) ./ alpha_power';
        MIFeaturesLabel(:, channel, n + 4) = ...
            MIFeaturesLabel(:, channel, n) ./ beta_power';
        MIFeaturesLabel(:, channel, n + 5) = ...
            MIFeaturesLabel(:, channel, n) ./ theta_power';
        MIFeaturesLabel(:, channel, n + 6) = ...
            MIFeaturesLabel(:, channel, n) ./ mu_power';
        MIFeaturesLabel(:, channel, n + 6) = ...
            MIFeaturesLabel(:, channel, n) ./ gamma_power';
        
        n = n + 8;
    end
    
    %sqrt total power feature
    MIFeaturesLabel(:, channel, n) = sqrt(tot_power);
    n = n + 1;
    
    % Power
    power = pwelch(squeeze(MIData(channel,:,:)), round(0.75 * Hz), round(0.7 * Hz) ,f ,Hz);
    
    %Probability function
    prob_f = EEGFun.Probably(power);
    
    %Spectral moment feature
    MIFeaturesLabel(:, channel, n) = f * prob_f ;
    n = n + 1;
    
    %Spectral edge
    MIFeaturesLabel(:, channel, n) = EEGFun.precen(prob_f' , 0.9, f);
    n = n + 1;
    
    %Spectral entropy
    MIFeaturesLabel(:, channel, n) = -sum(prob_f .* log2(prob_f),1);
end

% MIFeaturesLabel = zscore(MIFeaturesLabel);

% Reshape into 2-D matrix
MIFeatures = reshape(MIFeaturesLabel,trials,[]);

%% PCA (Not improving at the moment)
% [coeff, ~, ~, ~, explained, ~] = pca(MIFeatures);
% dim2take = find(cumsum(explained) >99.999, 1);
% pcaMat = coeff(:, 1 : dim2take);
% MIFeatures = MIFeatures * pcaMat;


%% saving
save(strcat(recordingFolder,'\MIFeatures.mat'),'MIFeatures');
save(strcat(recordingFolder,'\FeatureParam.mat'),'bands', 'f');


