function [trainingVec] = prepareTraining(numTrials,Class)
%return a random vector of the classes in the length of numTrials

trainingVec = repmat(Class,1,numTrials);
trainingVec = trainingVec(randperm(length(trainingVec)));
end