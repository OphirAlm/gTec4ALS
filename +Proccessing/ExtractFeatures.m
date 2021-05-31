function [MIFeatures, f] = ExtractFeatures(MIData, Hz, bands, restingStateBands)
% Extract feauters from the segmented EEG data.
%
% MIFeatures - Matrix of the features per trial (trials in rows features in
% columns)
%
% MIData - Segmented EEG signal (trials in rows, sampels in columns)
% Hz - Signal sampling rate
% bands - The power bands to extract features from.
% restingStateBands - Resting state power recorded per band
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Total frequency range
f = 4 : 0.1 : 40;

% get number of channels from main data variable
numChans = size(MIData,1);

% how many bands overall exist
bands_N = length(bands);

% Get number of trials
trials_N = size(MIData, 3);

% init features+labels matrix
MIFeaturesLabel = NaN(numChans, bands_N, trials_N);

%% Extract features
for channel = 1:numChans
    
    % Bands power and total power
    tot_power = bandpower(squeeze(MIData(channel, :, :)),Hz,[f(1), f(end)]);
    alpha_power = bandpower(squeeze(MIData(channel, :, :)),Hz,[8, 12]);
    beta_power = bandpower(squeeze(MIData(channel, :, :)),Hz,[12, 30]);
    theta_power = bandpower(squeeze(MIData(channel, :, :)),Hz,[4, 8]);
    mu_power = bandpower(squeeze(MIData(channel, :, :)),Hz,[9, 13]);
    gamma_power = bandpower(squeeze(MIData(channel, :, :)),Hz,[30, 40]);
    
    n = 1;
    % Band power features
    for band_i = 1:bands_N
        % Extract bandpower
        MIFeaturesLabel(channel, n, :) = ...
            bandpower(squeeze(MIData(channel, :, :)),Hz,bands{band_i});
        % Extract relaitve band power to the resting state power.
        MIFeaturesLabel(channel, n + 1, :) = ...
            MIFeaturesLabel(channel, n, :) ./ restingStateBands(channel, band_i);
        % Extract relaitve band power (relative to total power and each
        % power band)
        MIFeaturesLabel(channel, n + 2, :) = ...
            squeeze(MIFeaturesLabel(channel, n, :)) ./ tot_power';
        MIFeaturesLabel(channel, n + 3, :) = ...
            squeeze(MIFeaturesLabel(channel, n, :)) ./ alpha_power';
        MIFeaturesLabel(channel, n + 4, :) = ...
            squeeze(MIFeaturesLabel(channel, n, :)) ./ beta_power';
        MIFeaturesLabel(channel, n + 5, :) = ...
            squeeze(MIFeaturesLabel(channel, n, :)) ./ theta_power';
        MIFeaturesLabel(channel, n + 6, :) = ...
            squeeze(MIFeaturesLabel(channel, n, :)) ./ mu_power';
        MIFeaturesLabel(channel, n + 7, :) = ...
            squeeze(MIFeaturesLabel(channel, n, :)) ./ gamma_power';
        n = n + 8;
    end
    %sqrt total power feature
    MIFeaturesLabel(channel, n, :) = sqrt(tot_power);
    n = n + 1;
    
    % Power
    power = pwelch(squeeze(MIData(channel,:, :)), round(0.75 * Hz), round(0.7 * Hz) ,f ,Hz);
    
    %Probability function
    prob_f = EEGFun.Probably(power);
    
    if trials_N ~= 1
        prob_f = prob_f';
    end
    
    %Spectral moment feature
    MIFeaturesLabel(channel, n, :) = f * prob_f' ;
    n = n + 1;
    
    %Spectral edge
    MIFeaturesLabel(channel, n, :) = EEGFun.precen(prob_f , 0.9, f);
    n = n + 1;
    
    %Spectral entropy
    MIFeaturesLabel(channel, n, :) = -sum(prob_f .* log2(prob_f),2);
end

% Reshape into 2-D matrix
% MIFeatures2 = reshape(MIFeaturesLabel,trials_N ,numChans * (bands_N * 8 + 4));

MIFeatures = [];
for elec_i = 1 : numChans
    if trials_N == 1
        MIFeatures = [MIFeatures, squeeze(MIFeaturesLabel(elec_i, :, :))];
    else
        MIFeatures = [MIFeatures; squeeze(MIFeaturesLabel(elec_i, :, :))];
    end
end
MIFeatures = MIFeatures';



