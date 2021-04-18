%% MI Training Scaffolding

function [recordingFolder,subID] = MI_Training_4Class(bands)
%% Set params and setup psychtoolbox & Simulink
% define objects' strings for Simulink objects
USBobj          = 'USBamp_offline';
% BUFFobj         = 'USBamp_offline/Buffer';
% RestBUFFobj     = 'USBamp_offline/Resting State Buffer';
AMPobj          = 'USBamp_offline/g.USBamp UB-2016.03.01';
IMPobj          = 'USBamp_offline/Impedance Check';
RestDelayobj          = 'USBamp_offline/Resting Delay';
ChunkDelayobj          = 'USBamp_offline/Chunk Delay';

% open Simulink
open_system(USBobj)
set_param(USBobj,'BlockReduction', 'off')

% create parameter gui
[Hz, trialLength, numClass, subID, ~, numTrials, restingTime] = ...
    parameter_gui(ChunkDelayobj, AMPobj, IMPobj, RestDelayobj);

%Start simulation
getSig_offline(inf);

%Get the running time object (buffer)
rto = get_param(ChunkDelayobj,'RuntimeObject');
restingStateDelay = get_param(RestDelayobj,'RuntimeObject');

% % % subID = input('Please enter subject ID: ');     % prompt to enter subject ID
%Get Date and time for the model
date = string(datetime);
date = date(1 : end - 3);
date = strrep(date,':','-');

Classes = 1 : numClass;
recordingFolder = strcat('C:\Subjects\Sub',num2str(subID),'\offline- ',date,'\');   %%% Change the path if needed %%%
mkdir(recordingFolder);
idleSign = imread('idleSign.jpg');              % (1) load idle sign
rightArrow = imread('RightArrow.jpg');          % (2) load right arrow image
leftArrow = imread('LeftArrow.jpg');            % (3) load left arrow image
downArrow = imread('downArrow.jpg');            % (4) load down arrow image

% % % Hz = 512;                                       % sampling rate
nbchan = 16;                                    % number of channels
% % % numTrials =50;                                 % set number of training trials PER CONDITION %%%
% % % trialLength = 3;                                % each trial length in seconds
cueLength = 0.5;
readyLength = 0.5;                              %%% Added cue ready and next lengths %%%
nextLength = 0.5;
% % % numClass = length(Classes);                                   % number of classes to train (two hands, leg & permutations + idle)
% % % BuffSz = 0.5; % Buffer size in seconds

EEG = zeros(nbchan, trialLength*Hz, numClass*numTrials);


% Define the keyboard keys that are listened for:
KbName('UnifyKeyNames');
escapeKey = KbName('Escape');                   % let psychtoolbox know what the escape key is


%% Psychtoolbox, Stim, Screen Params Init:
disp('Setting up Psychtoolbox parameters...');
disp('This will open a black screen - good luck!');
PsychDebugWindowConfiguration(0,1);   %%% For debugging, change 1 to 0.5 (opaquaness of the screen) %%%
Screen('Preference', 'SkipSyncTests', 0);   %%% Change to 1 if in debugging mode %%%
[window,white,black,screenXpixels,screenYpixels,xCenter,yCenter,ifi] = PsychInit();
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);



%% Record Resteing State Stage
DrawFormattedText(window, strcat(['Just rest for now. \n' 'The training will begin soon.']), 'center','center', white);
Screen('Flip', window);
pause(10) % Letting the signal to get stable
pause(restingTime)
RestingSignal =  restingStateDelay.OutputPort(1).Data';
%     for t = 1 : floor(restingTime / 5)
%         pause(5);
%         RestingSignal(:, 1 + (t-1) * Hz * 5 : Hz * 5 + ((t - 1) * Hz * 5)) = ...
%             restingStateBuffer.OutputPort(1).Data';
%     end
% Cut and clean the signalas needed
[RestingSignal, ~] = MI_Preprocess(RestingSignal);
% Show a message the declares that training is about to begin
DrawFormattedText(window, strcat('The training will begin in few seconds.'), 'center','center', white);
Screen('Flip', window);
pause(3)
%% Record Training Stage
% prepare set of training trials with predefined arrow cues
trainingVec = prepareTraining(numTrials,Classes);  %% Changed the function to be equal trials per condition %%%
save(strcat(recordingFolder,'trainingVec.mat'),'trainingVec');
labelVec = trainingVec;
pause(0.2);
%GetSig %TODO need to add a stop mechanism
%t0 = GetSecs

% for each trial:
for trial_i = 1:numTrials * numClass %%% Trials times number of classes %%%
    
    
    % Check Keyboard press
    [keyIsDown,secs, keyCode] = KbCheck;    % check for keyboard press
    if keyCode(escapeKey)                   % pushed escape key - SHUT IT DOWN!!!
        ShowCursor;
        sca;
        return
    end
    
    currentTrial = trainingVec(trial_i);
    if currentTrial == 1
        imageTexture = Screen('MakeTexture', window, idleSign);
    elseif currentTrial == 2
        imageTexture = Screen('MakeTexture', window, rightArrow);
    elseif currentTrial == 3
        imageTexture = Screen('MakeTexture',window, leftArrow);
    elseif currentTrial == 4
        imageTexture = Screen('MakeTexture',window, downArrow);
        
    end
    
    %%% Added cue before ready %%%
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    pause(cueLength);
    
    
    % Show on screen the corresponding arrow for entire trial for 5 seconds
    % Arrow Cue
    Screen('TextSize', window, 50);                         % Draw text in the bottom portion of the screen in white
    DrawFormattedText(window, 'Ready', 'center',screenYpixels * 0.75, white);
    Screen('Flip', window);
    pause(readyLength);         % used to be 2 seconds
    
    
    
    DrawFormattedText(window, strcat('Trial #',num2str(trial_i),' from:',num2str(numTrials * numClass)), 'center',screenYpixels * 0.98, white);
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    pause(trialLength)
    EEG(:, :, trial_i) = rto.OutputPort(1).Data';
    %In the offline proccess, we will  use loop and take buffers.
    %     for t = 1 : trialLength * 2
    %         pause(BuffSz);
    %         EEG(:, 1 + (t-1) * Hz * BuffSz : Hz * BuffSz + ((t - 1) * Hz * BuffSz), trial) = ...
    %             rto.OutputPort(1).Data';
    %     end
    
    Screen('TextSize', window, 70);  % Draw text in the bottom portion of the screen in white
    DrawFormattedText(window, 'Next', 'center',screenYpixels * 0.75, white);
    Screen('Flip', window);
    pause(nextLength);               % "Next" stays on screen
    
end

%% End of recording session
ShowCursor;
sca;
Priority(0);
save([recordingFolder, 'EEG'], 'EEG')
save([recordingFolder, 'RestingSignal'], 'RestingSignal')
save([recordingFolder, 'parameters'], 'Hz', 'trialLength')
save(strcat(recordingFolder,'FeatureParam'),'bands');
disp('finish :)');
%Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')

