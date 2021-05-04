function prec = precen(distribution , precentile ,frequency)
%MATLAB R2019b
%
%Finding the frequency value of the desired precentile from a probability
%distribution.
%
%prec - the wanted precentile value of a distribution function vector.
%
%distribution - the distribution function.
%precentile - the % you want to find.
%frequency -Frequency spectrum.
%
%--------------------------------------------------------------------------------

Cumulative = cumsum(distribution ,2);
trials_N = size(distribution , 1);
prec=zeros(trials_N,1);

for trial_i = 1:trials_N
    index = find(Cumulative(trial_i,:) >= precentile ,1);
    prec(trial_i) = frequency(index);
end