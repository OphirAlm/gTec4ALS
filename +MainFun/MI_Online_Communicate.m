%% Online Communication script

%% Set params and setup psychtoolbox & Simulink

% Define objects' strings for Simulink objects
USBobj          = 'USBamp_online';
AMPobj          = 'USBamp_online/g.USBamp UB-2016.03.01';
IMPobj          = 'USBamp_online/Impedance Check';
RestDelayobj    = 'USBamp_online/Resting Delay';
ChunkDelayobj   = 'USBamp_online/Chunk Delay';

% open Simulink
open_system(['Utillity/' USBobj])
set_param(USBobj,'BlockReduction', 'off')

% Activate parameter gui
[Hz, trialLength, nClass, subID, ~, restingTime] ...
    = Utillity.parameter_gui(ChunkDelayobj, AMPobj, IMPobj, RestDelayobj, 'Communication');

% Start simulation
Utillity.getSig_online(inf);

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
[window,white,black,screenXpixels,screenYpixels,xCenter,yCenter,ifi] = Utillity.PsychInit();
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);


%% Load photos

% Set classes' numbers vector
Classes = 1 : nClass;

% Define the keyboard keys that are listened for:
KbName('UnifyKeyNames');
% let psychtoolbox know what the escape key is
escapeKey = KbName('Escape');

%% Load model, params etc.

% Load model
load(strcat(fullPath,'\RF_model.mat'), 'model')

% Load features' parameters
load(strcat(fullPath,'\FeatureParam.mat'), 'bands','f')

% Sanity check - number of classes
assert(nClass == length(model.ClassNames), ...
    'number of chosen classes and number of model classes are uneven!');

%% Record Resteing State Stage
DrawFormattedText(window, strcat(...
    ['Just rest for now. \n' 'The Communication Program will begin soon.']),...
    'center','center', white);
Screen('Flip', window);     % Adjust screen
pause(10)                   % Letting the signal time to stabalize
pause(restingTime)          % Pause for the resting state time

% Extract resting state signal and preprocess it
RestingSignal       = restingStateDelay.OutputPort(1).Data';
[RestingMI, ~]      = OnlineProc.Preprocess(RestingSignal);
restingStateBands   = EEGFun.restingState(RestingMI, bands, Hz);

% Show a message that declares that training is about to begin
DrawFormattedText(window, strcat(...
    'The Communication Progaram will begin in few seconds.'),...
    'center','center', white);
Screen('Flip', window);     % Adjust screen
pause(3)

% Close PsychToolBox
ShowCursor;
sca;
Priority(0);
Screen('close')

%% First State Of KeyBoard GUI
% Initiall state for main menu
State.position = [0 0 0 0 1 0 0 0 0];
State.screen = 'Main';
keyboardHanle = figure;

% Display KeyBoard
Utillity.KeyBoardGUI(State, keyboardHanle, string)

% String to speak
string = '';

% Text to speech gender
male = 'Microsoft David Desktop - English (United States)';
female = 'Microsoft Zira Desktop - English (United States)';
%% Record Training Stage

runFlag = 1;
% For each trial:
while runFlag == 1 % Number of trials times number of classes
    
    % Check Keyboard press - Escape key set for shutting down the program
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(escapeKey)
        ShowCursor;
        sca;
        return
    end
    
    % Get signal chunk
    EEG = rto.OutputPort(1).Data';
    
    % Clean signal
    [MIData, removeTrial] = OnlineProc.Preprocess(EEG);
    
    % Extract features
    MIFeatures = OnlineProc.ExtractFeatures(MIData, Hz, bands, restingStateBands);
    
    % Predict using the pre-trained model
    prediction = model.predict(MIFeatures);
    
    % If the trial was noisy, classify as idle
    if removeTrial == 1
        prediction = 1;
    end
    
    % Update state
    [State, output] = Utillity.stateUpdate(State, prediction);
    if output ~= 0
        if strcmp(output, 'Send')
            Utillity.tts(string, female)
            % Reset string
            string = '';
        elseif strcmp(output, 'Help')
            % Change string to help
            string = 'I Need Help';
            % Say 3 times help is needed
            for i = 1 : 3
                Utillity.tts(string, female)
                pause(1)
            end
            % Reset the string
            string = '';
        else
            % Add character to string
            string(end + 1) = output;
        end
    end
    
    % Display KeyBoard
    Utillity.KeyBoardGUI(State, keyboardHanle, string)
    
    %     %Write the result to a txt file
    %     pred_str = num2str(prediction);
    %     txtFile = fopen('Action.txt', 'w');
    %     fprintf(txtFile, pred_str);
    %     fclose(txtFile);
end

%Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')
