function [nights] = NightsAssembling(raw_data,n_subfolder)


f = waitbar(0, 'Starting nights assembling');

%% Assembling the first two nights
for ii=1:2
    nights(ii).date = strcat(raw_data(ii).date(9:10), '/', raw_data(ii+1).date(9:10));
    nights(ii).ACC = [raw_data(ii).ACC; raw_data(ii+1).ACC];
    nights(ii).PPG = [raw_data(ii).PPG; raw_data(ii+1).PPG];
    nights(ii).EDA = [raw_data(ii).EDA; raw_data(ii+1).EDA];
    nights(ii).t_ACC_datetime = [raw_data(ii).t_ACC_datetime; raw_data(ii+1).t_ACC_datetime];
    nights(ii).t_PPG_datetime = [raw_data(ii).t_PPG_datetime; raw_data(ii+1).t_PPG_datetime];
    nights(ii).t_EDA_datetime = [raw_data(ii).t_EDA_datetime; raw_data(ii+1).t_EDA_datetime];
    nights(ii).tags = [raw_data(ii).tags(end), raw_data(ii+1).tags(1)];
    nights(ii).countdown = raw_data(ii).countup;
    %nights(ii).sleep_time = length(find(AccProcessing(ii).inactivity_bouts(:,2)>nights(ii).tags(end)))
    %the line above doesn't work, i think i'll have to start a counter and
    %then calculate total time,sleep time and awake time

    waitbar(ii/(n_subfolder-2), f, sprintf('Nights assembling progress: %d %%', floor(ii/(n_subfolder-2)*100)));

end
%% Assembling the from the fifth night to the last
for ii=3:n_subfolder-2 % ii starting from 3 to match nights indexing, -2 to match the nights i deleted
    nights(ii).date = strcat(raw_data(ii+1).date(9:10), '/', raw_data(ii+2).date(9:10)); % 9:10 to get the day from the date
    nights(ii).ACC = [raw_data(ii+1).ACC; raw_data(ii+2).ACC]; % ii+1 ii+2 to match raw_data indexing
    nights(ii).PPG = [raw_data(ii+1).PPG; raw_data(ii+2).PPG];
    nights(ii).EDA = [raw_data(ii+1).EDA; raw_data(ii+2).EDA];
    nights(ii).t_ACC_datetime = [raw_data(ii+1).t_ACC_datetime; raw_data(ii+2).t_ACC_datetime];
    nights(ii).t_PPG_datetime = [raw_data(ii+1).t_PPG_datetime; raw_data(ii+2).t_PPG_datetime];
    nights(ii).t_EDA_datetime = [raw_data(ii+1).t_EDA_datetime; raw_data(ii+2).t_EDA_datetime];
    nights(ii).tags = [raw_data(ii+1).tags(end), raw_data(ii+2).tags(1)];
    nights(ii).countdown = raw_data(ii+1).countup;

    waitbar(ii/(n_subfolder-2), f, sprintf('Nights assembling progress: %d %%', floor(ii/(n_subfolder-2)*100)));
end

delete(f);
end