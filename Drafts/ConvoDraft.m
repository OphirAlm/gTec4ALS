%% Convolotion network for spectrgorams draft
clear; close all; clc;
%% Load EEG and labels
load('C:\Subjects\Sub3\online -83.5294% Accuracy\trainingVec.mat')
load('C:\Subjects\Sub3\online -83.5294% Accuracy\trials2remove.mat')
load('C:\Subjects\Sub3\online -83.5294% Accuracy\EEG.mat')
load('C:\Subjects\Sub3\online -83.5294% Accuracy\FeatureParam.mat')

%% Paramas
Fs = 512;
f = 4 : 0.1 : 40;
window_sz = round(Fs * 0.15);
overlap_sz = floor(Fs * .145);

%% Make spectrogram per electrode
for trial_i = 1 : size(EEG, 3)
    for elec_i = 1 : size(EEG, 1)
        specto(:, :, elec_i, trial_i) = SpecPower(spectrogram(EEG(elec_i, :, trial_i),...
            window_sz , overlap_sz ,f , Fs ,'yaxis'));
    end
end



