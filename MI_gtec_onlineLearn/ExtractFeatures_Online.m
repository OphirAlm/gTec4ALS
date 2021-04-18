function [MIFeatures] = ExtractFeatures_Online(MIData, Hz,bands, f, restingStateBands)
%% This function extracts features for the machine learning process.


% get number of channels from main data variable
numChans = size(MIData,1);

%% PLEASE ENTER RELEVENT FREAQUENCIES - NO NEED in the online proccess



% how many bands overall exist
bands_N = length(bands);

% init features+labels matrix
MIFeaturesLabel = NaN(numChans,bands_N);

%% Extract features
for channel = 1:numChans
    
    %Power and total power
    tot_power = bandpower(squeeze(MIData(channel,:)),Hz,[f(1), f(end)]);
    alpha_power = bandpower(squeeze(MIData(channel,:)),Hz,[8, 12]);
    beta_power = bandpower(squeeze(MIData(channel,:)),Hz,[12, 30]);
    theta_power = bandpower(squeeze(MIData(channel,:)),Hz,[4, 8]);
    mu_power = bandpower(squeeze(MIData(channel,:)),Hz,[9, 13]);
    
    n = 1;
    %Band power features
    for band_i = 1:bands_N
        % Extract bandpower
        MIFeaturesLabel(channel, n) = ...
            bandpower(squeeze(MIData(channel, :, :)),Hz,bands{band_i});
        % Extract relaitve band power to the resting state power.
        MIFeaturesLabel(channel, n + 1) = ...
            MIFeaturesLabel(channel, n) ./ restingStateBands(channel, band_i);
        % Extract relaitve band power (relative to total power and each
        % power band)
        MIFeaturesLabel(channel, n + 2) = ...
            MIFeaturesLabel(channel, n) ./ tot_power';
        MIFeaturesLabel(channel, n + 3) = ...
            MIFeaturesLabel(channel, n) ./ alpha_power';
        MIFeaturesLabel(channel, n + 4) = ...
            MIFeaturesLabel(channel, n) ./ beta_power';
        MIFeaturesLabel(channel, n + 5) = ...
            MIFeaturesLabel(channel, n) ./ theta_power';
        MIFeaturesLabel(channel, n + 6) = ...
            MIFeaturesLabel(channel, n) ./ mu_power';
        
        n = n + 7;
    end
    %sqrt total power feature
    MIFeaturesLabel(channel, n) = sqrt(tot_power);
    n = n + 1;
    
    % Power
    power = pwelch(squeeze(MIData(channel,:)), round(0.75 * Hz), round(0.7 * Hz) ,f ,Hz);
    
    %Probability function
    prob_f = Probably(power)';
    
    %Spectral moment feature
    MIFeaturesLabel(channel, n) = f * prob_f ;
    n = n + 1;
    
    %Spectral edge
    MIFeaturesLabel(channel, n) = precen(prob_f' , 0.9, f);
    n = n + 1;
    
    %Spectral entropy
    MIFeaturesLabel(channel, n) = -sum(prob_f .* log2(prob_f),1);
end

% Reshape into 2-D matrix
MIFeatures = reshape(MIFeaturesLabel,1 ,numChans * (bands_N * 7 + 4) );





