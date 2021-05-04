%% Motor Imagery Main GUI

% Open GUI and choose a system
 system = Utillity.main_gui();
 
%% Choose file to run according to decision
if strcmpi(system,'Online')
    addpath([pwd, '\MI_gtec_onlineLearn'])
    MI_Online_Training
    rmpath([pwd, '\MI_gtec_onlineLearn'])
elseif strcmpi(system,'Offline')
    addpath([pwd, '\MI_gtec_offline'])
    MainScript
    rmpath([pwd, '\MI_gtec_offline'])
elseif strcmpi(system,'Communication')
    addpath([pwd, '\MI_gtec_onlineCommunicate'])
    MI_Online_Communicate
    rmpath([pwd, '\MI_gtec_onlineCommunicate'])
end
