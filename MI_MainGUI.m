%% Motor Imagery Main GUI

% Open GUI and choose
 % Add GUI
 
%% Choose file to run according to decision
if online _ Learn
    cd([pwd, '\MI_gtec_onlineLearn'])
    MI_Online_Training
elseif offline_Learn
    cd([pwd, '\MI_gtec_offline'])
    MainScript
elseif Online _ Communicate
    cd([pwd, '\MI_gtec_onlineCommunicate'])
    MI_Online_Communicate
end
cd('..')