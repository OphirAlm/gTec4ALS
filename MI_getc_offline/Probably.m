function probability_f = Probably(signal_power)
%MATLAB R2019b
%
%Transforming the power function to probability function
%
%probability_f - the probability distribution of the signal power.
%
%signal_power - the signal power
%
%--------------------------------------------------------------------------------

signal_tot_val = sum(signal_power ,1);

for i = 1 : length(signal_tot_val)
    probability_f(:, i) = signal_power(:, i) ./ signal_tot_val(i)';
end