function getSig_online(session_runtime)
% Runs the simulink online model




%%
modelName = 'USBamp_online';

if isempty(find_system('Type','block_diagram','Name',modelName))
    load_system(modelName);
end

% Add a listener to the 'Scope' block
Scope = struct(...
    'blockName','',...
    'blockHandle',[],...
    'blockEvent','',...
    'blockFcn',[]);

Scope.blockName = sprintf('%s/Scope',modelName);
Scope.blockHandle = get_param(Scope.blockName,'Handle');
Scope.blockEvent = 'PostOutputs';
Scope.blockFcn = @ScopeCallback;
% Set a listener
set_param(modelName,'SimulationMode','normal');
set_param(modelName,'SimulationCommand','start');
set_param(modelName,'StopTime', num2str(session_runtime)); 

eventHandle = add_exec_event_listener(Scope.blockName,Scope.blockEvent, Scope.blockFcn);

end
