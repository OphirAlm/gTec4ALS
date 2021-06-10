function [trainingVec] = prepareTraining(numTrials,Class)
% PREPARETRAINING returns a random vector of the classes in 
% the length of numTrials
%
% INPUT:
%     - numTrials - Number of trials (PER CLASS).
%     - Class - a vector of classes numbers.
%
% OUTPUT:
%     - trainingVec - Randomized order of classes times number of trials
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trainingVec = repmat(Class,1,numTrials);
trainingVec = trainingVec(randperm(length(trainingVec)));
end