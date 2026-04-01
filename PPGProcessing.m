function [PpgProcessing, nights] = PPGProcessing(fs_PPG, nights, plot_flag)


f = waitbar(0, 'Starting PPG processing');
for ii = 1:length(nights)


    % In this case i can't do a general analysis of all the signal cause i
    % have to detrend it, using non appropriate segment of signal could
    % result in non relatable signal
    idx_start = find(nights(ii).t_PPG_datetime >= nights(ii).tags(1),1,"first");
    idx_stop = find(nights(ii).t_PPG_datetime <= nights(ii).tags(2),1,"last");

    t = (0:length(nights(ii).PPG)-1)/fs_PPG;
    t = t(idx_start:idx_stop);

    PpgProcessing(ii).PPG = zscore(detrend(nights(ii).PPG(idx_start:idx_stop)));
    PpgProcessing(ii).t_PPG_datetime = nights(ii).t_PPG_datetime(idx_start:idx_stop); % usefull to plot
    PpgProcessing(ii).t_PPG = t; % usefull to calculate IBI

    [sys_feet,idx_systolic_feet] = findpeaks(-PpgProcessing(ii).PPG,'MinPeakDistance',0.5*fs_PPG);
    sys_feet_time = PpgProcessing(ii).t_PPG(idx_systolic_feet);

    PpgProcessing(ii).IBI = diff(sys_feet_time);
    PpgProcessing(ii).time_vector_IBI = cumsum(PpgProcessing(ii).IBI);
    PpgProcessing(ii).SDNN = std(PpgProcessing(ii).IBI);
    PpgProcessing(ii).RMSD = sqrt(mean(diff(PpgProcessing(ii).IBI).^2));
    PpgProcessing(ii).meanHR = mean(60./PpgProcessing(ii).IBI);


    %% Now i want a IBI vector that i can compare with the sleep status obtained by the sleep accellerometer analysis
    %%% In order to do that i have to compare vector with the same length,
    %%% so i'm gonna do the mean over a 5 minutes time lapse as i did for the sleep analysis

    % I'm gonna see vai the Ppg_processing.time_vector_IBI how many samples
    % corrispond to five minutes and then i'm gonna average these values
    idx_IBI = [];
    count = 1;
    for jj = 1:length(PpgProcessing(ii).time_vector_IBI)
        if mod(PpgProcessing(ii).time_vector_IBI(jj),300) < 1 %300 is the seconds equivalent to five minutes, 0.1 cause theretically i'm not gonna have two heart beats in less than 0.9 second
            idx_IBI(count) = jj;
            count = count+1;
        end
    end

    proof = find(diff(idx_IBI)<10); % to prove if the solution is relatable
    %sometimes there will be more than around 300 samples in eanch five
    %minutes epochs, this is due to the presence of more sys_feet in that
    %segment, since each sample is referred to a systolic feet
    idx_IBI(proof+1) = []; % Just to be sure


    for ff = 1:length(idx_IBI)-1
        PpgProcessing(ii).IBI_PCA(ff) =  mean(PpgProcessing(ii).IBI(idx_IBI(ff):idx_IBI(ff+1)));
    end
    nights(ii).IBI_PCA = PpgProcessing(ii).IBI_PCA; % just to have a copy directly in nights
    % I can see that between the data that will go through the pca there is
    % a minimum difference, idk if it's an error and i have to solve it or
    % if i can just resample



    waitbar(ii/length(nights), f, sprintf('PPG processing progress: %d %%', floor(ii/length(nights)*100)));

    if nargin == 3 && plot_flag==1
        %% Plot Systolic Feet
        %Plot Systolic Feet
        Feet = NaN(length(PpgProcessing(ii).PPG),1);
        Feet(idx_systolic_feet) = -sys_feet;
        figure
        plot(PpgProcessing(ii).t_PPG_datetime,PpgProcessing(ii).PPG,PpgProcessing(ii).t_PPG_datetime,Feet,'r*')
        title(strcat(nights(ii).date),'FontSize',20);
        xline(nights(ii).tags,'r',LineWidth=2)
        xlabel("Time")
        ylabel("Amplitude");
        legend("PPG","Systolic Feet Position")



        % % % Plot IBI in datetime
        % % figure
        % % plot(PpgProcessing(ii).time_vector_IBI,PpgProcessing(ii).IBI)

        %Plot IBI in seconds
        % figure
        % plot(PpgProcessing(ii).time_vector_IBI,PpgProcessing(ii).IBI)

    end
end

delete(f);


end