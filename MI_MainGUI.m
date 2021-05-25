%% Motor Imagery Main GUI
close all; clear; clc;

% Open GUI and choose a system
 system = Utillity.main_gui();

%% Choose file to run according to decision
if strcmpi(system,'Offline')
    MainFun.MI_Offline_Training
elseif strcmpi(system,'Online')
    MainFun.MI_Online_Training
elseif strcmpi(system,'Communication')
    MainFun.MI_Online_Communicate
end
