function [PCAcoeff, PCAscore, PCAlatent, PCAexplained, Variance_percentage] = PCA_analysis(nights, EdaProcessing, PpgProcessing, minVar)



%% PCA

nights(1).SleepQuality = 4;
nights(2).SleepQuality = 3;
nights(3).SleepQuality = 3;
nights(4).SleepQuality = 3;
nights(5).SleepQuality = 2;
nights(6).SleepQuality = 4;
nights(7).SleepQuality = 4;
nights(8).SleepQuality = 3;
nights(9).SleepQuality = 3;

    PCA_features_evolution_between_nights = [];
    for ii=1:length(nights)
        nights(ii).IBI_PCA = resize(nights(ii).IBI_PCA,length(nights(ii).SleepAwakeBinary_PCA));

        

         % EDA data
     % nights(ii).AvgStormSizePCA = ones(length(nights(ii).IBI_PCA),1)*EdaProcessing(ii).AvgStormSize;
     % nights(ii).StdStormSizePCA = ones(length(nights(ii).IBI_PCA),1)*EdaProcessing(ii).StdStormSize;
     % nights(ii).LargestStorm = ones(length(nights(ii).IBI_PCA),1)*EdaProcessing(ii).LargestStorm;

     % nights(ii).X = [nights(ii).IBI_PCA' nights(ii).AvgStormSizePCA nights(ii).StdStormSizePCA nights(ii).LargestStorm ones(length(nights(ii).SleepAwakeBinary_PCA),1)*nights(ii).countdown ones(length(nights(ii).SleepAwakeBinary_PCA),1)*nights(ii).SE];
     % nights(ii).X = nights(ii).X-mean(nights(ii).X);
     % [nights(ii).PCAcoeff, nights(ii).PCAscore, nights(ii).PCAlatent, ~, nights(ii).PCAexplained] = pca(nights(ii).X);

     % I think the PCA won't work due to the presence of constant values vectors and binary vectors
     PCA_features_evolution_between_nights = [PCA_features_evolution_between_nights;  ...
         EdaProcessing(ii).AvgStormSize EdaProcessing(ii).StdStormSize EdaProcessing(ii).LargestStorm nights(ii).SE ...
         PpgProcessing(ii).SDNN PpgProcessing(ii).RMSD PpgProcessing(ii).meanHR nights(ii).SleepQuality nights(ii).countdown];
     

    end

    PCA_features_evolution_between_nights = PCA_features_evolution_between_nights - mean(PCA_features_evolution_between_nights);
    [PCAcoeff, PCAscore, PCAlatent, ~, PCAexplained] = pca(PCA_features_evolution_between_nights);


    N_variance_percentage = length(find(PCAexplained>minVar)); % To find only the PCA that explains at least the 0.05% of the variance
    Variance_percentage = sum(PCAexplained(PCAexplained>minVar));
    
    x1 = [];
    for idx=1:N_variance_percentage
        x1 = [x1; strcat("PC",num2str(idx))];
    end

    figure
    barplot1 = bar(x1,PCAexplained(1:N_variance_percentage));
    title("Amount of total variance explained by each PC")
    xtips1 = barplot1.XEndPoints;
    ytips1 = barplot1.YEndPoints;
    labels1 = strcat(string(barplot1.YData),'%');
    text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
        'VerticalAlignment','bottom',FontSize=12)
    ylim([0 100])


    x2 = ["AvgStormSize" "StdStormSize" "LargestStorm" "SE" ...
        "SDNN" "RMSD" "meanHR" "SleepQuality" "countdown"];
    for ii=1:N_variance_percentage
        figure
        barplot2 = bar(x2,PCAcoeff(:,ii).^2*100);
        title(strcat("Contribution of each variable for PC",num2str(ii),' (',num2str(PCAexplained(ii)),'% of the total variance)'));

        xtips2 = barplot2.XEndPoints;
        ytips2 = barplot2.YEndPoints;
        labels2 = strcat(string(barplot2.YData),'%');
        text(xtips2,ytips2,labels2,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom',FontSize=12)
        ylim([0 100])
    end

end