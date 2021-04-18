function Visualize(data , left_idx, right_idx, idle_idx, Fs , f, window_sz ,...
    overlap_sz , elec_name ,imagine_t , trials_N ,max_trials ,Font)
%MATLAB R2019b
%
%Creating visualization of the EEG signal with left and right trials
%division: random N trials, spectrogram per elctrode and condition, and the
%condition differnce, power spectrum plot and ERP plot.
%
%data - the amplitude data for all trials and electrodes.
%left_idx , right_idx - the indexis of left \ right trials.
%Fs - Sampling rate.
%f - frequencies vector
%window_sz - window size.
%overlap_sz - overlap size.
%elec_name - electrodes names string.
%imagine_t - time period the subject imagined the hand movement.
%trials_N - number of random trials per condition wanted for ploting.
%max_trials - Maximum numbers of trials to plot per figure.
%Font - Structure of font size.
%
%output- all of the above mentioned graphes, no need to pre assign figure.
%function will create on it own.
%
%--------------------------------------------------------------------------------


%% Setting parameters
elec_N = length(elec_name);
%Figures sizes
trials_fig_sz = [3.2808,1.07597,28.0458,15.85736];
spec_diff_fig_sz = [1.28764,2.1343,30.8857,14.19049];
power_fig_sz = [0.51,4.145,32.543,9.684];
spec_fig_sz = [7.285,2.8575,19.685,13.0175];
erp_fig_sz = [1.28764,2.1343,30.8857,14.19049];


%Arranging the data to left and right.
left_data = data(left_idx, :, 1:elec_N);
right_data = data(right_idx, :, 1:elec_N);
idle_data = data(idle_idx, :,  1:elec_N);

%Sizes
[sampels_N , L , elec_N] = size(left_data);
time_v = (1:L)/Fs; %Time vector in seconds for al sampels in signal.

%Number of windows and time as function of windows.
[window_N , wind2time] = windy(L,window_sz,overlap_sz,Fs);

%% Random trials plot
%getting random trials indexis per each condition
trials_left_idx = randperm(size(left_data,1) , trials_N);
trials_right_idx = randperm(size(right_data,1) , trials_N);
trials_idle_idx = randperm(size(idle_data,1) , trials_N);

%Creating trials array per condition.
trials_left = left_data(trials_left_idx,:,:);
trials_right = right_data(trials_right_idx,:,:);
trials_idle = idle_data(trials_idle_idx,:,:);

%Getting the minimum and maximum amplitude values, for having same limits
%on all plots (between conditions aswell).
Limit.top = max(max(max(max(trials_left))) ,...
    max(max(max(trials_right))));
Limit.bot = min(min(min(min(trials_left))) ,...
    min(min(min(trials_right))));

%Plotting the trials
%Left trials
plotTrials(max_trials,  trials_left, time_v ,trials_fig_sz,...
    elec_name , Font , Limit, 'Left')
%Right trials
plotTrials(max_trials,  trials_right, time_v ,trials_fig_sz,...
    elec_name , Font , Limit, 'Right')
%Idle trials
plotTrials(max_trials,  trials_idle, time_v ,trials_fig_sz,...
    elec_name , Font , Limit, 'Idle')

%% Spectrogram

%Creating a structure
for elec_i = 1:elec_N
    Right.(elec_name{elec_i}) = zeros(sampels_N, length(f),window_N);
    Left.(elec_name{elec_i}) = zeros(sampels_N, length(f),window_N);
    Idle.(elec_name{elec_i}) = zeros(sampels_N, length(f),window_N);
end

%Getting Fourier transform values for power computation from each trials
for elec_i = 1:elec_N
    for trial_i = 1:sampels_N
        tempR = spectrogram(right_data(trial_i,:,elec_i)'...
                    , window_sz , overlap_sz ,f , Fs ,'yaxis');
        tempL = spectrogram(left_data(trial_i,:,elec_i)'...
                    , window_sz , overlap_sz ,f , Fs ,'yaxis');
        tempI = spectrogram(idle_data(trial_i,:,elec_i)'...
                    , window_sz , overlap_sz ,f , Fs ,'yaxis');
                
        Right.(elec_name{elec_i})(trial_i,:,:) = ...
            reshape(tempR,[1 size(tempR)]);
        Left.(elec_name{elec_i})(trial_i,:,:) = ...
            reshape(tempL,[1 size(tempL)]);
        Idle.(elec_name{elec_i})(trial_i,:,:) = ...
            reshape(tempI,[1 size(tempI)]);
    end
end

%Computing mean power over trials in dB units
for elec_i = 1:elec_N
    Right.(elec_name{elec_i}) = SpecPower(Right.(elec_name{elec_i}));
    Left.(elec_name{elec_i}) = SpecPower(Left.(elec_name{elec_i}));
    Idle.(elec_name{elec_i}) = SpecPower(Idle.(elec_name{elec_i}));
end

%Computing diffrence in power between left and right trials per electrode
for elec_i = 1:elec_N
    DifRL.(elec_name{elec_i}) = Right.(elec_name{elec_i})-Left.(elec_name{elec_i});
    DifRI.(elec_name{elec_i}) = Right.(elec_name{elec_i})-Idle.(elec_name{elec_i});
    DifLI.(elec_name{elec_i}) = Left.(elec_name{elec_i})-Idle.(elec_name{elec_i});
    DifLR.(elec_name{elec_i}) = Left.(elec_name{elec_i})-Right.(elec_name{elec_i});
    DifIR.(elec_name{elec_i}) = Idle.(elec_name{elec_i})-Right.(elec_name{elec_i});
    DifIL.(elec_name{elec_i}) = Idle.(elec_name{elec_i})-Left.(elec_name{elec_i});
end

%Plotting power spectrograms
figure('units' , 'centimeters' , 'position' , spec_fig_sz)
for elec_i = 0:elec_N-1
    subplot(elec_N,3, (elec_i)*3+1)
    imagesc(wind2time,f,Left.(elec_name{elec_i+1})(:,:,elec_i+1))
    %title labels etc...
%     xticks(0:5);
%     xticklabels(0:5);
    set(gca,'FontSize',Font.axesmall) %Axes font size.
    colormap(jet)
    colorbar('visible' , 'off')
    y_labe = ylabel('Frequency [Hz]' , 'FontSize' , 10);
    y_labe.Units = 'centimeters'; %Setting y label position to cm.
    pos = y_labe.Position; %Getting y label position.
    text(pos(1)-1.5, pos(2) , elec_name{elec_i+1} , 'FontSize' , Font.title ...
        ,'Units', 'Centimeters'); %Electrode label 1.5 cm to the left of the y label.
    set(gca,'YDir','normal')
    if elec_i == 0
        title('Left' , 'FontSize' , Font.title)
    elseif elec_i == elec_N - 1
        xlabel('Time [Sec]' ,'FontSize' ,Font.label)
    end
    
    subplot(elec_N,3, elec_i*3+2)
    imagesc(wind2time,f,Right.(elec_name{elec_i+1})(:,:,elec_i+1))
    %title labels etc...
%     xticks(0:5);
%     xticklabels(0:5);
    set(gca,'FontSize',Font.axesmall) %Axes font size.
    colormap(jet)
    set(gca,'YDir','normal')
    colorbar('visible' , 'off')
    %Only one color bar and more titles and labels.
    if elec_i == 0
        title('Right' , 'FontSize' , Font.label)
    elseif elec_i == elec_N -1
        xlabel('Time [Sec]' ,'FontSize' ,Font.label)
    end
    
    
    subplot(elec_N,3, elec_i*3+3)
    imagesc(wind2time,f,Idle.(elec_name{elec_i+1})(:,:,elec_i+1))
    %title labels etc...
%     xticks(0:5);
%     xticklabels(0:5);
    set(gca,'FontSize',Font.axesmall) %Axes font size.
    colormap(jet)
    set(gca,'YDir','normal')
    colorbar('visible' , 'off')
    if elec_i == 0
        title('Idle' , 'FontSize' , Font.label)
    elseif elec_i == elec_N
        xlabel('Time [Sec]' ,'FontSize' ,Font.label)
    end
    if elec_i == elec_N -1
        cb = colorbar('location' , 'manual', 'Position' , [0.89,0.23,0.0245,0.552]);
        cb.Label.String = 'Power [dB]';
        cb.Label.FontSize = Font.label;
    end
    
end


%Ploting power diffrences (only between left and right)
figure('units' , 'centimeters' , 'position' , spec_diff_fig_sz)
for elec_i = 0:elec_N-1
    subplot(elec_N,3,elec_i*3+1)
    imagesc(wind2time,f,DifRL.(elec_name{elec_i+1})(:,:,elec_i+1))
    %title labels etc...
%     xticks(0:5);
%     xticklabels(0:5);
    if elec_i == 0
        title('Right minus Left' , 'FontSize' , Font.title);
    end
    ylabel(elec_name{elec_i+1} ,'FontSize' ,Font.label)
    set(gca,'FontSize',Font.axebig) %Axes font size.
    colormap(jet)
    set(gca,'YDir','normal')
    if elec_i == elec_N-1
        xlabel('Time [Sec]' ,'FontSize' ,Font.label)
    end
    %show only one color bar.
    if elec_i ~= elec_N - 1
        colorbar('visible' , 'off')
    else
        cb = colorbar('location' , 'manual', 'Position' , [0.92,0.23,0.0245,0.552]);
        cb.Label.String = 'Power difference [dB]';
    end
    
    subplot(elec_N,3,elec_i*3+2)
    imagesc(wind2time,f,DifRI.(elec_name{elec_i+1})(:,:,elec_i+1))
    %title labels etc...
%     xticks(0:5);
%     xticklabels(0:5);
    if elec_i == 0
        title('Right minus Idle' , 'FontSize' , Font.title);
    end
    set(gca,'FontSize',Font.axebig) %Axes font size.
    colormap(jet)
    set(gca,'YDir','normal')
    if elec_i == elec_N-1
        xlabel('Time [Sec]' ,'FontSize' ,Font.label)
    end
    
    subplot(elec_N,3,elec_i*3+3)
    imagesc(wind2time,f,DifLI.(elec_name{elec_i+1})(:,:,elec_i+1))
    %title labels etc...
%     xticks(0:5);
%     xticklabels(0:5);
    if elec_i == 0
        title('Left minus Idle' , 'FontSize' , Font.title);
    end
    set(gca,'FontSize',Font.axebig) %Axes font size.
    colormap(jet)
    if elec_i == elec_N-1
        xlabel('Time [Sec]' ,'FontSize' ,Font.label)
    end
    set(gca,'YDir','normal')
% % %     
% % %     subplot(elec_N,6,elec_i*6+4)
% % %     imagesc(wind2time,f,DifLR.(elec_name{elec_i+1})(:,:,elec_i+1))
% % %     %title labels etc...
% % %     xticks(0:5);
% % %     xticklabels(0:5);
% % %     if elec_i == 0
% % %         title('Left minus Right' , 'FontSize' , Font.title);
% % %     end
% % %     set(gca,'FontSize',Font.axebig) %Axes font size.
% % %     colormap(jet)
% % %     if elec_i == elec_N-1
% % %         xlabel('Time [Sec]' ,'FontSize' ,Font.label)
% % %     end
% % %     set(gca,'YDir','normal')
% % %     
% % %     subplot(elec_N,6,elec_i*6+5)
% % %     imagesc(wind2time,f,DifIR.(elec_name{elec_i+1})(:,:,elec_i+1))
% % %     %title labels etc...
% % %     xticks(0:5);
% % %     xticklabels(0:5);
% % %     if elec_i == 0
% % %         title('Idle minus Right' , 'FontSize' , Font.title);
% % %     end
% % %     set(gca,'FontSize',Font.axebig) %Axes font size.
% % %     colormap(jet)
% % %     if elec_i == elec_N-1
% % %         xlabel('Time [Sec]' ,'FontSize' ,Font.label)
% % %     end
% % %     set(gca,'YDir','normal')
% % %     
% % %     subplot(elec_N,6,elec_i*6+6)
% % %     imagesc(wind2time,f,DifIL.(elec_name{elec_i+1})(:,:,elec_i+1))
% % %     %title labels etc...
% % %     xticks(0:5);
% % %     xticklabels(0:5);
% % %     if elec_i == 0
% % %         title('Idle minus Left' , 'FontSize' , Font.title);
% % %     end
% % %     set(gca,'FontSize',Font.axebig) %Axes font size.
% % %     colormap(jet)
% % %     if elec_i == elec_N-1
% % %         xlabel('Time [Sec]' ,'FontSize' ,Font.label)
% % %     end
% % %     set(gca,'YDir','normal')
    
end

%% Power spectrum
power = zeros(elec_N*3 , length(f) , sampels_N);
figure('units' , 'centimeters' , 'position' , power_fig_sz)
% sgtitle('Power spectrum' , 'FontSize' , Font.title)
for elec_i = 1:elec_N
    %Left trials power
    power(elec_i*3-2,:,:) =10*log10(pwelch(left_data(:,imagine_t,elec_i)' ...
        , window_sz , overlap_sz , f , Fs)); %Power
    std_dev = std(power(elec_i*3-2,:,:),0,3); %Standard deviation of power over trials
    mean_power = squeeze(mean(power( elec_i*3-2,:,:),3)); %Mean power over trials
    %Plot
    subplot(ceil(elec_N/2) , 2 , elec_i)
    left_line = plotPower(mean_power , std_dev,f,'b');
    
    
    %Right trials power
    power(elec_i*3-1,:,:) = 10*log10(pwelch(right_data(:,imagine_t,elec_i)' ...
        , window_sz , overlap_sz , f , Fs)); %Power
    std_dev = std(power(elec_i*3-1,:,:),0,3); %Standard deviation of power over trials
    mean_power = squeeze(mean(power( elec_i*3-1,:,:),3)); %Mean power over trials
    %Plot
    hold on
    right_line = plotPower(mean_power, std_dev, f, 'r');
    
    %Idle trials power
    power(elec_i*3,:,:) = 10*log10(pwelch(idle_data(:,imagine_t,elec_i)' ...
        , window_sz , overlap_sz , f , Fs)); %Power
    std_dev = std(power(elec_i*3,:,:),0,3); %Standard deviation of power over trials
    mean_power = squeeze(mean(power( elec_i*3,:,:),3)); %Mean power over trials
    %Plot
    hold on
    idle_line = plotPower(mean_power, std_dev, f, 'g');
    
    %title and labels
    title(elec_name{elec_i})
    xlim([f(1) , f(end)])
    set(gca,'FontSize',Font.axebig) %Axes font size.
    if elec_i >= elec_N - 1
        xlabel ('Frequency [Hz]')
    end
    %Legend
    legend([left_line , right_line, idle_line] , 'Left trials' , 'Right trials' , 'Idle trials')
    
end

%% ERP
%Compute ERP
for elec_i = 1:elec_N
    ERP.left.(elec_name{elec_i}) = mean(left_data(:,:,elec_i));
    ERP.right.(elec_name{elec_i}) = mean(right_data(:,:,elec_i));
    ERP.Idle.(elec_name{elec_i}) = mean(idle_data(:,:,elec_i));
end

%Plot ERP
figure('units' , 'centimeters' , 'position' , erp_fig_sz)
% sgtitle('ERP' , 'FontSize' , Font.title)
for elec_i = 1:elec_N
    %Left ERP
    subplot(3,1,1)
    hold on
    plot(time_v , ERP.left.(elec_name{elec_i}))
    title('Left trials')
    ylabel('Amplitude [\muV]')
    xlim([time_v(1) time_v(end)])
    set(gca,'FontSize',Font.axebig) %Axes font size.
    
    %Right ERP
    subplot(3,1,2)
    hold on
    plot(time_v , ERP.right.(elec_name{elec_i}))
    title('Right trials')
    ylabel('Amplitude [\muV]')
    xlabel('Time [Sec]')
    xlim([time_v(1) time_v(end)])
    set(gca,'FontSize',Font.axebig) %Axes font size.
    
    %Idle ERP
    subplot(3,1,3)
    hold on
    plot(time_v , ERP.Idle.(elec_name{elec_i}))
    title('Idle trials')
    ylabel('Amplitude [\muV]')
    xlabel('Time [Sec]')
    xlim([time_v(1) time_v(end)])
    set(gca,'FontSize',Font.axebig) %Axes font size.
end
legend(elec_name, 'Position' , [0.921,0.423,0.056,0.1374])