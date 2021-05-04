function bandMat = CSPextract(MIData, nTrials, trainingVec, bands, m, Hz)

% MIData - EEG signals
%   1st dim - elec
%   2nd dim - signal
%   3rd dim - trials
% nTrials - number of trials
% trainingVec - class label vector
%   1 - Right class
%   2 - Left class
%   3 - Down clas
%   4 - Idle class
% bands - cell matrix of 2 scalars each cell band width ranges
% m - number of rows to take from each whitening matrix
% Hz - sampling rate

nBands = length(bands);
nChans = size(MIData, 1);
dat = zeros(size(MIData,1), size(MIData,2));
bandMat = cell(size(bands));

for band_i = 1:nBands
    
    Cov.R = zeros(nChans,nChans,size(MIData,3));
    countR = 1;
    Cov.L = zeros(nChans,nChans,size(MIData,3));
    countL = 1;
    Cov.I = zeros(nChans,nChans,size(MIData,3));
    countI = 1;
    Cov.D = zeros(nChans,nChans,size(MIData,3));
    countD = 1;
    
    %%
    for trial = 1:nTrials
        for chan_i = 1:nChans
            dat(chan_i,:) = bpfilt(squeeze(MIData(chan_i,:,trial))',bands{band_i}(1), bands{band_i}(2), Hz)';
        end
        if trainingVec(trial) == 1
            Cov.R(:,:,countR) = (dat*dat') / trace(dat*dat');
            countR = countR + 1;
        elseif trainingVec(trial) == 2
            Cov.L(:,:,countL) = (dat*dat') / trace(dat*dat');
            countL = countL + 1;
        elseif trainingVec(trial) == 3
            Cov.D(:,:,countD) = (dat*dat') / trace(dat*dat');
            countD = countD + 1;
        else
            Cov.I(:,:,countI) = (dat*dat') / trace(dat*dat');
            countI = countI + 1;
        end
    end
    
    Cov.I(:,:,countI:end) = [];
    Cov.L(:,:,countL:end) = [];
    Cov.R(:,:,countR:end) = [];
    Cov.D(:,:,countD:end) = [];
    
    %%
    Cov.I = mean(Cov.I,3);
    Cov.L = mean(Cov.L,3);
    Cov.R = mean(Cov.R,3);
    Cov.D = mean(Cov.D,3);
    
    %%
    
    Cov.tot = Cov.I + Cov.L + Cov.R + Cov.D;
    
    %%
    Cov.NI = Cov.L + Cov.R + Cov.D;
    Cov.NR = Cov.L + Cov.I + Cov.D;
    Cov.NL = Cov.I + Cov.R + Cov.D;
    Cov.ND = Cov.L + Cov.R + Cov.I;
    
    %%
    [U, Lambda.tot] = eig(Cov.tot);
    
    % [Lambda, ord] = sort(diag(Lambda),'descend');
    % Lambda = diag(Lambda);
    % UTrans = UTrans(:,ord);
    
    P = ((Lambda.tot)^(-0.5))*U';
    
    %%
    S.I = P * Cov.I * P';
    S.NI = P * Cov.NI * P';
    
    S.R = P * Cov.R * P';
    S.NR = P * Cov.NR * P';
    
    S.L = P * Cov.L * P';
    S.NL = P * Cov.NL * P';
    
    S.D = P * Cov.D * P';
    S.ND = P * Cov.ND * P';
    
    %%
    [B.I, Lambda.I] = eig(S.I);
    [B.NI, Lambda.NI] = eig(S.NI);
    
    [B.L, Lambda.L] = eig(S.L);
    [B.NL, Lambda.NL, B.NL] = eig(S.NL);
    
    [B.R, Lambda.R] = eig(S.R);
    [B.NR, Lambda.NR] = eig(S.NR);
    
    [B.D, Lambda.D] = eig(S.D);
    [B.ND, Lambda.ND] = eig(S.ND);
    

    %%
    
    W.I = (B.I' * P);
    W.L = (B.L' * P);
    W.R = (B.R' * P);
    W.D = (B.D' * P);
    
    %%
    
    Wm.I = W.I([1:m end-m+1:end]',:);
    Wm.R = W.R([1:m end-m+1:end]',:);
    Wm.L = W.L([1:m end-m+1:end]',:);
    Wm.D = W.D([1:m end-m+1:end]',:);
    
    %%
    
    bandMat{band_i} = [Wm.R ; Wm.L ; Wm.D ; Wm.I];
end

end