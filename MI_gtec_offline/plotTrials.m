function plotTrials(max_trials,  trials_data, time_v , ...
    trials_fig_sz, elec_name , Font , Limit, condition)
%MATLAB R2019b
%
%Plotting trials amplitude of the choosen condition (left\right), with
%maximum of desired subplots per figure, creating more figures if needed.
%
%max_trials - Maximum numbers of trials to plot per figure.
%trials_data - data of the trials to plot.
%time_v - time vector of the trial.
%trials_fig_sz - figure sizes in centimeters,
%elec_name - Electrode names cell.
%Font - Structure of font size.
%Limit - Structure of the top and bottum limits for y axes.
%condition - String of the condition - Left\Right.
%
%output- Plotting the trials amplitude for all the electrode on number of
%figures, keeping max trials per figure at max_trials.
%
%--------------------------------------------------------------------------------

%Getting sizes.
elec_N = length(elec_name);
trials_N = size(trials_data,1);
fig_N = ceil(trials_N/max_trials);

%Looping over number of needed figures.
for fig_i = 1:fig_N
    figure('units' , 'centimeters' , 'position' , trials_fig_sz)
%     sgtitle([condition ' trials - Figure #' num2str(fig_i)] , 'FontSize' , Font.title)
    subpl_i = 1; %Subplot index.
    %Loop through the trials, per figure group.
    for trial_i = 1 + (fig_i-1)*max_trials : max_trials + (fig_i-1)*max_trials
        %Break if all trials has been plotted
        if trial_i >trials_N
            break
        end
        %Plot
        subplot(max_trials/2, 2, subpl_i) %2 columns subplots (NOT magic)
        for elec_i = 1:elec_N
            hold on
            plot(time_v , trials_data(trial_i , : , elec_i))
        end
        %Labels, limits, fonts, etc...
        ylim([Limit.bot , Limit.top]) %Set limits.
        set(gca,'FontSize',Font.axesmall) %Axes font size.
        
        %Show only at the buttom subplots X axis labels.
        if (subpl_i == max_trials-1 || subpl_i == max_trials) || ...
                (fig_i == fig_N && (trial_i == trials_N || trial_i == trials_N-1))
            xlabel('Time [Sec]' ,'FontSize' , Font.label)
        end
        
        if subpl_i == 1
            %Show only one Y axis label for estethics reasons.
            ylabe = text(-1.5,-7 , 'Amplitude [\muV]' ,  'units' , 'centimeters'...
                ,'FontSize' , Font.title);
            ylabe.Rotation = 90; %Vertical alignment.
            %Plot only one legend for all subplots.
            legend(elec_name , 'Position' , [0.0267,0.776,0.07318,0.138]...
                ,'FontSize' , Font.label)
        end
        subpl_i = subpl_i + 1; %Advance to next subplot.
    end
end