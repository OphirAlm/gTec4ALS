%% Convolotion network for spectrgorams draft
clear; close all; clc;
%% Load EEG and labels
MIdata = load('C:\Users\ophir\Downloads\Aviya_results\sub_1\sub_1\EEG_mission3_N1.mat');
MIdata = MIdata.variable2Save1;
restingData = load('C:\Users\ophir\Downloads\Aviya_results\sub_1\sub_1\EoEEG.mat');
restingData = restingData.EEG.data;
trainingVec = ones(1,size(MIdata, 3));

% load('C:\Users\ophir\Downloads\Sub777\Sub777\online -61.5385% Accuracy\EEG.mat')
% load('C:\Users\ophir\Downloads\Sub777\Sub777\online -61.5385% Accuracy\FeatureParam.mat')
% load('C:\Users\ophir\Downloads\Sub777\Sub777\online -61.5385% Accuracy\RestingSignal.mat')

%% Paramas
Fs = 300;
f = 10 : 0.1 : 35;
window_sz = round(Fs * 0.25);
overlap_sz = floor(Fs * .2);

%% Split data
idle = trainingVec == 1;
right = trainingVec == 2;
left = trainingVec == 3;


% Helper directory
dir = 'C:\Subjects\temp';

% Delete helper dir if exists
% flag = rmdir(dir, 's');

% Create helper dir
mkdir C:\Subjects\temp\1
mkdir C:\Subjects\temp\2
mkdir C:\Subjects\temp\3

% MIdata = Proccessing.Preprocess(EEG);
% restingData = Proccessing.Preprocess(RestingSignal);

%% Compute Mean And STD For Resting State
for elec_i = 1 : size(restingData, 1)
    restingSpectro = SpecPower(spectrogram(restingData(elec_i, :),...
        window_sz , overlap_sz ,f , Fs ,'yaxis'));
    restingMean(:, elec_i) = mean(restingSpectro, 2);
    restingSTD(:, elec_i) = std(restingSpectro, [], 2);    
end
%% Make spectrogram per electrode
for trial_i = 1 : size(MIdata, 3)
    tempAll = [];
    for elec_i = 1 : size(MIdata, 1)
        tempSpecto = SpecPower(spectrogram(MIdata(elec_i, :, trial_i),...
            window_sz , overlap_sz ,f , Fs ,'yaxis'));
        % Normalize (Z-score) with respect to resting state
        tempSpecto = (tempSpecto - restingMean(:, elec_i)) ./ restingSTD(:, elec_i);
        % Stack spectrograms
        tempAll = [tempAll; tempSpecto];
    end
    imwrite(mat2gray(tempAll),...
        [dir '\' num2str(trainingVec(trial_i)) '\mission3_trial' num2str(trial_i) '.png'])
end


%% Create net
% inputSz = size(tempAll);
% class_N = length(unique(trainingVec));
% net = transferLearning(inputSz, class_N);
% 
% net = transferTrain(net, inputSz, dir);


