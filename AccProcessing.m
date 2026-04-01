function [AccProcessing, nights] = AccProcessing(fs_ACC,raw_data,n_subfolder,nights,plot_flag)


%% Sleep Analysis Accellerometers
f = waitbar(0, 'Starting ACC angle computing');
for ii = 1:n_subfolder
    AccProcessing(ii).Median = movmedian(raw_data(ii).ACC,fs_ACC*5);
    % I would like to detect the right acc_z, in order to do that i can
    % look at the medians and check which is closer to one, at least
    % at the start
    idx = 1:3;
    [~, which_is_z] = min(abs(abs(AccProcessing(ii).Median(1,:))-1));
    idx(idx==which_is_z) = [];
    acc_z = AccProcessing(ii).Median(:,which_is_z);
    acc_x = AccProcessing(ii).Median(:,idx(1)); % 1 and 2 do not represent anything they are just the indexes of the non-z axisses
    acc_y = AccProcessing(ii).Median(:,idx(2));

    AccProcessing(ii).Angle = 180/pi * atan(acc_z./(acc_x.^2+acc_y.^2));


    waitbar(ii/n_subfolder, f, sprintf('Computing ACC angle progress: %d %%', floor(ii/n_subfolder*100)));
end

delete(f)
%% Still sleep Acc processing

epoch_duration_in_samples = fs_ACC*5;

f = waitbar(0, 'Starting ACC processing');
for ii = 1 : n_subfolder
    
    num_epochs = floor(length(AccProcessing(ii).Angle)/epoch_duration_in_samples);
    for jj = 1:num_epochs-1
        AccProcessing(ii).AngleAvg(jj) = mean(AccProcessing(ii).Angle((jj-1)*epoch_duration_in_samples+1:jj*epoch_duration_in_samples));
    end
    % In this way i'm not considering the last part of the
    % AccProcessing.Angle since it's not a full epoch, since it's less
    % than 5 seconds i'would just not consider it
    AccProcessing(ii).t_resampled = raw_data(ii).t_ACC_datetime(fs_ACC*5:fs_ACC*5:end);
    % i start from AccProcessing(ii).fs*5 since the first value will be
    % refered to the first five second
    if length(AccProcessing(ii).AngleAvg) ~= length(AccProcessing(ii).t_resampled)
        AccProcessing(ii).t_resampled(end) = []; % Sometimes idk why there's an extra sample
    end

    % Now I'm starting to see sleep/awake time (1=sleep, 0=awake)
    % I see the cumulative difference in a 5 minutes period of time to
    % set a 1 or 0

    seconds_per_sample = 5;
    angle_threshold = 5;
    bout_duration = (5*60)/seconds_per_sample; %it will be equal to 60, meaning that i'll have 5 minutes in 60 samples of AngleAvg
    num_fiveminepochs = floor(length(AccProcessing(ii).AngleAvg)/bout_duration);
    AccProcessing(ii).inactivity_bouts = cell(num_fiveminepochs,2); %2 cause i'd like to insert the time lapse which is refering to


    for kk = 1:num_fiveminepochs  % Since each sample
        if length(find(abs( diff(AccProcessing(ii).AngleAvg((kk-1)*60+1:kk*60))) > 5)) < 1
            % I want to find at least a change of at least 5 degree in % a 5 minutes period of time
            AccProcessing(ii).inactivity_bouts{kk,1} = 1;
        else
            AccProcessing(ii).inactivity_bouts{kk,1} = 0;
        end
        AccProcessing(ii).inactivity_bouts{kk,2} = AccProcessing(ii).t_resampled(bout_duration*kk);
    end
waitbar(ii/n_subfolder, f, sprintf('ACC processing progress: %d %%', floor(ii/n_subfolder*100)));

end
delete(f)


%% Computing sleep time ecc and updating nights

for ii=1:2

    for jj = 1:length(AccProcessing(ii).inactivity_bouts)
        timetocheck = AccProcessing(ii).inactivity_bouts{jj,2};
        if timetocheck>nights(ii).tags(1)
            break;
        end
    end

    for kk =length(AccProcessing(ii+1).inactivity_bouts):-1:1
        timetocheck = AccProcessing(ii+1).inactivity_bouts{kk,2};
        if timetocheck<nights(ii).tags(end)
            break;
        end
    end

    total_bed_time = (length(AccProcessing(ii).inactivity_bouts)-jj+kk)*5; %*5 to obtain the total amount of bed time in minutes, jj and kk are the epochs
    % I can also check if the total_bed_time is similar to the signed time with tags
    sleep_timepre = length(find(cell2mat(AccProcessing(ii).inactivity_bouts(jj:end,1)) == 1))*5;
    sleep_timepost = length(find(cell2mat(AccProcessing(ii+1).inactivity_bouts(1:kk-1,1)) == 1))*5;
    sleep_time = sleep_timepre + sleep_timepost; %in this way i obtain sleep time
    nights(ii).SleepInfoMinutes.TotalBedTime = total_bed_time;
    nights(ii).SleepInfoMinutes.SleepTime = sleep_time;
    nights(ii).SleepInfoMinutes.AwakeTime = total_bed_time-sleep_time;

    %% Sleep Efficiency SE
    nights(ii).SE = nights(ii).SleepInfoMinutes.SleepTime/nights(ii).SleepInfoMinutes.TotalBedTime;
    %% Sleep Awake Binary status
    nights(ii).SleepAwakeBinary_PCA = [AccProcessing(ii).inactivity_bouts(jj:end,:); AccProcessing(ii+1).inactivity_bouts(1:kk-1,:)];
end

for ii=4:n_subfolder-1

    for jj = 1:length(AccProcessing(ii).inactivity_bouts)
        timetocheck = AccProcessing(ii).inactivity_bouts{jj,2};
        if timetocheck>nights(ii-1).tags(1) %% i-1 cause in nights the 3 nights corrispond to AccProccessing(4:5)
            break;
        end
    end

    for kk =length(AccProcessing(ii+1).inactivity_bouts):-1:1
        timetocheck = AccProcessing(ii+1).inactivity_bouts{kk,2};
        if timetocheck<nights(ii-1).tags(end)
            break;
        end
    end

    total_bed_time = (length(AccProcessing(ii).inactivity_bouts)-jj+kk)*5; %*5 to obtain the total amount of bed time in minutes, jj and kk are the epochs
    % I can also check if the total_bed_time is similar to the signed time with tags
    sleep_timepre = length(find(cell2mat(AccProcessing(ii).inactivity_bouts(jj:end,1)) == 1))*5;
    sleep_timepost = length(find(cell2mat(AccProcessing(ii+1).inactivity_bouts(1:kk-1,1)) == 1))*5;
    sleep_time = sleep_timepre + sleep_timepost; %in this way i obtain sleep time
    nights(ii-1).SleepInfoMinutes.TotalBedTime = total_bed_time;
    nights(ii-1).SleepInfoMinutes.SleepTime = sleep_time;
    nights(ii-1).SleepInfoMinutes.AwakeTime = total_bed_time-sleep_time;

    %% Sleep Efficiency SE
    nights(ii-1).SE = nights(ii-1).SleepInfoMinutes.SleepTime/nights(ii-1).SleepInfoMinutes.TotalBedTime;
    %% Sleep Awake Binary status
    nights(ii-1).SleepAwakeBinary_PCA = [AccProcessing(ii).inactivity_bouts(jj:end,:); AccProcessing(ii+1).inactivity_bouts(1:kk-1,:)];

end

if nargin==5 && plot_flag==1
    %% Plot accellerazioni giornaliere
    for ii=1:2
        figure
        m = max([AccProcessing(ii).AngleAvg AccProcessing(ii+1).AngleAvg]);
        plot([AccProcessing(ii).t_resampled; AccProcessing(ii+1).t_resampled], [AccProcessing(ii).AngleAvg AccProcessing(ii+1).AngleAvg]./m)
        hold on
        plot([AccProcessing(ii).inactivity_bouts{:,2} AccProcessing(ii+1).inactivity_bouts{:,2}],[AccProcessing(ii).inactivity_bouts{:,1} AccProcessing(ii+1).inactivity_bouts{:,1}],'.',LineWidth=4)
        xline(nights(ii).tags,'r',LineWidth=2)
        title(strcat(nights(ii).date),'FontSize',20);
        xlabel("Time")
        ylabel("Max Normalized Average angle [°]")
        legend("Average Angle","Sleep/Awake Staturs")

    end

    for ii=4:n_subfolder-1
        figure
        m = max([AccProcessing(ii).AngleAvg AccProcessing(ii+1).AngleAvg]);
        plot([AccProcessing(ii).t_resampled; AccProcessing(ii+1).t_resampled], [AccProcessing(ii).AngleAvg AccProcessing(ii+1).AngleAvg]./m)
        hold on
        plot([AccProcessing(ii).inactivity_bouts{:,2} AccProcessing(ii+1).inactivity_bouts{:,2}],[AccProcessing(ii).inactivity_bouts{:,1} AccProcessing(ii+1).inactivity_bouts{:,1}],'.',LineWidth=4)
        xline(nights(ii-1).tags,'r',LineWidth=2)
        title(strcat(nights(ii-1).date),'FontSize',20);
        xlabel("Time")
        ylabel("Max Normalized Average angle [°]")
        legend("Average Angle","Sleep/Awake Staturs")

    end
end

end