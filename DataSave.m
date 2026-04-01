function [raw_data, n_subfolder, fs_ACC, fs_PPG, fs_EDA   ] = DataSave(main_folder)


k = dir(main_folder);
k(1:1:2,:) = [];
n_subfolder = length(k);

folder = k(1).folder; % to get the folder



for ii = 1:n_subfolder
    %% caricamento dati in raw_data
    date = k(ii).name;
    data = strcat(main_folder,"\",date,"\00014-3YK3M161DK","\raw_data","\raw_data_matlab","\data.mat");
    raw_data(ii) = load(data);
    raw_data(ii).start = raw_data(ii).start/1e6;
    raw_data(ii).tags = sort(datetime(raw_data(ii).tags/1e6,'convertFrom','posixtime','timezone','Europe/Rome'),1,"ascend");

end

%% Explaining why i used /1e6

%%% I need to use two different for otherwhise i was loading a 1 x 13 in a 1 x (13+3)

%%% In order to use datetime i have first to convert raw_data(ii).start in
%%% a way i didn't understand but i verified it's true 1732727824257140
%%% ---> 1.732727824257140e9 => /1e6


%tags = raw_data.tags; % i store them into a vector just cause it's easier to me

 %% Fixing the tags (OLD)
raw_data(1).tags = [datetime(2024,11,27, 23, 30, 00,'TimeZone','Europe/Rome')];
raw_data(2).tags = [datetime(2024,11,28, 08, 18, 00,'TimeZone','Europe/Rome'); datetime(2024,11,28, 21, 00, 00,'TimeZone','Europe/Rome')];
raw_data(3).tags = [datetime(2024,11,29, 08, 26, 00,'TimeZone','Europe/Rome')];


raw_data(2).tags(2) = datetime(2024,11,29, 02, 30, 00,'TimeZone','Europe/Rome');



raw_data(8).tags(2) = datetime(2024,12,07, 02, 10, 00,'TimeZone','Europe/Rome');


raw_data(9).tags = [raw_data(9).tags; datetime(2024,12,08, 00, 20, 00,'TimeZone','Europe/Rome')];


raw_data(10).tags(2) = datetime(2024,12,09, 02, 18, 30,'TimeZone','Europe/Rome');


raw_data(12).tags(2) = datetime(2024,12,11, 02, 08, 00,'TimeZone','Europe/Rome');



% 
% raw_data(15).tags = raw_data(15).tags([1 4]);
% 
% 
% raw_data(17).tags = [raw_data(17).tags(end); datetime(2024,12,16, 00, 20, 00,'TimeZone','Europe/Rome')]; %just a guess, then check through plot
% 
% 
% raw_data(18).tags = [datetime(2024,11,16, 08, 18, 00,'TimeZone','Europe/Rome'); datetime(2024,11,16, 21, 00, 00,'TimeZone','Europe/Rome')]; %like the one before
% 
% raw_data(end).tags(end)= [];

   



%% Fixing the tags (NEW: After deleting the first nights due to unpresence or data curruptance)


%raw_data(4).tags = [raw_data(4).tags; datetime(2024,12,08, 00, 20, 00,'TimeZone','Europe/Rome');];
fs_ACC = double(raw_data(1).fs_ACC);
fs_PPG = double(raw_data(1).fs_PPG);
%fs_EDA = double(raw_data(1).fs_EDA);
fs_EDA = 4;

for ii = 1:n_subfolder
    %% asse x
    start_datetime = datetime(raw_data(ii).start,'convertFrom','posixtime','timezone','Europe/Rome');

    %%%% ACC
    t_ACC = (0:length(raw_data(ii).ACC)-1)/fs_ACC;
    raw_data(ii).t_ACC_datetime = (start_datetime + seconds(t_ACC))';

    %%%% PPG
    t_PPG = (0:length(raw_data(ii).PPG)-1)/fs_PPG;
    raw_data(ii).t_PPG_datetime = (start_datetime + seconds(t_PPG))';

    %%%% EDA
    t_EDA = (0:length(raw_data(ii).EDA)-1)/fs_EDA;
    raw_data(ii).t_EDA_datetime = (start_datetime + seconds(t_EDA))';

    raw_data(ii).date = k(ii).name; % Just to have a simplier way to visualize the data
    raw_data(ii).countup = ii;




end
    %% Deleting acquisition when i wasn't at home
    raw_data(4:5) = [];
    n_subfolder = length(raw_data); % Also updating raw_data length


end