%% MI Training Scaffolding
close all; clear; clc;

%% Set params and setup psychtoolbox & Simulink

 % Define objects' strings for Simulink objects
USBobj          = 'USBamp_online';
AMPobj          = 'USBamp_online/g.USBamp UB-2016.03.01';
IMPobj          = 'USBamp_online/Impedance Check';
RestDelayobj    = 'USBamp_online/Resting Delay';
ChunkDelayobj   = 'USBamp_online/Chunk Delay';

 % Open Simulink
open_system(USBobj)
set_param(USBobj,'BlockReduction', 'off')

 % Activate parameter gui
[Hz, trialLength, nClass, subID, f, numTrials, restingTime] ...
    = parameter_gui(ChunkDelayobj, AMPobj, IMPobj, RestDelayobj);

 % Start simulation
getSig_online(inf);

 % Get the running time object (Delay line)
restingStateDelay  = get_param(RestDelayobj,'RuntimeObject');
rto                = get_param(ChunkDelayobj,'RuntimeObject');

 % Get Desired model to use (Choose folder by date)
fullPath = uigetdir(['C:/Subjects/Sub' num2str(subID) '/'], ...
    'Choose Desired Directory');

%% Psychtoolbox, Stim, Screen Params Init:
 
 % Set resolution 
 % Looking for nearest resolution available to 1980x1080, 60Hz, pixel sz 32.
% res = NearestResolution(2,[1980, 1080, 60, 32]);
 % Seting this resolution
% SetResolution(1, res);

disp('Setting up Psychtoolbox parameters...');
disp('This will open a black screen - good luck!');

%%% For debugging, change 1 to 0.5 (opaquaness of the screen) %%%
PsychDebugWindowConfiguration(0,1);
%%% Change to 1 if in debugging mode %%%
Screen('Preference', 'SkipSyncTests', 0);

 % Initialize Psychtoolbox 
[window,white,black,screenXpixels,screenYpixels,xCenter,yCenter,ifi] = PsychInit();
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);


%% Load photos

 % Set classes' numbers vector
Classes = 1 : nClass;

 % Load photos
[Arrow, Idle, Mark] = load_photos();    

%% Make Textures and psychtoolbox Display Setting

 % Make textures
[ArrowTexture, IdleTexture, MarkTexture] = Texture(window, Arrow, Idle, Mark);

 % Gap between the targets & the width of the marker line
gap = 20;
targetLine = 20;

 % Are thoose magic numbers or fitting to any screen?
 % They fit, need to set resolution at beggining
middleRect  = [xCenter - 250, 35, xCenter + 250, 535];
rightRect   = [xCenter + gap + 300, 150, xCenter + 900 + gap , 450];
leftRect    = [ xCenter - 900 - gap, 150, xCenter - gap - 300 , 450];
downRect    = [xCenter - 250, 600 + gap, xCenter + 250, 1000 + gap];

targetRect(1, :) = [middleRect(1:2) - targetLine, middleRect(3:4) + targetLine];
targetRect(2, :) = [rightRect(1:2) - targetLine, rightRect(3:4) + targetLine];
targetRect(3, :) = [leftRect(1:2) - targetLine, leftRect(3:4) + targetLine];
targetRect(4, :) = [downRect(1:2) - targetLine, downRect(3:4) + targetLine];

%% Parmeters
% % % numTrials       = 8;     % set number of training trials PER CONDITION %%%
% maxtrialLength  = 20;    % each trial length in seconds
cueLength       = 2;     % Cue length in seconds
readyLength     = 1.5;   % Ready length in seconds
nextLength      = 2;     % Next length in seconds
chunk_i         = 1;     % Initiallize chunk count
correct_trials  = 0;     % Initiallize correct trials
correct_i       = 1;     % Initiallize counter for correct EEG trials

 % Define the keyboard keys that are listened for:
KbName('UnifyKeyNames');
escapeKey = KbName('Escape');                   % let psychtoolbox know what the escape key is

%% Load model, params etc.

 % Load model
load(strcat(fullPath,'\RF_model.mat'), 'model')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Load previous model, correct EEG trials, correct labels and MI features
if exist(strcat(fullPath,'\EEGcorrect.mat'), 'file')
    load(strcat(fullPath,'\correct_RF_model.mat'), 'correctmodel')
    
    prevEEGcorrect      = load(strcat(fullPath,'\EEGcorrect.mat'));
    prevEEGcorrect      = prevEEGcorrect.EEGcorrect;
    
    prevMIcorrect       = load(strcat(fullPath,'\MIcorrect.mat'));
    prevMIcorrect       = prevMIcorrect.MIcorrect;
    
    prevCorrectLabels   = load(strcat(fullPath,'\correctlabels.mat'));
    prevCorrectLabels   = prevCorrectLabels.correctlabels;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Load features' parameters
load(strcat(fullPath,'\FeatureParam.mat'), 'bands','f')

 % Sanity check - number of classes
assert(nClass == length(model.ClassNames), ...
    'number of chosen classes and number of model classes are uneven!');

%% Record Resteing State Stage
DrawFormattedText(window, strcat(['Just rest for now. \n' 'The training will begin soon.']), 'center','center', white);
Screen('Flip', window);     % Adjust screen
pause(10)                   % Letting the signal time to stabalize
pause(restingTime)          % Pause for the resting state time

 % Extract resting state signal and preprocess it
RestingSignal       = restingStateDelay.OutputPort(1).Data';
[RestingMI, ~]      = MI_Preprocess(RestingSignal);
restingStateBands   = restingState(RestingMI, bands, Hz);

 % Show a message that declares that training is about to begin
DrawFormattedText(window, strcat('The training will begin in few seconds.'), 'center','center', white);
Screen('Flip', window);     % Adjust screen
pause(3)
%% Record Training Stage

 % Prepare set of training trials with predefined arrow cues
%%% Changed the function to be equal trials per condition %%%
trainingVec = prepareTraining(numTrials,Classes);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Allocate arraies
EEG             = zeros(size(RestingSignal, 1), trialLength * Hz, numTrials * nClass * 3);
labels          = zeros(1, numTrials * nClass * 3);
trials2remove   = zeros(size(labels));
correctLabeled  = zeros(size(labels));
EEGcorrect      = cell(1, numTrials * 3);
if exist('prevMIcorrect', 'var')
    MIFeatures  = zeros(numTrials * nClass * 3, size(prevMIcorrect, 2));
    MIcorrect   = zeros(numTrials * 3, size(prevMIcorrect, 2));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labelVec = trainingVec;
pause(0.2);

 % For each trial:
for trial = 1 : numTrials * nClass % Number of trials times number of classes
    
     % Check Keyboard press - Escape key set for shutting down the program
    [keyIsDown,secs, keyCode] = KbCheck; 
    if keyCode(escapeKey)                   
        ShowCursor;
        sca;
        return
    end
    
    currentTrial = trainingVec(trial);
    
     % Cue before ready
    if currentTrial == 4
        Screen('DrawTexture', window, MarkTexture, [], targetRect(currentTrial, :), 90);
    else
        Screen('DrawTexture', window, MarkTexture, [], targetRect(currentTrial, :), 0);
    end
    Screen('DrawTexture', window, IdleTexture(1), [], middleRect, 0);
    Screen('DrawTexture', window, ArrowTexture(1), [], rightRect, 0);
    Screen('DrawTexture', window, ArrowTexture(1), [], leftRect, 180);
    Screen('DrawTexture', window, ArrowTexture(1), [], downRect, 90);
    Screen('Flip', window);
    pause(cueLength);
    
     % Ready
    Screen('TextSize', window, 50);
    DrawFormattedText(window, 'Ready', 'center',screenYpixels * 0.75, white);
    Screen('Flip', window);
    pause(readyLength);
    
    %% Present the cue untill 3 succesfull classifications
    
    success = ones(1, nClass);  %initiallize counter
    
    while max(success) < 4
        
        if currentTrial == 4
            Screen('DrawTexture', window, MarkTexture, [], targetRect(currentTrial, :), 90);
        else
            Screen('DrawTexture', window, MarkTexture, [], targetRect(currentTrial, :), 0);
        end
        Screen('DrawTexture', window, IdleTexture(success(1)), [], middleRect, 0);
        Screen('DrawTexture', window, ArrowTexture(success(2)), [], rightRect, 0);
        Screen('DrawTexture', window, ArrowTexture(success(3)), [], leftRect, 180);
        Screen('DrawTexture', window, ArrowTexture(success(4)), [], downRect, 90);
        Screen('Flip', window);
        pause(trialLength);
        
         % Get signal chunk
        EEG(:, :, chunk_i) = rto.OutputPort(1).Data';
        labels(chunk_i) = currentTrial;
        
         % Clean signal
        [MIData, removeTrial] = MI_Preprocess(EEG(:, :, chunk_i));
        trials2remove(chunk_i) = removeTrial; %Flag is trial is noisy
        
         % Extract features
        MIFeatures(chunk_i, :) = ExtractFeatures_Online(MIData, Hz, bands, f, restingStateBands);
        
         % Predict using the pre-trained model
        prediction = model.predict(MIFeatures(chunk_i, :));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Predict using the pre-trained model
         if exist('correctmodel', 'var')
             predictionCorrect = correctmodel.predict(MIFeatures(chunk_i, :));
         end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
         % Saving the indexes of the trials that were classiffied correctly
        if prediction == currentTrial
            correctLabeled(chunk_i) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            EEGcorrect{correct_i} = EEG(:, :, chunk_i);
            MIcorrect(correct_i, :) = MIFeatures(chunk_i, :);
            correct_i = correct_i + 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
         % Add a count for the predicted label
        success(prediction) = success(prediction) + 1;
        
        chunk_i = chunk_i + 1; %Next chunk index
    end
    
    %% Check whether 3 decisions were made in a single direction, and what
    % direction it was.
       %%%%%%%%% Cant we remove the if?? descisions == 4 always %%%%%%%%%
    [decisions, location] = max(success);
    if decisions == 4
        % If 3 the user got 3 correct predictions, the trial is marked as
        % correct.
        correct_trials = correct_trials + isequal(location, currentTrial);
        
        %Draw full arrow if succeeded
        if currentTrial == 4
            Screen('DrawTexture', window, MarkTexture, [], targetRect(currentTrial, :), 90);
        else
            Screen('DrawTexture', window, MarkTexture, [], targetRect(currentTrial, :), 0);
        end
        Screen('DrawTexture', window, IdleTexture(success(1)), [], middleRect, 0);
        Screen('DrawTexture', window, ArrowTexture(success(2)), [], rightRect, 0);
        Screen('DrawTexture', window, ArrowTexture(success(3)), [], leftRect, 180);
        Screen('DrawTexture', window, ArrowTexture(success(4)), [], downRect, 90);
        Screen('Flip', window);
        pause(nextLength);
        
        % Display "Next" trial text
        Screen('TextSize', window, 70);  % Draw text in the bottom portion of the screen in white
        DrawFormattedText(window, 'Next', 'center',screenYpixels * 0.75, white);
        Screen('TextSize', window, 50);
        DrawFormattedText(window, strcat('Trial #',num2str(trial + 1),' Out Of : ',num2str(numTrials * nClass)), 'center',screenYpixels * 0.95, white);
        Screen('Flip', window);
        pause(nextLength);
    else
        % Display "Next" trial text
        Screen('TextSize', window, 70);
        DrawFormattedText(window, 'Next', 'center',screenYpixels * 0.75, white);
        Screen('TextSize', window, 50);
        DrawFormattedText(window, strcat('Trial #',num2str(trial + 1),' Out Of : ',num2str(numTrials * nClass)), 'center',screenYpixels * 0.95, white);
        Screen('Flip', window);
        pause(nextLength);
    end
end

%% Delete spare space in arraies

EEG(:,:,chunck_i:end)           = [];
labels(chunck_i:end)            = [];
trials2remove(chunck_i:end)     = [];
correctLabeled(chunck_i:end)    = [];
EEGcorrect                      = EEGcorrect(1 : correct_i - 1);
if exist('prevMIcorrect', 'var')
    MIFeatures(chunck_i:end, :) = [];
    MIcorrect(correct_i:end, :) = [];
end

%% End of recording session
ShowCursor;
sca;
Priority(0);

 %Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')

%% Train new model
disp('Training new model, please wait')

 %Get Date and time for the model
date = char(datetime);
date = date(1 : end - 3);
date = strrep(date,':','-');

 %Create folder with the new model
recordingFolder = strcat('C:\Subjects\Sub',num2str(subID),'\online -',date,'\');   %%% Change the path if needed %%%
mkdir(recordingFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %extract correct trials' labels and trials to remove from correct trials
removecorrect   = trials2remove(correctLabeled);
correctlabels   = labels(correctLabeled);

 %concatenate all previous correct MI features and labeles
if exist('prevMIcorrect', 'var')
    correctlabels   = [correctlabels , prevCorrectLabels];
    MIcorrect       = [MIcorrect ; prevMIcorrect];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %Save in the folder the recording data
save([recordingFolder, 'EEG'], 'EEG')
save([recordingFolder, 'MIFeatures'], 'MIFeatures')
trainingVec = labels; %Rename for comfort
save([recordingFolder, 'trainingVec'], 'trainingVec')
save([recordingFolder, 'trials2remove'], 'trials2remove')
save([recordingFolder, 'FeatureParam'], 'bands')
save([recordingFolder, 'RestingSignal'], 'RestingSignal')
save([recordingFolder, 'correctLabeled'], 'correctLabeled')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save([recordingFolder, 'EEGcorrect'], 'EEGcorrect')
save([recordingFolder, 'removecorrect'], 'removecorrect')
save([recordingFolder, 'MIcorrect'], 'MIcorrect')
save([recordingFolder, 'correctlabels'], 'correctlabels')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %Train new model
[trainedClassifier, validationAccuracy]...
    = MI_LearnModel_OnlineBoost(MIFeatures, labels, trials2remove, recordingFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[trainedCorrectClassifier, correctValidationAccuracy]...
    = MI_LearnModel_OnlineBoost_CorrectOnly(MIcorrect, correctlabels, removecorrect, recordingFolder);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %Rename folder with new model accuracy
newDirName = strcat('C:\Subjects\Sub',num2str(subID),'\online -',num2str(validationAccuracy*100),'% Accuracy\');
movefile(recordingFolder, newDirName)

 % Print how many trials were correctly classifiied (3/3)
disp([num2str(correct_trials) ' out of ' num2str(numTrials * nClass) '(' ...
    num2str(100 * correct_trials / (numTrials * nClass)) '%)'])