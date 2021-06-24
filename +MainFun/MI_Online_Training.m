%% Online Training Function
function MI_Online_Training()
% MI_ONLINE_TRAINING Uses previous ML classification model and runs a
% simulation which includes a feedback for the user. At the end of the
% simulation, the function creates a new model consisting of only the new
% data or the combined new and old data, to the user's choice.
%
%% Set params and setup psychtoolbox & Simulink

% Define objects' strings for Simulink objects
USBobj          = 'USBamp_online';
AMPobj          = [USBobj '/g.USBamp UB-2016.03.01'];
IMPobj          = [USBobj '/Impedance Check'];
RestDelayobj    = [USBobj '/Resting Delay'];
ChunkDelayobj   = [USBobj '/Chunk Delay'];
scopeObj        = [USBobj '/g.SCOPE'];

% Open Simulink
open_system(['Utillity/' USBobj])
set_param(USBobj,'BlockReduction', 'off')

% Activate parameter gui
[Hz, trialLength, nClass, subID, numTrials, restingTime, accumulationFlag] ...
    = Utillity.parameter_gui(ChunkDelayobj, AMPobj, IMPobj, RestDelayobj, 'Online');

% Start simulation
Utillity.startSimulation(inf, USBobj);
open_system(scopeObj);

% Get the running time object (Delay line)
restingStateDelay  = get_param(RestDelayobj,'RuntimeObject');
rto                = get_param(ChunkDelayobj,'RuntimeObject');

% Get Desired model to use (Choose folder by date)
fullPath = uigetdir(['C:/Subjects/Sub' num2str(subID) '/'], ...
    'Choose Desired Directory');

%% Display Setup
% Checking monitor position and number of monitors
monitorPos = get(0,'MonitorPositions');
monitorN = size(monitorPos, 1);
% Which monitor to use TODO: make a parameter
choosenMonitor = 2;
% If no 2nd monitor found, use the main monitor
if choosenMonitor < monitorN
    choosenMonitor = 1;
    disp('Another monitored is not detected, using main monitor')
end
% Get choosen monitor position
figurePos = monitorPos(choosenMonitor, :);

% Open full screen monitor
figure('outerPosition',figurePos);

% get the figure and axes handles
MainFig = gcf;
hAx  = gca;

% set the axes to full screen
set(hAx,'Unit','normalized','Position',[0 0 1 1]);
% hide the toolbar
set(MainFig,'menubar','none')
% to hide the title
set(MainFig,'NumberTitle','off');
% Set background color
set(hAx,'color', 'black');
% Lock axes limits
hAx.XLim = [0, 1];
hAx.YLim = [0, 1];
hold on

%% Load photos

% Set classes' numbers vector
Classes = 1 : nClass;

% Load photos
[Arrow, Idle, ~] = Utillity.load_photos();

%% Parmeters
cueLength       = 2;     % Cue length in seconds
readyLength     = 1.5;   % Ready length in seconds
nextLength      = 2;     % Next length in seconds
chunk_i         = 1;     % Initiallize chunk count
correct_trials  = 0;     % Initiallize correct trials

nbChan = 16;

% Rectangle positions (order - Idle, Right, Left, Down)
rectangePos = [0.355, 0.535, 0.285, 0.395;...
    0.665, 0.55, 0.325, 0.37;...
    0.01, 0.55, 0.325, 0.37;...
    0.38, 0.035, 0.24, 0.47];

%% Load model, params etc.
% Load model
load(strcat(fullPath,'\RF_model.mat'), 'model')

% Load accumilated labels and MI features
if exist(strcat(fullPath,'\MIAccumilate.mat'), 'file')

    % Accumilating features
    prevMIAccumilate       = load(strcat(fullPath,'\MIAccumilate.mat'));
    prevMIAccumilate       = prevMIAccumilate.MIAccumilate;

    % Accumilating labels
    prevAccumilateLabels   = load(strcat(fullPath,'\accumilateLabels.mat'));
    prevAccumilateLabels   = prevAccumilateLabels.accumilateLabels;

    % Accumilating trials to remove
    prevAccumilateRemove   = load(strcat(fullPath,'\removeAccumilate.mat'));
    prevAccumilateRemove   = prevAccumilateRemove.removeAccumilate;
elseif accumulationFlag
    disp('No accumulating model in the folder, predicting with normal model.')
    accumulationFlag = 0;
end

% Load features' parameters
load(strcat(fullPath,'\FeatureParam.mat'), 'bands')
nbBands = size(bands, 2);

% Sanity check - number of classes
assert(nClass == length(model.ClassNames), ...
    'number of chosen classes and number of model classes are uneven!');

%% System Stabilazation
% Show a message that declares that training is about to begin
text(0.5,0.5 ,...
    ['System is calibrating.' sprintf('\n') 'The Training Program will begin shortly.'], ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(15)

% Clear axis
cla
%% Record Training Stage
% Prepare set of training trials with predefined arrow cues
trainingVec = Utillity.prepareTraining(numTrials,Classes);

% Allocate arraies
EEG             = zeros(nbChan, trialLength * Hz, numTrials * nClass * 3);
restingStateBands     = zeros(7, nbBands, numTrials * nClass * 3);
labels          = zeros(1, numTrials * nClass * 3);
trials2remove   = zeros(size(labels));
correctLabeled  = zeros(size(labels));

% For each trial:
for trial = 1 : (numTrials * nClass) % Number of trials times number of classes

    currentTrial = trainingVec(trial);

    % Cue before ready
    image(Arrow{1}, 'XData', [0.67 .99], 'YData', [0.92 0.55]);
    image(rot90(Arrow{1}, 2), 'XData', [0.01 .33], 'YData', [0.92 0.55]);
    image(rot90(Arrow{1}, 1), 'XData', [0.38 .62], 'YData', [0.04 0.5]);
    image(Idle{1}, 'XData', [0.37 .63], 'YData', [0.92 0.55]);
    rectangle('Position',rectangePos(currentTrial, :),'Curvature',0.2,...
        'EdgeColor', 'm', 'LineWidth', 7)
    % Wait for cue length
    pause(cueLength);
    % Clear axis
    cla

    % Ready
    text(0.5,0.5 , 'Ready',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    % Pause for ready length
    pause(readyLength);
    
    %% Present the cue untill 3 succesfull classifications
    success = ones(1, 4);  %initiallize counter

    while max(success) < 4
        
        % Clear axis
        cla
        
        % Draw current images
        image(Idle{success(1)}, 'XData', [0.37 .63], 'YData', [0.92 0.55]);
        image(Arrow{success(2)}, 'XData', [0.67 .99], 'YData', [0.92 0.55]);
        image(rot90(Arrow{success(3)}, 2), 'XData', [0.01 .33], 'YData', [0.92 0.55]);
        image(rot90(Arrow{success(4)}, 1), 'XData', [0.38 .62], 'YData', [0.04 0.5]);
        rectangle('Position',rectangePos(currentTrial, :),'Curvature',0.2,...
            'EdgeColor', 'm', 'LineWidth', 7)
        
        % Display stop and go signs
        Utillity.stopGo(restingTime);
        
        % Extract resting state signal and preprocess it
        RestingSignal       = restingStateDelay.OutputPort(1).Data';
        [RestingMI, ~]      = Proccessing.Preprocess(RestingSignal);
        restingStateBands(:, :, chunk_i)   = EEGFun.restingState(RestingMI, bands, Hz);
        
        % Pause for trial length
        pause(trialLength);

        % Get signal chunk
        EEG(:, :, chunk_i) = rto.OutputPort(1).Data';
        labels(chunk_i) = currentTrial;

        % Clean signal
        [MIData, removeTrial] = Proccessing.Preprocess(EEG(:, :, chunk_i));
        trials2remove(chunk_i) = removeTrial; %Flag is trial is noisy

        % Extract features
        MIFeatures(chunk_i, :) = Proccessing.ExtractFeatures(MIData, Hz, bands, restingStateBands(:, :, chunk_i));

        % Predict using the pre-trained model
        [prediction, scores] = predict(model, MIFeatures(chunk_i, :));

        % If the model is not sure, mark as idle.
        if max(scores) < 1 / nClass + 0.03
            prediction = 1;
        end

        % Saving the indexes of the trials that were classiffied correctly
        if prediction == currentTrial
            correctLabeled(chunk_i) = 1;
        end

        % Add a count for the predicted label
        success(prediction) = success(prediction) + 1;

        chunk_i = chunk_i + 1; %Next chunk index
    end

    %% Displaying final decision arrows
    [~, location] = max(success);
    % If 3 the user got 3 correct predictions, the trial is marked as
    % correct.
    correct_trials = correct_trials + isequal(location, currentTrial);

    % Clear axis
    cla

    %Draw full arrow if succeeded
    image(Idle{success(1)}, 'XData', [0.37 .63], 'YData', [0.92 0.55]);
    image(Arrow{success(2)}, 'XData', [0.67 .99], 'YData', [0.92 0.55]);
    image(rot90(Arrow{success(3)}, 2), 'XData', [0.01 .33], 'YData', [0.92 0.55]);
    image(rot90(Arrow{success(4)}, 1), 'XData', [0.38 .62], 'YData', [0.04 0.5]);
    rectangle('Position',rectangePos(currentTrial, :),'Curvature',0.2,...
        'EdgeColor', 'm', 'LineWidth', 7)

    % Pause for the final display
    pause(nextLength)
    % Clear axis
    cla

    % After the final trial
    if trial == (numTrials * nClass)
        % Display model training messsage on screen
        text(0.5,0.5 , 'Training new model, please wait.',...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
        pause(0.000000000000000001)
    else
        % Otherwise, display "Next" trial text
        text(0.5,0.5 , 'Next',...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
        % Display trial count
        text(0.5,0.2 , strcat('Trial #',num2str(trial + 1),' Out Of : '...
            ,num2str(numTrials * nClass)),...
            'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
        % Wait for next trial
        pause(nextLength);
        % Clear axis
        cla
    end
end

%% Delete spare space in arraies
EEG(:,:,chunk_i:end)           = [];
labels(chunk_i:end)            = [];
trials2remove(chunk_i:end)     = [];
correctLabeled(chunk_i:end)    = [];


%% End of recording session

%Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')
bdclose all

%% Train new model
disp('Training new model, please wait')

%Get Date and time for the model
date = char(datetime);
date = date(1 : end - 3);
date = strrep(date,':','-');

%Create folder with the new model
recordingFolder = strcat('C:\Subjects\Sub',num2str(subID),'\online -',date,'\');   %%% Change the path if needed %%%
mkdir(recordingFolder);

%% Accumilate the current correct trials to the previous trials
if accumulationFlag
    correctLabeled = logical(correctLabeled);
    % Extract correct trials' labels and trials to remove from correct trials
    removeCorrect   = trials2remove(correctLabeled);
    correctlabels   = labels(correctLabeled);
    MIcorrect       = MIFeatures(correctLabeled,:);

    % Concatenate all previous correct MI features and labeles
    accumilateLabels   = [correctlabels , prevAccumilateLabels];
    MIAccumilate       = [MIcorrect ; prevMIAccumilate];
    removeAccumilate   = [removeCorrect , prevAccumilateRemove];

    % If no accumilation wanted, create fresh accumilated data
else
    accumilateLabels   = labels;
    MIAccumilate       = MIFeatures;
    removeAccumilate   = trials2remove;
end

%Save in the folder the recording data
save([recordingFolder, 'EEG'], 'EEG')
save([recordingFolder, 'MIFeatures'], 'MIFeatures')
trainingVec = labels; %Rename for comfort
save([recordingFolder, 'trainingVec'], 'trainingVec')
save([recordingFolder, 'trials2remove'], 'trials2remove')
save([recordingFolder, 'FeatureParam'], 'bands')
save([recordingFolder, 'restingStateBands'], 'restingStateBands')
save([recordingFolder, 'correctLabeled'], 'correctLabeled')
save([recordingFolder, 'removeAccumilate'], 'removeAccumilate')
save([recordingFolder, 'MIAccumilate'], 'MIAccumilate')
save([recordingFolder, 'accumilateLabels'], 'accumilateLabels')


%% Train model

if ~accumulationFlag
    %Train new model
    [~, validationAccuracy]...
        = Proccessing.LearnModel(MIFeatures, labels, trials2remove, recordingFolder);
else
    [~, validationAccuracy]...
        = Proccessing.LearnModel(MIAccumilate, accumilateLabels, removeAccumilate, recordingFolder);
end

%Rename folder with new model accuracy
newDirName = strcat('C:\Subjects\Sub',num2str(subID),'\online -',num2str(validationAccuracy*100),'% Accuracy\');
movefile(recordingFolder, newDirName)

% Print how many trials were correctly classifiied (3/3)
disp([num2str(correct_trials) ' out of ' num2str(numTrials * nClass) '(' ...
    num2str(100 * correct_trials / (numTrials * nClass)) '%)'])

% Display accuracy messsage on screen
cla
text(0.5,0.5 , [ 'New Model Accuracy - ' num2str(validationAccuracy*100),'%'...
    sprintf('\n') 'Current Session (Previous Model) Performance - ' ...
    num2str(correct_trials) ' Out Of ' num2str(numTrials * nClass)...
    '('  num2str(100 * correct_trials /(numTrials * nClass)) '%)'],...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);

% Wait for button press
text(0.5,0.2 , 'Press Any Key To Close Program',...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
% Wait
waitforbuttonpress
% Close
close(MainFig)
end
