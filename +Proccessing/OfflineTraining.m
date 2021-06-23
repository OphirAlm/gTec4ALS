%% Offline MI Training
function [recordingFolder,subID, EEG, trainingVec, restingSignal, ...
    Hz, trialLength] = OfflineTraining
% OFFLINETRAINING Runs an offline training session.
% Uses parameters from parameter file and parameter selection gui.
%
% OUTPUT:
%     - recordingFolder - a fullfile path of the recorded data and other
%                         parameters
%     - subID - subject number (scalar)
%     - EEG - 3-D array of raw EEG signal recorded (electrodes, signal,
%             trial)
%     - trainingVec - a vector of scalars indicating the label of the class
%                     presented in each trial (i.e., trainingVec length
%                     equals to EEG 3rd dimension's length)
%     - restingSignal - 2-D array of raw EEG signal from a pre-train
%                       resting session. Length decided by use (default -
%                       60 seconds)
%     - Hz - sampling rate
%     - trialLength - length of eacch trail (in seconds)

%% Set params and setup psychtoolbox & Simulink
% define objects' strings for Simulink objects
USBobj          = 'USBamp_offline';
AMPobj          = [USBobj '/g.USBamp UB-2016.03.01'];
IMPobj          = [USBobj '/Impedance Check'];
RestDelayobj    = [USBobj '/Resting Delay'];
ChunkDelayobj   = [USBobj '/Chunk Delay'];

% open Simulink
open_system(['Utillity/' USBobj])
set_param(USBobj,'BlockReduction', 'off')

% create parameter gui
[Hz, trialLength, numClass, subID, numTrials, restingTime] ...
    = Utillity.parameter_gui(ChunkDelayobj, AMPobj, IMPobj, RestDelayobj, 'Offline');

%Start simulation
Utillity.startSimulation(inf, USBobj);

%Get the running time object (buffer)
rto = get_param(ChunkDelayobj,'RuntimeObject');
restingStateDelay = get_param(RestDelayobj,'RuntimeObject');

%Get Date and time for the model
date = string(datetime);
date = date(1 : end - 3);
date = strrep(date,':','-');

% Create vector of each class
Classes = 1 : numClass;
% Make directory of the current session
recordingFolder = strcat('C:\Subjects\Sub',num2str(subID),'\offline- ',date,'\');   %%% Change the path if needed %%%
mkdir(recordingFolder);

% Load photos
trainingImage{1} = imread('./LoadingPics/idleSign.jpg');              % (1) load idle sign
trainingImage{2} = imread('./LoadingPics/RightArrow.jpg');          % (2) load right arrow image
trainingImage{3} = imread('./LoadingPics/LeftArrow.jpg');            % (3) load left arrow image
trainingImage{4} = imread('./LoadingPics/downArrow.jpg');            % (4) load down arrow image

% number of channels
nbchan = 16;        
% Cue length in seconds
cueLength = 2;
% Ready length in seconds
readyLength = 1;         
% Time between trials in seconds
nextLength = 1;

% Allocate Signal matrix
EEG = zeros(nbchan, trialLength*Hz, numClass*numTrials);  

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

%% Record Resteing State Stage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % Display rest message
% % % text(0.5,0.5 ,...
% % %     ['Just rest for now.' sprintf('\n') 'The training session will begin soon.'], ...
% % %     'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
% % % 
% % % % Letting the signal time to stabalize
% % % pause(10)
% % % % Pause for the resting state time
% % % pause(restingTime)
% % % 
% % % % Extract resting state signal and preprocess it
% % % RestingSignal       = restingStateDelay.OutputPort(1).Data';
% % % [RestingMI, ~]      = Proccessing.Preprocess(RestingSignal);
% % % restingStateBands   = EEGFun.restingState(RestingMI, bands, Hz);
% % % 
% % % % Clear axis
% % % cla

% Show a message that declares that training is about to begin
text(0.5,0.5 ,...
    ['System calibrating.' sprintf('\n') 'The training session will begin shortly.'], ...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
pause(10)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear axis
cla

%% Record Training Stage
% prepare set of training trials with predefined arrow cues
trainingVec = Utillity.prepareTraining(numTrials,Classes);  %% Changed the function to be equal trials per condition %%%

% for each trial:
for trial_i = 1:numTrials * numClass
    
    % Current trial label
    currentTrial = trainingVec(trial_i);
            
    % Cue before ready
    image(flip(trainingImage{currentTrial}, 1), 'XData', [0.25, 0.75],...
        'YData', [0.25, 0.75 * ...
        size(trainingImage{currentTrial},1)./ size(trainingImage{currentTrial},2)])
    % Pause for cue length
    pause(cueLength);
    % Clear axis
    cla
    
    % Extract resting state signal and preprocess it
    RestingSignal       = restingStateDelay.OutputPort(1).Data';
    [RestingMI, ~]      = Proccessing.Preprocess(RestingSignal);
    restingStateBands   = EEGFun.restingState(RestingMI, bands, Hz);
    
    % Ready
    text(0.5,0.5 , 'Ready',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    % Pause for ready length
    pause(readyLength);
    % Clear axis
    cla
    
    
    % Show image of the corresponding label of the trial
    image(flip(trainingImage{currentTrial}, 1), 'XData', [0.25, 0.75],...
        'YData', [0.25, 0.75 * ...
        size(trainingImage{currentTrial},1)./ size(trainingImage{currentTrial},2)])    % Pause for trial length
    pause(trialLength)
    % Clear axis
    cla
    
    % Get raw signal of the trial
    EEG(:, :, trial_i) = rto.OutputPort(1).Data';
    
    % Display "Next" trial text
    text(0.5,0.5 , 'Next',...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    % Display trial count
    text(0.5,0.2 , strcat('Trial #',num2str(trial_i + 1),' Out Of : '...
        ,num2str(numTrials * nClass)),...
        'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 40);
    % Wait for next trial
    pause(nextLength);
    % Clear axis
    cla
end

%% End of recording session
% Save relevant time in the session directory
save(strcat(recordingFolder,'trainingVec.mat'),'trainingVec');
save([recordingFolder, 'EEG'], 'EEG')
save([recordingFolder, 'RestingSignal'], 'RestingSignal')
save([recordingFolder, 'parameters'], 'Hz', 'trialLength')

% Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')

% Close figure
close(MainFig)
