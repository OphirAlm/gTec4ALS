%% MI_MAINGUI
% Software for MI-based BCI communication system for disabled patients.
% Communication utilizes spelling keyboard and text to speach function.
%
% Software runs three types of systems:
%     - Offline - Runs an offline simulation. Creates a ML classification
%          model based on recorded data.
%
%     - Online - Runs an online simulation, including feedback. Creates a
%          ML classification model based on recorded data.
%          - Has an option of accumulating data between sessions such that
%            the new model will be trained with recorded and previous data.
%
%     - Communication - Currently operateable for 4 classifications only.
%          Operate movements on keyboard using Right or Left MI.
%          Choose button with Leg MI.
%          No-Decision option for precision purposes.
%          Send button for Text-To-Speach.
%          Lock option to prevent gibberish when speech is unwanted.
%
% Hardware:
%     - g.tec USBamp, 16 electrodes
%
% System requirements:
%     - MATLAB R2015a
%     - Windows 7 pro
%     - g.needAccess
%     - g.recorder dongle
%     - g.HISYS
%     - g.USBamp driver
%
%% Motor Imagery Main GUI
close all; clear; clc;

%% Open GUI and choose a system
runFlag = 1;

while runFlag
    system = Utillity.main_gui();
    
    %% Choose file to run according to decision
    switch system
        case 'Offline'
            MainFun.MI_Offline_Training
        case 'Online'
            MainFun.MI_Online_Training
        case 'Communication'
            MainFun.MI_Online_Communicate
        case 'impScope'
            MainFun.signalCheck
        case ''
            runFlag = 0;
    end
    % Close all windows but main
    bdclose all
end

%%
close all; clear; clc;