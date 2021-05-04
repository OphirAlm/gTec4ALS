%% Motor Imagery Main GUI

% Open GUI and choose
 % Add GUI
 
%% Choose file to run according to decision
if online _ Learn
    addpath([pwd, '\MI_gtec_onlineLearn'])
    MI_Online_Training
    rmpath([pwd, '\MI_gtec_onlineLearn'])
elseif offline_Learn
    addpath([pwd, '\MI_gtec_offline'])
    MainScript
    rmpath([pwd, '\MI_gtec_offline'])
elseif Online _ Communicate
    addpath([pwd, '\MI_gtec_onlineCommunicate'])
    MI_Online_Communicate
    rmpath([pwd, '\MI_gtec_onlineCommunicate'])
end
