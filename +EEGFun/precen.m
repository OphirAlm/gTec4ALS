function prec = precen(distribution , precentile ,frequency)
%PRECEN Finds the frequency value of the desired precentile from a probability
%distribution.
%
% INPUT:
%     - distribution - the distribution function.
%     - precentile - the % you want to find.
%     - frequency -Frequency spectrum.
%
% OUTPUT:
%     - prec - the wanted precentile value of a distribution function vector.
%
%--------------------------------------------------------------------------------

% Create CDF from PDF
Cumulative = cumsum(distribution ,2);

% Extract number of trials
trials_N = size(distribution , 1);

% Allocate output variable
prec=zeros(trials_N,1);

% Calculate percentile for each trial
for trial_i = 1:trials_N
    index = find(Cumulative(trial_i,:) >= precentile ,1);
    prec(trial_i) = frequency(index);
end
end