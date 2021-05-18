function spec_output =  SpecPower(spec_output)
%MATLAB R2019b
%
%This function will take the fourier transform values, transform them into
%power values in dB units
%
%specoutput- the matrix of the output from the spectrogram
%
%--------------------------------------------------------------------------------

%Tranform to power
spec_output = abs(spec_output);
spec_output = spec_output.^2;
%Transform to decibels
spec_output = 10*log10(spec_output);

