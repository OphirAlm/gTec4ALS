%% Motor Imagery Main GUI
close all; clear; clc;

% Open GUI and choose a system
 system = Utillity.main_gui();

%% Choose file to run according to decision
switch system
    case 'Offline'
        MainFun.MI_Offline_Training
    case 'Online'
        MainFun.MI_Online_Training
    case 'Communication'
        MainFun.MI_Online_Communicate
end
