function probability_f = Probably(signal_power)
% PROBABLY Transforming the power function to probability function
%
% INPUT:
%     - signal_power - The signal power, in rows
%
% OUTPUT:
%     - probability_f - the probability distribution of the signal power.
%
%--------------------------------------------------------------------------------

% Allocate output variable
probability_f = zeros(size(signal_power));

% Total signal power
signal_tot_val = sum(signal_power ,1);

% Probability calculation
for i = 1 : length(signal_tot_val)
    probability_f(:, i) = signal_power(:, i) ./ signal_tot_val(i)';
end
end