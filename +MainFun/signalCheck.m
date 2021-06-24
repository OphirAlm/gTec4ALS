%% Signal Check Function
function signalCheck()
% SIGNALCHECK runs an imdeance test on simulink for g.tec USBamp.
% After imdenace is done a signal display is opened.
%
%% Set params and setup psychtoolbox & Simulink

% Define objects' strings for Simulink objects
USBobj          = 'USBamp_signalCheck';
IMPobj          = [USBobj '/Impedance Check'];
scopeObj        = [USBobj '/g.SCOPE'];

% Open Simulink
load_system(['Utillity/' USBobj])
set_param(USBobj,'BlockReduction', 'off')
set_param(USBobj,'Location',[1300 199 1301 200])

% Open impedance check
open_system(IMPobj);

Utillity.breakGUI()

% Close impendace
close_system(IMPobj)

% Start simulation
Utillity.startSimulation(inf, USBobj);

% Open scope check
open_system(scopeObj);

Utillity.breakGUI()

%Stop simulink
set_param(gcs, 'SimulationCommand', 'stop')
