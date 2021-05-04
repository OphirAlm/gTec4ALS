function [restingStateBands] = restingState(signal, bands, Hz)
% Getting a signal of a resting state, and returns the power of each band,
% at each electrodr,of the resting state (Used to compute ERS\ERD).


% Get number of channels from main data variable
numChans = size(signal,1);                                    
% How many bands to extract are there
numBands = length(bands);                   
% Pre-allocation
restingStateBands = NaN(numChans, numBands);                      

%% Extract Power Bands
for channel = 1:numChans

    %Band power features
    for band_i = 1 : numBands
        % Extract bandpower
        restingStateBands(channel, band_i) = bandpower(signal(channel,:),Hz,bands{band_i});
    end

end
