function [EdaProcessing] = EDAProcessing(fs_EDA, raw_data, nights, FIRfilter, plot_flag)


     EDA_info = struct();
 for ii = 1:length(raw_data)
        EDA_info(ii).data = raw_data(ii).EDA;
        EDA_info(ii).t = (0:length(EDA_info(ii).data)-1)/fs_EDA;
        EDA_info(ii).t_datetime = raw_data(ii).t_EDA_datetime;
 end

 for ii = 1:2



    EdaProcessing(ii).EDA = [EDA_info(ii).data; EDA_info(ii+1).data];
    EdaProcessing(ii).t = [EDA_info(ii).t EDA_info(ii+1).t];
    EdaProcessing(ii).t_datetime = [EDA_info(ii).t_datetime; EDA_info(ii+1).t_datetime];

    idx_start = find(EdaProcessing(ii).t_datetime >= nights(ii).tags(1),1,"first");
    idx_stop = find(EdaProcessing(ii).t_datetime <= nights(ii).tags(2),1,"last");

    EdaProcessing(ii).EDA = EdaProcessing(ii).EDA(idx_start:idx_stop);
    EdaProcessing(ii).t = EdaProcessing(ii).t(idx_start:idx_stop);
    EdaProcessing(ii).t_datetime = EdaProcessing(ii).t_datetime(idx_start:idx_stop);

 end

  for ii = 4:length(EDA_info)-1

    EdaProcessing(ii-1).EDA = [EDA_info(ii).data; EDA_info(ii+1).data];
    EdaProcessing(ii-1).t = [EDA_info(ii).t EDA_info(ii+1).t];
    EdaProcessing(ii-1).t_datetime = [EDA_info(ii).t_datetime; EDA_info(ii+1).t_datetime];

    idx_start = find(EdaProcessing(ii-1).t_datetime >= nights(ii-1).tags(1),1,"first");
    idx_stop = find(EdaProcessing(ii-1).t_datetime <= nights(ii-1).tags(2),1,"last");

    EdaProcessing(ii-1).EDA = EdaProcessing(ii-1).EDA(idx_start:idx_stop);
    EdaProcessing(ii-1).t = EdaProcessing(ii-1).t(idx_start:idx_stop);
    EdaProcessing(ii-1).t_datetime = EdaProcessing(ii-1).t_datetime(idx_start:idx_stop);

 end


    f = waitbar(0, 'Starting EDA processing');

 for ii = 1:length(EdaProcessing)

     load(FIRfilter);
     EdaProcessing(ii).EDAfiltered = filtfilt(b,1,EdaProcessing(ii).EDA);
    
     % for pp = 1:10000:length(EdaProcessing(ii).EDAfiltered) %%% Segmenting part to allow the total elaboration of the signal in cvxEDA
     % 
     %     if pp+10000<length(EdaProcessing(ii).EDAfiltered)
     %         [EdaProcessing(ii).phasic(pp:pp+10000-1), ~, EdaProcessing(ii).tonic(pp:pp+10000-1)] = cvxEDA(EdaProcessing(ii).EDAfiltered(pp:pp+10000-1), 1/fs_EDA);
     %     else
     %         [EdaProcessing(ii).phasic(pp:length(EdaProcessing(ii).EDAfiltered)), ~, EdaProcessing(ii).tonic(pp:length(EdaProcessing(ii).EDAfiltered))] = cvxEDA(EdaProcessing(ii).EDAfiltered(pp:end), 1/fs_EDA);
     %     end
     % end


     %% Finding EDA events and Storms and some plots
     Ts_EDA = 1/fs_EDA;
     EdaProcessing(ii).firstDerivative = gradient(EdaProcessing(ii).EDAfiltered)./Ts_EDA;

     [EdaProcessing(ii).EdaEvent_amplitude,EdaProcessing(ii).EdaEvent_location] = findpeaks(EdaProcessing(ii).firstDerivative,MinPeakHeight=0.01);


     Epoch_end = EdaProcessing(ii).EdaEvent_location(1)+120;
     last_EDA_event = EdaProcessing(ii).EdaEvent_location(find(EdaProcessing(ii).EdaEvent_location < EdaProcessing(ii).EdaEvent_location(1)+120,1,'last'));
     EdaProcessing(ii).Epoch_idx(1) = {[EdaProcessing(ii).EdaEvent_location(1); Epoch_end; last_EDA_event]};
     counter = 2;
     for rr=2:length(EdaProcessing(ii).EdaEvent_location)
         if EdaProcessing(ii).EdaEvent_location(rr) > Epoch_end
             Epoch_end =  EdaProcessing(ii).EdaEvent_location(rr)+120;
             %120 cause it's equal to 30 s at 4Hz
             last_EDA_event = EdaProcessing(ii).EdaEvent_location(find(EdaProcessing(ii).EdaEvent_location < EdaProcessing(ii).EdaEvent_location(rr)+120,1,'last'));
             %i save the last EDA event in a storm to see the distance
             %between it and the next EDA event, to know if i can consider
             %it
             EdaProcessing(ii).Epoch_idx(counter,1) = {[EdaProcessing(ii).EdaEvent_location(rr); Epoch_end; last_EDA_event]};
             counter = counter+1;
         end
     end


     

     counter = 1;
     rr = 1;

     tic
     while rr<length(EdaProcessing(ii).Epoch_idx)

         kk = 1;
         while (EdaProcessing(ii).Epoch_idx{rr+kk}(1)-EdaProcessing(ii).Epoch_idx{rr+kk-1}(3)<120) && rr+kk<length(EdaProcessing(ii).Epoch_idx)
             kk = kk+1;
         end
         if kk >= 2 && (rr+kk < length(EdaProcessing(ii).Epoch_idx))
             n_epochs = kk;
             EdaProcessing(ii).Storm_idx(counter,1) = {[EdaProcessing(ii).Epoch_idx{rr}(1); EdaProcessing(ii).Epoch_idx{rr+kk+1}(2); n_epochs]};
             counter = counter+1;
         elseif kk >= 2 && (rr+kk == length(EdaProcessing(ii).Epoch_idx))
                 n_epochs = kk+1;
                 EdaProcessing(ii).Storm_idx(counter,1) = {[EdaProcessing(ii).Epoch_idx{rr}(1); EdaProcessing(ii).Epoch_idx{rr+kk}(2); n_epochs]};
                 counter = counter+1;
         end
         rr = rr+kk;

         end
         toc



     for rr=1:length(EdaProcessing(ii).Storm_idx)
         StormSize (rr) = EdaProcessing(ii).Storm_idx{rr}(3); %number of epochs in each detected storm
     end
     EdaProcessing(ii).AvgStormSize = sum(StormSize)/length(EdaProcessing(ii).Storm_idx);
     EdaProcessing(ii).StdStormSize = std(StormSize);
     EdaProcessing(ii).LargestStorm = max(StormSize);



if nargin == 5 && plot_flag==1

     figure
     EdaPeaks = NaN(length(EdaProcessing(ii).firstDerivative),1);
     EdaPeaks(EdaProcessing(ii).EdaEvent_location) = EdaProcessing(ii).EdaEvent_amplitude;
     plot(EdaProcessing(ii).t_datetime, EdaProcessing(ii).firstDerivative,EdaProcessing(ii).t_datetime, EdaPeaks,'r*');
     title(strcat('Filtered EDA Derivative-',strcat(nights(ii).date)))
     yline(0.01)
     ylim([0 max(EdaProcessing(ii).firstDerivative)])
     xlabel("Time")
     ylabel("Amplitude [\muSiemens/s]");
     legend("Filtered Eda Derivative","EDA events")

end

     waitbar(ii/length(EdaProcessing), f, sprintf('EDA processing progress: %d %%', floor(ii/length(EdaProcessing)*100)));
 end

  delete(f);
end