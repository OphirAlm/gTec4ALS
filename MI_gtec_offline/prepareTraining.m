function [trainingVec] = prepareTraining(numTrials,Class)
%% return a random vector of 1's and 2's and 3's length of numTrials
%%% We changed it to be equal number of trials per condition %%%

% trainingVec = (1:numClass);
trainingVec = repmat(Class,1,numTrials);
trainingVec = trainingVec(randperm(length(trainingVec)));

end