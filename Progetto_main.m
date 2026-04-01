clear all
close all
clc


% Set to 1 to visualize the plots relative to the analysis
plotACC_flag = 0;
plotPPG_flag = 0;
plotEDA_flag = 0;
% Set the minimun variance described by each principal component
min_PCAvariance = 1;
FIRfilter = "FIRfilter.mat";

%% Select the folder to analyze
% Run the code and select the folder to analyze - AlessandroCardia_Empatica1 -
main_folder = uigetdir();

[raw_data, n_subfolder, fs_ACC, fs_PPG, fs_EDA] = DataSave(main_folder);
[nights] = NightsAssembling(raw_data,n_subfolder);
[AccProcessing, nights] = AccProcessing(fs_ACC,raw_data,n_subfolder,nights,plotACC_flag);
[PpgProcessing, nights] = PPGProcessing(fs_PPG, nights, plotPPG_flag);
[EdaProcessing] = EDAProcessing(fs_EDA, raw_data, nights, FIRfilter, plotEDA_flag);
[PCAcoeff, PCAscore, PCAlatent, PCAexplained, Variance_Percentage] = PCA_analysis(nights, EdaProcessing, PpgProcessing, min_PCAvariance);
