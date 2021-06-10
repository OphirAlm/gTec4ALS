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



%% Load photos

% % % Set classes' numbers vector
% % % Classes = 1 : nClass;

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
% % % assert(nClass == length(model.ClassNames), ...
% % %     'number of chosen classes and number of model classes are uneven!');

%% Display Setup

% Checking monitor position and number of monitors
monitorPos = get(0,'MonitorPositions');
monitorN = size(monitorPos, 1);
% Which monitor to use TODO: make a parameter
choosenMonitor = 2;
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

% Display rest message
hText = text(0.5,0.5 ,...
    ['Just rest for now.' sprintf('\n') 'The Communication Program will begin soon.'], ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);

%% Record Resteing State Stage

pause(10)                   % Letting the signal time to stabalize
pause(restingTime)          % Pause for the resting state time

% Extract resting state signal and preprocess it
RestingSignal       = restingStateDelay.OutputPort(1).Data';
[RestingMI, ~]      = Proccessing.Preprocess(RestingSignal);
restingStateBands   = EEGFun.restingState(RestingMI, bands, Hz);

% Show a message that declares that training is about to begin
delete(hText)
hText = text(0.5,0.5 ,...
    'The Communication Program will begin in few seconds.', ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(3)


%% First State Of KeyBoard GUI
% Initiall state for main menu
State.position = [0 0 0 0 1 0 0 0 0];
State.screen = 'Main';


% String to speak
outputText = '';

% Display KeyBoard
Utillity.KeyBoardGUI(State, MainFig, outputText)

% Text to speech gender
male = 'Microsoft David Desktop - English (United States)';
female = 'Microsoft Zira Desktop - English (United States)';
%% Record Training Stage

runFlag = 1;
lockedFlag = 0;
idleCount = 0;

% For each trial:
while runFlag == 1 % Number of trials times number of classes
    
    % Certianty level
    certainty = 0.35;
    if lockedFlag
        certainty = 0.6;
    end
    
    % Accumulate chunk
    pause(trialLength + 0.5)
    
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
    [MIData, removeTrial] = Proccessing.Preprocess(EEG);
    
    % Extract features
    MIFeatures = Proccessing.ExtractFeatures(MIData, Hz, bands, restingStateBands);
    
    % Predict using the pre-trained model
    [prediction, scores] = predict(model, MIFeatures);
    
    
    % If the trial was noisy, classify as idle
    if removeTrial == 1
        prediction = 1;
        % If the model was not sure, classify as idle
    elseif max(scores) < certainty
        prediction = 1;
    end
    
    % Add or reset the idle count
    if prediction == 1
        idleCount = idleCount + 1;
    else
        idleCount = 0;
    end
    
    % After 4 idles, choose the current sqaure
    if idleCount == 4
        idleCount = 0;
        prediction = 4;
    end
    
    % Update state
    [State, output] = Utillity.stateUpdate(State, prediction);
    if output ~= 0
        if strcmp(output, 'Send')
            Utillity.tts(lower(outputText), female)
            % Reset string
            outputText = '';
        elseif strcmp(output, 'Lock') && lockedFlag == 0
            % Lock the keyboard
            lockedFlag = 1;
            Utillity.tts('Keyboard Locked', female)
        elseif strcmp(output, 'Backspace')
            % Remoce character
            outputText(end) = '';
        else
            % Add character to string
            outputText(end + 1) = output;
        end
    end
    
    
    disp(prediction)
    disp(scores)
    
    % Display KeyBoard
    Utillity.KeyBoardGUI(State, MainFig, outputText)
end

%Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')
