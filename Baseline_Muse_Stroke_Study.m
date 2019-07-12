%%

%%%trigger info%%%
%%%Baseline%%%
% % 1 = first button press/tones
% % 2 = start of first block
% % 3 = end of first block
% % 4 = second button press/tones
% % 5 = start of second block
% % 6 = end of second block
% % 7 = end of experiment

clearvars
close all
clc

%%%%here we will specify our participants, conditions, and electrodes
parts = {'001';'002';'003'};
electrodes = {'TP9';'AF7';'AF8';'TP10';'AUX'};%AUX will be used for EKG

n_chans = length(electrodes);

conds = {'eyes_open';'eyes_closed'};
n_trigs = 2;

%%%ERP information
baseline = 51; %in samples, 51 is about 200 ms
epoch_eeg = 48640; %in samples, 256 is about 1 second
epoch_acc = 9880; %in samples, 52 is about 1 second
epoch_gyro = 9880; %in samples, 52 is about 1 second

%%%filter information
threshold = 50; %absolute uV away from baseline
high_pass = 0.1; %lower cutoff
low_pass = 60; %upper cutoff
order = 4; %order of polynomial used in the filter, can be increased to sharpen the dropoff of the filter
type = 'band'; %type of filter

%%%file path and name information
datapath = ['M:\Data\Muse_Stroke_Study\Baseline\'];
% % datapath = ['M:\Data\Muse_Stroke_Study\Pilot\Baseline\'];

%%%variables for EEG%%%
eyes_open_part_all_chan_eeg = NaN(length(1:.5:60),epoch_eeg, n_chans, length(parts));
eyes_closed_part_all_chan_eeg = NaN(length(1:.5:60),epoch_eeg, n_chans, length(parts));

eyes_open_part_combined_eeg = NaN(length(1:.5:60),epoch_eeg, 3, length(parts));
eyes_closed_part_combined_eeg = NaN(length(1:.5:60),epoch_eeg, 3, length(parts));

avg_eyes_open_all_chan_eeg = NaN(length(1:.5:60), n_chans, length(parts));
avg_eyes_closed_all_chan_eeg = NaN(length(1:.5:60), n_chans, length(parts));

avg_eyes_open_combined_eeg = NaN(length(1:.5:60), 3, length(parts));
avg_eyes_closed_combined_eeg = NaN(length(1:.5:60), 3, length(parts));

%%%variables for ACC%%%
eyes_open_part_all_chan_acc = NaN(epoch_acc, 3, length(parts));
eyes_closed_part_all_chan_acc = NaN(epoch_acc, 3, length(parts));
eyes_open_part_all_chan_acc_rms = NaN(3, length(parts));
eyes_closed_part_all_chan_acc_rms = NaN(3, length(parts));
eyes_open_part_all_chan_acc_sd = NaN(3, length(parts));
eyes_closed_part_all_chan_acc_sd = NaN(3, length(parts));
eyes_open_part_all_chan_acc_var = NaN(3, length(parts));
eyes_closed_part_all_chan_acc_var = NaN(3, length(parts));

%%%variables for GYRO%%%
eyes_open_part_all_chan_gyro = NaN(epoch_gyro, 3, length(parts));
eyes_closed_part_all_chan_gyro = NaN(epoch_gyro, 3, length(parts));
eyes_open_part_all_chan_gyro_rms = NaN(3, length(parts));
eyes_closed_part_all_chan_gyro_rms = NaN(3, length(parts));
eyes_open_part_all_chan_gyro_sd = NaN(3, length(parts));
eyes_closed_part_all_chan_gyro_sd = NaN(3, length(parts));
eyes_open_part_all_chan_gyro_var = NaN(3, length(parts));
eyes_closed_part_all_chan_gyro_var = NaN(3, length(parts));

%%
for i_part = 1:length(parts)
    
    disp(['Processing data for participant ' parts{i_part} ' and experiment Baseline']);
    
    %%%get the filename for each device, condition, and participant
    filename_eeg = [parts{i_part} '_EEG_baseline_stroke_study_updated.csv'];
    filename_acc = [parts{i_part} '_ACC_baseline_stroke_study_updated.csv'];
    filename_gyro = [parts{i_part} '_GYRO_baseline_stroke_study_updated.csv'];
    
    %%%import our data file
    %%%these files are organised the following way:
    %%%Column 1 = TP9
    %%%Column 2 = AF7
    %%%Column 3 = AF8
    %%%Column 4 = TP10
    %%%Column 5 = AUX
    temp_eeg_data = importfile_lsl([datapath filename_eeg]);
    temp_acc_data = importfile_lsl([datapath filename_acc]);
    temp_gyro_data = importfile_lsl([datapath filename_gyro]);
    
    eeg_data = temp_eeg_data(:,2:6);
    ekg_data = temp_eeg_data(:,6);
    acc_data = temp_acc_data(:,2:4);
    gyro_data = temp_gyro_data(:,2:4);
    
    markers_eeg = temp_eeg_data(:,7);
    markers_acc = temp_acc_data(:,5);
    markers_gyro = temp_gyro_data(:,5);
    
    times_eeg = temp_eeg_data(:,1);
    times_acc = temp_acc_data(:,1);
    times_gyro = temp_gyro_data(:,1);
    
    %%%process eeg data%%%
    for i_chan = 1:n_chans
        disp(['Processing data for channel ' electrodes{i_chan}]);
        
        %%%now extract our EEG data%%%
        eeg_data_chan = eeg_data(:,i_chan) - nanmean(eeg_data(:,i_chan));
        
        %%%info for BOSC%%%
        period = median(diff(times_eeg));
        srate = 1/period;
        timepoints = period:period:length(times_eeg)*period;
        timepointm = timepoints/60;
        F = 1:.5:60;
        wavenum = 10;
        [bosc_eeg_data_chan] = log(BOSC_tf(eeg_data_chan,F,srate,wavenum));
        
        %%%get marker positions%%%
        eyes_open_eeg_start = find(markers_eeg == 2);
        eyes_open_eeg_end = find(markers_eeg == 3);
        eyes_closed_eeg_start = find(markers_eeg == 5);
        eyes_closed_eeg_end = find(markers_eeg == 6);
        
        %%%save eyes open and closed segments%%%
        eyes_open_part_all_chan_eeg(:,1:eyes_open_eeg_end-eyes_open_eeg_start+1,i_chan,i_part) = bosc_eeg_data_chan(:,eyes_open_eeg_start:eyes_open_eeg_end);
        eyes_closed_part_all_chan_eeg(:,1:eyes_closed_eeg_end-eyes_closed_eeg_start+1,i_chan,i_part) = bosc_eeg_data_chan(:,eyes_closed_eeg_start:eyes_closed_eeg_end);
        
        %%%average spectra across time%%%
        avg_eyes_open_all_chan_eeg(:,i_chan,i_part) = nanmean(eyes_open_part_all_chan_eeg(:,:,i_chan,i_part),2);
        avg_eyes_closed_all_chan_eeg(:,i_chan,i_part) = nanmean(eyes_closed_part_all_chan_eeg(:,:,i_chan,i_part),2);
        
    end
    
    %%%also average across electrodes%%%
    eyes_open_part_combined_eeg(:,:,1,i_part) = nanmean(eyes_open_part_all_chan_eeg(:,:,[1,4],i_part),3);
    eyes_closed_part_combined_eeg(:,:,1,i_part) = nanmean(eyes_closed_part_all_chan_eeg(:,:,[1,4],i_part),3);
    
    eyes_open_part_combined_eeg(:,:,2,i_part) = nanmean(eyes_open_part_all_chan_eeg(:,:,[2,3],i_part),3);
    eyes_closed_part_combined_eeg(:,:,2,i_part) = nanmean(eyes_closed_part_all_chan_eeg(:,:,[2,3],i_part),3);
    
    eyes_open_part_combined_eeg(:,:,3,i_part) = eyes_open_part_all_chan_eeg(:,:,5,i_part);
    eyes_closed_part_combined_eeg(:,:,3,i_part) = eyes_closed_part_all_chan_eeg(:,:,5,i_part);
    
    avg_eyes_open_combined_eeg(:,1,i_part) = squeeze(nanmean(nanmean(eyes_open_part_all_chan_eeg(:,:,[1,4],i_part),2),3));
    avg_eyes_closed_combined_eeg(:,1,i_part) = squeeze(nanmean(nanmean(eyes_closed_part_all_chan_eeg(:,:,[1,4],i_part),2),3));
    
    avg_eyes_open_combined_eeg(:,2,i_part) = squeeze(nanmean(nanmean(eyes_open_part_all_chan_eeg(:,:,[2,3],i_part),2),3));
    avg_eyes_closed_combined_eeg(:,2,i_part) = squeeze(nanmean(nanmean(eyes_closed_part_all_chan_eeg(:,:,[2,3],i_part),2),3));
    
    avg_eyes_open_combined_eeg(:,3,i_part) = squeeze(nanmean(eyes_open_part_all_chan_eeg(:,:,5,i_part),2));
    avg_eyes_closed_combined_eeg(:,3,i_part) = squeeze(nanmean(eyes_closed_part_all_chan_eeg(:,:,5,i_part),2));
    
    %%%process acc and gryo data%%%
    for i_chan = 1:3
        
        acc_data_chan = acc_data(:,i_chan);
        
        %%%find eyes open markers%%%
        eyes_open_acc_start = find(markers_acc == 2);
        eyes_open_acc_end = find(markers_acc == 3);
        
        %%%find eyes closed markers%%%
        eyes_closed_acc_start = find(markers_acc == 5);
        eyes_closed_acc_end = find(markers_acc == 6);
        
        %%%get our acc epochs%%%
        eyes_open_part_all_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part) = acc_data_chan(eyes_open_acc_start:eyes_open_acc_end, 1);
        eyes_closed_part_all_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part) = acc_data_chan(eyes_closed_acc_start:eyes_closed_acc_end, 1);
        
        %%%determine RMS, SD, and variance for each epoch%%%
        eyes_open_part_all_chan_acc_rms(i_chan,i_part) = rms(eyes_open_part_all_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part));
        eyes_closed_part_all_chan_acc_rms(i_chan,i_part) = rms(eyes_closed_part_all_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part));
        eyes_open_part_all_chan_acc_sd(i_chan,i_part) = std(eyes_open_part_all_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part));
        eyes_closed_part_all_chan_acc_sd(i_chan,i_part) = std(eyes_closed_part_all_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part));
        eyes_open_part_all_chan_acc_var(i_chan,i_part) = var(eyes_open_part_all_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part));
        eyes_closed_part_all_chan_acc_var(i_chan,i_part) = var(eyes_closed_part_all_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part));
        
        gyro_data_chan = gyro_data(:,i_chan);
        
        %%%find eyes open markers%%%
        eyes_open_gyro_start = find(markers_gyro == 2);
        eyes_open_gyro_end = find(markers_gyro == 3);
        
        %%%find eyes closed markers%%%
        eyes_closed_gyro_start = find(markers_gyro == 5);
        eyes_closed_gyro_end = find(markers_gyro == 6);
        
        %%%get our gyro epochs%%%
        eyes_open_part_all_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part) = gyro_data_chan(eyes_open_gyro_start:eyes_open_gyro_end, 1);
        eyes_closed_part_all_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part) = gyro_data_chan(eyes_closed_gyro_start:eyes_closed_gyro_end, 1);
        
        %%%determine RMS, SD, and variance for each epoch%%%
        eyes_open_part_all_chan_gyro_rms(i_chan,i_part) = rms(eyes_open_part_all_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part));
        eyes_closed_part_all_chan_gyro_rms(i_chan,i_part) = rms(eyes_closed_part_all_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part));
        eyes_open_part_all_chan_gyro_sd(i_chan,i_part) = std(eyes_open_part_all_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part));
        eyes_closed_part_all_chan_gyro_sd(i_chan,i_part) = std(eyes_closed_part_all_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part));
        eyes_open_part_all_chan_gyro_var(i_chan,i_part) = var(eyes_open_part_all_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part));
        eyes_closed_part_all_chan_gyro_var(i_chan,i_part) = var(eyes_closed_part_all_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part));
    end
end

%%
%%%Plot spectra for each participant for all electrodes%%%
for i_part = 1:length(parts)
    for i_chan = 1:length(electrodes)
        figure;
        
        %         subplot(3,1,1);
        plot(F,avg_eyes_open_all_chan_eeg(:,i_chan,i_part),F,avg_eyes_closed_all_chan_eeg(:,i_chan,i_part));
        legend('open','closed');
        ylabel('Power (uV^2)');
        xlabel('Frequency (Hz)');
        title(['Averaged spectra for ' parts{i_part} ' and electrode ' electrodes{i_chan}]);
        
        %         subplot(3,1,2);
        %         imagesc(timepointm,F,eyes_open_part_all_chan_eeg(:,:,i_chan,i_part));
        %         set(gca,'Ydir','normal');
        %         xlabel('Time (min)');
        %         ylabel('Frequency (Hz)');
        %         colormap(hot)
        %         title(['Spectra for eyes open at electrode ' electrodes{i_chan}]);
        %
        %         subplot(3,1,3);
        %         imagesc(timepointm,F,eyes_closed_part_all_chan_eeg(:,:,i_chan,i_part));
        %         set(gca,'Ydir','normal');
        %         xlabel('Time (min)');
        %         ylabel('Frequency (Hz)');
        %         title(['Spectra for eyes closed at electrode ' electrodes{i_chan}]);
    end
end

%%
%%%Plot spectra for each participant for combined electrodes%%%
electrodes_comb = {'TP9/TP10';'AF7/AF8';'AUX'};
for i_part = 1:length(parts)
    for i_chan = 1:length(electrodes_comb)
        figure;
        
        subplot(3,1,1);
        plot(F,avg_eyes_open_combined_eeg(:,i_chan,i_part),F,avg_eyes_closed_combined_eeg(:,i_chan,i_part));
        legend('open','closed');
        ylabel('Power (uV^2)');
        xlabel('Frequency (Hz)');
        title(['Averaged spectra for ' parts{i_part} ' and electrode ' electrodes_comb{i_chan}]);
        
        subplot(3,1,2);
        imagesc(timepointm,F,eyes_open_part_all_chan_eeg(:,:,i_chan,i_part));
        set(gca,'Ydir','normal');
        xlabel('Time (min)');
        ylabel('Frequency (Hz)');
        colormap(hot)
        title(['Spectra for eyes open at electrode ' electrodes_comb{i_chan}]);
        
        subplot(3,1,3);
        imagesc(timepointm,F,eyes_closed_part_all_chan_eeg(:,:,i_chan,i_part));
        set(gca,'Ydir','normal');
        xlabel('Time (min)');
        ylabel('Frequency (Hz)');
        title(['Spectra for eyes closed at electrode ' electrodes_comb{i_chan}]);
    end
end

%%
%%%Plot grand-average spectra for all electrodes%%%
for i_chan = 1:length(electrodes)
    figure;
    
    subplot(3,1,1);
    plot(F,nanmean(avg_eyes_open_all_chan_eeg(:,i_chan,:),3),F,nanmean(avg_eyes_closed_all_chan_eeg(:,i_chan,:),3));
    legend('open','closed');
    ylabel('Power (uV^2)');
    xlabel('Frequency (Hz)');
    title(['Grand averaged spectra at electrode ' electrodes{i_chan}]);
    
    subplot(3,1,2);
    imagesc(timepointm,F,nanmean(eyes_open_part_all_chan_eeg(:,:,i_chan,:),4));
    set(gca,'Ydir','normal');
    xlabel('Time (min)');
    ylabel('Frequency (Hz)');
    colormap(hot)
    title(['Spectra for eyes open at electrode ' electrodes{i_chan}]);
    
    subplot(3,1,3);
    imagesc(timepointm,F,nanmean(eyes_closed_part_all_chan_eeg(:,:,i_chan,:),4));
    set(gca,'Ydir','normal');
    xlabel('Time (min)');
    ylabel('Frequency (Hz)');
    title(['Spectra for eyes closed at electrode ' electrodes{i_chan}]);
end

%%
%%%Plot grand-average spectra for combined electrodes%%%
electrodes_comb = {'TP9/TP10';'AF7/AF8';'AUX'};
for i_chan = 1:length(electrodes_comb)
    figure;
    
    subplot(3,1,1);
    plot(F,nanmean(avg_eyes_open_combined_eeg(:,i_chan,:),3),F,nanmean(avg_eyes_closed_combined_eeg(:,i_chan,:),3));
    legend('open','closed');
    ylabel('Power (uV^2)');
    xlabel('Frequency (Hz)');
    title(['Averaged spectra for ' parts{i_part} ' and electrode ' electrodes_comb{i_chan}]);
    
    subplot(3,1,2);
    imagesc(timepointm,F,nanmean(eyes_open_part_all_chan_eeg(:,:,i_chan,:),4));
    set(gca,'Ydir','normal');
    xlabel('Time (min)');
    ylabel('Frequency (Hz)');
    colormap(hot)
    title(['Spectra for eyes open at electrode ' electrodes_comb{i_chan}]);
    
    subplot(3,1,3);
    imagesc(timepointm,F,nanmean(eyes_closed_part_all_chan_eeg(:,:,i_chan,:),4));
    set(gca,'Ydir','normal');
    xlabel('Time (min)');
    ylabel('Frequency (Hz)');
    title(['Spectra for eyes closed at electrode ' electrodes_comb{i_chan}]);
end

%%
%%%Plot ACC data for each participant%%%
for i_part = 1:length(parts)
    figure;
    
    subplot(2,3,1);
    plot(1:length(eyes_open_part_all_chan_acc(:,1,i_part)),eyes_open_part_all_chan_acc(:,1,i_part));
    ylabel('X Coordinates - Eyes Open');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
    
    subplot(2,3,2);
    plot(1:length(eyes_open_part_all_chan_acc(:,2,i_part)),eyes_open_part_all_chan_acc(:,2,i_part));
    ylabel('Y Coordinates - Eyes Open');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
    
    subplot(2,3,3);
    plot(1:length(eyes_open_part_all_chan_acc(:,3,i_part)),eyes_open_part_all_chan_acc(:,3,i_part));
    ylabel('Z Coordinates - Eyes Open');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
    
    subplot(2,3,4);
    plot(1:length(eyes_closed_part_all_chan_acc(:,1,i_part)),eyes_closed_part_all_chan_acc(:,1,i_part));
    ylabel('X Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
    
    subplot(2,3,5);
    plot(1:length(eyes_closed_part_all_chan_acc(:,2,i_part)),eyes_closed_part_all_chan_acc(:,2,i_part));
    ylabel('Y Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
    
    subplot(2,3,6);
    plot(1:length(eyes_closed_part_all_chan_acc(:,3,i_part)),eyes_closed_part_all_chan_acc(:,3,i_part));
    ylabel('Z Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
end


%%
%%%Plot GYRO data for each participant%%%
for i_part = 1:length(parts)
    figure;
    
    subplot(2,3,1);
    plot(1:length(eyes_open_part_all_chan_gyro(:,1,i_part)),eyes_open_part_all_chan_gyro(:,1,i_part));
    ylabel('X Coordinates - Eyes Open');
    xlabel('Sample Point');
    title(['GYRO for Participant ' num2str(i_part)]);
    
    subplot(2,3,2);
    plot(1:length(eyes_open_part_all_chan_gyro(:,2,i_part)),eyes_open_part_all_chan_gyro(:,2,i_part));
    ylabel('Y Coordinates - Eyes Open');
    xlabel('Sample Point');
    title(['GYRO for Participant ' num2str(i_part)]);
    
    subplot(2,3,3);
    plot(1:length(eyes_open_part_all_chan_gyro(:,3,i_part)),eyes_open_part_all_chan_gyro(:,3,i_part));
    ylabel('Z Coordinates - Eyes Open');
    xlabel('Sample Point');
    title(['GYRO for Participant ' num2str(i_part)]);
    
    subplot(2,3,4);
    plot(1:length(eyes_closed_part_all_chan_gyro(:,1,i_part)),eyes_closed_part_all_chan_gyro(:,1,i_part));
    ylabel('X Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['GYRO for Participant ' num2str(i_part)]);
    
    subplot(2,3,5);
    plot(1:length(eyes_closed_part_all_chan_gyro(:,2,i_part)),eyes_closed_part_all_chan_gyro(:,2,i_part));
    ylabel('Y Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['GYRO for Participant ' num2str(i_part)]);
    
    subplot(2,3,6);
    plot(1:length(eyes_closed_part_all_chan_gyro(:,3,i_part)),eyes_closed_part_all_chan_gyro(:,3,i_part));
    ylabel('Z Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['GYRO for Participant ' num2str(i_part)]);
end


%%
%%%Plot ACC RMS, SD, and variance for each participant%%%
figure;
coords = {'X';'Y';'Z'};
for i_chan = 1:3
    
    %%%open%%%
%     subplot(2,3,i_chan);
    subplot(2,3,i_chan,'Position',[0.05+(0.325*(i_chan-1)),0.57,0.295,0.395]);
    bar(eyes_open_part_all_chan_acc_rms(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_open_part_all_chan_acc_rms(i_chan,:)),...
        eyes_open_part_all_chan_acc_rms(i_chan,:),...
        num2str(eyes_open_part_all_chan_acc_rms(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis RMS'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Open ACC','FontSize', 20,'FontWeight', 'bold');
    ylim([0,1.5]);
    
    %%%closed%%%
%     subplot(2,3,i_chan+3);
    subplot(2,3,i_chan+3,'Position',[0.05+(0.325*(i_chan-1)),0.06,0.295,0.395]);
    bar(eyes_closed_part_all_chan_acc_rms(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_closed_part_all_chan_acc_rms(i_chan,:)),...
        eyes_closed_part_all_chan_acc_rms(i_chan,:),...
        num2str(eyes_closed_part_all_chan_acc_rms(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis RMS'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Closed ACC','FontSize', 20,'FontWeight', 'bold');
    ylim([0,1.5]);
    
end

figure;
coords = {'X';'Y';'Z'};
for i_chan = 1:3
    
    %%%open%%%
    subplot(2,3,i_chan,'Position',[0.05+(0.325*(i_chan-1)),0.57,0.295,0.395]);
    bar(eyes_open_part_all_chan_acc_sd(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_open_part_all_chan_acc_sd(i_chan,:)),...
        eyes_open_part_all_chan_acc_sd(i_chan,:),...
        num2str(eyes_open_part_all_chan_acc_sd(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis SD'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Open ACC','FontSize', 24,'FontWeight', 'bold');
    ylim([0,0.1]);
    
    %%%closed%%%
    subplot(2,3,i_chan+3,'Position',[0.05+(0.325*(i_chan-1)),0.06,0.295,0.395]);
    bar(eyes_closed_part_all_chan_acc_sd(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_closed_part_all_chan_acc_sd(i_chan,:)),...
        eyes_closed_part_all_chan_acc_sd(i_chan,:),...
        num2str(eyes_closed_part_all_chan_acc_sd(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis SD'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Closed ACC','FontSize', 24,'FontWeight', 'bold');
    ylim([0,0.1]);
    
end

figure;
coords = {'X';'Y';'Z'};
for i_chan = 1:3
    
    %%%open%%%
    subplot(2,3,i_chan,'Position',[0.05+(0.325*(i_chan-1)),0.57,0.295,0.395]);
    bar(eyes_open_part_all_chan_acc_var(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_open_part_all_chan_acc_var(i_chan,:)),...
        eyes_open_part_all_chan_acc_var(i_chan,:),...
        num2str(eyes_open_part_all_chan_acc_var(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis Variance'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Open ACC','FontSize', 24,'FontWeight', 'bold');
    ylim([0,0.005]);
    
    %%%closed%%%
    subplot(2,3,i_chan+3,'Position',[0.05+(0.325*(i_chan-1)),0.06,0.295,0.395]);
    bar(eyes_closed_part_all_chan_acc_var(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_closed_part_all_chan_acc_var(i_chan,:)),...
        eyes_closed_part_all_chan_acc_var(i_chan,:),...
        num2str(eyes_closed_part_all_chan_acc_var(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis Variance'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Closed ACC','FontSize', 24,'FontWeight', 'bold');
    ylim([0,0.005]);
    
end


%%
%%%Plot GYRO RMS, SD, and variance for each participant%%%
figure;
coords = {'X';'Y';'Z'};
for i_chan = 1:3
    
    %%%open%%%
    subplot(2,3,i_chan,'Position',[0.05+(0.325*(i_chan-1)),0.57,0.295,0.395]);
    bar(eyes_open_part_all_chan_gyro_rms(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_open_part_all_chan_gyro_rms(i_chan,:)),...
        eyes_open_part_all_chan_gyro_rms(i_chan,:),...
        num2str(eyes_open_part_all_chan_gyro_rms(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis RMS'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Open GYRO','FontSize', 24,'FontWeight', 'bold');
    ylim([0,3]);
    
    %%%closed%%%
    subplot(2,3,i_chan+3,'Position',[0.05+(0.325*(i_chan-1)),0.06,0.295,0.395]);
    bar(eyes_closed_part_all_chan_gyro_rms(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_closed_part_all_chan_gyro_rms(i_chan,:)),...
        eyes_closed_part_all_chan_gyro_rms(i_chan,:),...
        num2str(eyes_closed_part_all_chan_gyro_rms(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis RMS'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Closed GYRO','FontSize', 24,'FontWeight', 'bold');
    ylim([0,3]);
    
end

figure;
coords = {'X';'Y';'Z'};
for i_chan = 1:3
    
    %%%open%%%
    subplot(2,3,i_chan,'Position',[0.05+(0.325*(i_chan-1)),0.57,0.295,0.395]);
    bar(eyes_open_part_all_chan_gyro_sd(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_open_part_all_chan_gyro_sd(i_chan,:)),...
        eyes_open_part_all_chan_gyro_sd(i_chan,:),...
        num2str(eyes_open_part_all_chan_gyro_sd(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis SD'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Open GYRO','FontSize', 24,'FontWeight', 'bold');
    ylim([0,1]);
    
    %%%closed%%%
    subplot(2,3,i_chan+3,'Position',[0.05+(0.325*(i_chan-1)),0.06,0.295,0.395]);
    bar(eyes_closed_part_all_chan_gyro_sd(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_closed_part_all_chan_gyro_sd(i_chan,:)),...
        eyes_closed_part_all_chan_gyro_sd(i_chan,:),...
        num2str(eyes_closed_part_all_chan_gyro_sd(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis SD'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Closed GYRO','FontSize', 24,'FontWeight', 'bold');
    ylim([0,1]);
    
end

figure;
coords = {'X';'Y';'Z'};
for i_chan = 1:3
    
    %%%open%%%
    subplot(2,3,i_chan,'Position',[0.05+(0.325*(i_chan-1)),0.57,0.295,0.395]);
    bar(eyes_open_part_all_chan_gyro_var(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_open_part_all_chan_gyro_var(i_chan,:)),...
        eyes_open_part_all_chan_gyro_var(i_chan,:),...
        num2str(eyes_open_part_all_chan_gyro_var(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis Variance'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Open GYRO','FontSize', 24,'FontWeight', 'bold');
    ylim([0,0.5]);
    
    %%%closed%%%
    subplot(2,3,i_chan+3,'Position',[0.05+(0.325*(i_chan-1)),0.06,0.295,0.395]);
    bar(eyes_closed_part_all_chan_gyro_var(i_chan,:),'linewidth',3)
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none')
    text(1:length(eyes_closed_part_all_chan_gyro_var(i_chan,:)),...
        eyes_closed_part_all_chan_gyro_var(i_chan,:),...
        num2str(eyes_closed_part_all_chan_gyro_var(i_chan,:)'),...
        'vert','bottom','horiz','center','FontSize', 12,'FontWeight', 'bold')
    ylabel([coords{i_chan} ' Axis Variance'],'FontSize', 18,'FontWeight', 'bold');
    xlabel('Patient Number','FontSize', 18,'FontWeight', 'bold');
    title('Eyes Closed GYRO','FontSize', 24,'FontWeight', 'bold');
    ylim([0,0.5]);
    
end

%%
% %%%Plot ACC data for each participant%%%
% for i_part = 1:length(parts)
%     figure;
%
%     plot(eyes_open_part_all_chan_acc(:,1,i_part),eyes_open_part_all_chan_acc(:,2,i_part));
%     ylabel('Y Coordinates');
%     xlabel('X Coordinates');
%
% end
%
% %%
% %%%Plot ACC data for each participant%%%
% for i_part = 1:length(parts)
%     figure;
%
%     scatter3(eyes_open_part_all_chan_acc(:,1,i_part),eyes_open_part_all_chan_acc(:,2,i_part),eyes_open_part_all_chan_acc(:,3,i_part));
%     zlabel('Z Coordinates');
%     ylabel('Y Coordinates');
%     xlabel('X Coordinates');
%
% end