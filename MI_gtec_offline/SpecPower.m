function spec_output =  SpecPower(spec_output)
%MATLAB R2019b
%
%This function will take the fourier transform values, transform them into
%power values in dB units, and finally mean over all the results.
%
%specoutput- the matrix of the output from the spectrogram, from all the
%trials to mean over.
%
%mean_power - mean of the power in dB over all the trials.
%
%--------------------------------------------------------------------------------

%Tranform to power
spec_output = abs(spec_output);
spec_output = spec_output.^2;
%Transform to decibels
spec_output = 10*log10(spec_output);
%Mean over trials - Importent to mean after the non-linears
%transformations! (due to mean qualaties),
%mean_power = mean(spec_output);
%Squeeze to get rid of redundent dimension.
%mean_power = squeeze(mean_power);
