%%

%%%trigger info%%%
%%%Oddball%%%
% % 1 = standards
% % 2 = targets
% % 3 = response to standards
% % 4 = response to targets
% % 5 = start of experiment
% % 6 = end of experiment

clearvars
close all
clc

%%%%here we will specify our participants, conditions, and electrodes
parts = {'001';'002';'003'};
electrodes = {'TP9';'AF7';'AF8';'TP10'}; %AUX will be used for EKG

n_chans = length(electrodes);
standard_num = 200;
target_num = 50;

conds = {'standards';'targets'};
n_trigs = standard_num + target_num;

%%%ERP information
baseline = 51; %in samples, 51 is about 200 ms
epoch = 256; %in samples, 256 is about 1 second

high_pass = 0.1; %lower cutoff
low_pass = 30; %upper cutoff
order = 4; %order of polynomial used in the filter, can be increased to sharpen the dropoff of the filter
type = 'band'; %type of filter

%%%file path and name information
datapath = ['M:\Data\Muse_Stroke_Study\Oddball\'];
% % datapath = ['M:\Data\Muse_Stroke_Study\Pilot\Oddball\'];

%%%filter information
threshold = 50; %absolute uV away from baseline
srate = 256;
period = 1/srate;

pi_times_baseline = NaN(length(parts),standard_num + target_num);
pi_times_oddball = NaN(length(parts),standard_num + target_num);

all_standards = NaN((baseline+epoch),n_chans,standard_num,length(parts));
all_targets = NaN((baseline+epoch),n_chans,target_num,length(parts));

standard_part = NaN((baseline+epoch),n_chans,length(parts));
target_part = NaN((baseline+epoch),n_chans,length(parts));

standard_parts_combined = NaN((baseline+epoch),ceil(n_chans/2),length(parts));
target_parts_combined = NaN((baseline+epoch),ceil(n_chans/2),length(parts));

standards_erp = NaN((baseline+epoch),n_chans,standard_num);
targets_erp = NaN((baseline+epoch),n_chans,target_num);

standards_baseline = NaN(n_chans,standard_num);
targets_baseline = NaN(n_chans,target_num);

standard_count_eeg = NaN(standard_num,n_chans,length(parts));
target_count_eeg = NaN(target_num,n_chans,length(parts));

standard_rej_eeg = NaN(standard_num,n_chans,length(parts));
target_rej_eeg = NaN(target_num,n_chans,length(parts));

%%%variables for ACC%%%
eyes_open_part_all_chan_acc = NaN((baseline+epoch), standard_num, 3, length(parts));
eyes_closed_part_all_chan_acc = NaN((baseline+epoch), target_num, 3, length(parts));
eyes_open_part_all_chan_acc_rms = NaN(standard_num, 3, length(parts));
eyes_closed_part_all_chan_acc_rms = NaN(target_num, 3, length(parts));
eyes_open_part_all_chan_acc_sd = NaN(standard_num, 3, length(parts));
eyes_closed_part_all_chan_acc_sd = NaN(target_num, 3, length(parts));
eyes_open_part_all_chan_acc_var = NaN(standard_num, 3, length(parts));
eyes_closed_part_all_chan_acc_var = NaN(target_num, 3, length(parts));

%%%variables for GYRO%%%
eyes_open_part_all_chan_gyro = NaN((baseline+epoch), standard_num, 3, length(parts));
eyes_closed_part_all_chan_gyro = NaN((baseline+epoch), target_num, 3, length(parts));
eyes_open_part_all_chan_gyro_rms = NaN(standard_num, 3, length(parts));
eyes_closed_part_all_chan_gyro_rms = NaN(target_num, 3, length(parts));
eyes_open_part_all_chan_gyro_sd = NaN(standard_num, 3, length(parts));
eyes_closed_part_all_chan_gyro_sd = NaN(target_num, 3, length(parts));
eyes_open_part_all_chan_gyro_var = NaN(standard_num, 3, length(parts));
eyes_closed_part_all_chan_gyro_var = NaN(target_num, 3, length(parts));

%%
for i_part = 1:length(parts)
    
    disp(['Processing data for participant ' parts{i_part} ' and experiment Oddball']);
    
    %%%get the filename for each device, condition, and participant
    filename_eeg = [parts{i_part} '_EEG_oddball_stroke_study_updated.csv'];
    filename_acc = [parts{i_part} '_ACC_oddball_stroke_study_updated.csv'];
    filename_gyro = [parts{i_part} '_GYRO_oddball_stroke_study_updated.csv'];
    
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
    
    %%%pi time stuff for later%%%
    %     pi_times_baseline(i_part,:) =
    %     filename_pi = [parts{i_part} '_Auditory_P3_Stroke_Study_Updated.csv'];
    %     filename_pi = [parts{i_part} '_Baseline_Stroke_Study_Updated.csv'];
    %     t = readtable([datapath filename_pi]);
    %
    %     markers = markers_eeg(markers_eeg > 0);
    %     times = times_eeg(markers_eeg > 0) - times_eeg(1);
    %     times = times - times(1);
    %
    %     markers = markers_eeg(markers_eeg == 1 | markers_eeg == 2 | markers_eeg == 5);
    %     times = times_eeg(markers_eeg == 1 | markers_eeg == 2 | markers_eeg == 5) - times_eeg(1);
    %     times = times - times(1);
    
    for i_chan = 1:n_chans
        
        disp(['Processing data for channel ' electrodes{i_chan}]);
        
        %%%now extract our EEG data%%%
        eeg_data_chan = eeg_data(:,i_chan);
        
        %%%let's remove NaNs in our data since the filter won't like them%%%
        %%%instead of deleating them, we will use interp1 to predict what the values should be%%%
        %                 nan_val = isnan(eeg_data_chan);
        %                 total_val = 1:numel(eeg_data_chan);
        %                 eeg_data_chan(nan_val) = interp1(total_val(~nan_val), eeg_data_chan(~nan_val), total_val(nan_val));
        
        %%%now let's filter our eeg data
        [filt_eeg] = illini_filter(eeg_data_chan,srate,high_pass,low_pass,order,'band'); %run the filter (which plots a graph)
        
        %%%loop through target and standard timepoints and extract
        %%%so much data before and after each trigger
        
        standards_eeg = find(markers_eeg == 1);
        targets_eeg = find(markers_eeg == 2);
        stnd_rej_list_eeg = zeros(1,length(standards_eeg));
        targ_rej_list_eeg = zeros(1,length(targets_eeg));
        
        for i_stnd = 1:length(standards_eeg)
            %%%sometimes the last trigger is too close to the end
            %%%of the EEG file, so we just skip it if this is the
            %%%case
            if (standards_eeg(i_stnd)+epoch-1) > length(filt_eeg)
                standards_eeg(i_stnd) = [];
            else
                %%%save data points so much time before and after
                %%%the start of each trigger
                standards_erp(:,i_chan,i_stnd) = filt_eeg(standards_eeg(i_stnd)-baseline:standards_eeg(i_stnd)+epoch-1);
                %%%determine the average voltage during our
                %%%baseline period
                standards_baseline(i_chan,i_stnd) = nanmean(filt_eeg(standards_eeg(i_stnd)-baseline:standards_eeg(i_stnd)));
                %%%subtract our baseline from the epoch we recently
                %%%saved
                standards_erp(:,i_chan,i_stnd) = standards_erp(:,i_chan,i_stnd) - standards_baseline(i_chan,i_stnd);
            end
            %%%if a value is greater than our threshold, we turn
            %%%entire epoch into NaN and keep track our the number
            %%%of epochs we rejected
            if max(abs(squeeze(standards_erp(:,i_chan,i_stnd)))) > threshold
                standards_erp(:,i_chan,i_stnd) = NaN;
                stnd_rej_list_eeg(i_stnd) = i_stnd;
            end
        end
        
        for i_targ = 1:length(targets_eeg)
            %%%sometimes the last trigger is too close to the end
            %%%of the EEG file, so we just skip it if this is the
            %%%case
            if (targets_eeg(i_targ)+epoch-1) > length(filt_eeg)
                targets_eeg(i_targ) = [];
            else
                %%%save data points so much time before and after
                %%%the start of each trigger
                targets_erp(:,i_chan,i_targ) = filt_eeg(targets_eeg(i_targ)-baseline:targets_eeg(i_targ)+epoch-1);
                %%%determine the average voltage during our
                %%%baseline period
                targets_baseline(i_chan,i_targ) = nanmean(filt_eeg(targets_eeg(i_targ)-baseline:targets_eeg(i_targ)));
                %%%subtract our baseline from the epoch we recently
                %%%saved
                targets_erp(:,i_chan,i_targ) = targets_erp(:,i_chan,i_targ) - targets_baseline(i_chan,i_targ);
            end
            %%%if a value is greater than our threshold, we turn
            %%%entire epoch into NaN and keep track our the number
            %%%of epochs we rejected
            if max(abs(squeeze(targets_erp(:,i_chan,i_targ)))) > threshold
                targets_erp(:,i_chan,i_targ) = NaN;
                targ_rej_list_eeg(i_targ) = i_targ;
            end
        end
        
        fprintf([num2str(sum(stnd_rej_list_eeg ~= 0)) ' Standard trials rejected. \n']);
        fprintf([num2str(sum(targ_rej_list_eeg ~= 0)) ' Target trials rejected. \n']);
        
        standard_count_eeg(i_chan,i_part) = length(standards_eeg)-sum(isnan(standards_erp(1,i_chan,1:length(standards_eeg))));
        target_count_eeg(i_chan,i_part) = length(targets_eeg)-sum(isnan(targets_erp(1,i_chan,1:length(targets_eeg))));
        
        standard_rej_eeg(i_chan,i_part) = sum(isnan(standards_erp(1,i_chan,1:length(standards_eeg))));
        target_rej_eeg(i_chan,i_part) = sum(isnan(targets_erp(1,i_chan,1:length(targets_eeg))));
        
    end
    
%     %%%process ACC and GYRO data%%%
%     for i_chan = 1:3
%         
%         %%%find markers%%%
%         standards_acc = find(markers_acc == 1);
%         standards_gyro = find(markers_gyro == 1);
%         
%         targets_acc = find(markers_acc == 2);
%         targets_gyro = find(markers_gyro == 2);
%         
%         stnd_rej_list_acc = zeros(1,length(standards_acc));
%         stnd_rej_list_gyro = zeros(1,length(standards_gyro));
%         
%         targ_rej_list_acc = zeros(1,length(targets_acc));
%         targ_rej_list_gyro = zeros(1,length(targets_gyro));
%         
%         %%%find our epochs in acc and gyro%%%
%         
%         for i_stnd = 1:length(standards_eeg)
%             %%%sometimes the last trigger is too close to the end
%             %%%of the EEG file, so we just skip it if this is the
%             %%%case
%             if (standards_eeg(i_stnd)+epoch-1) > length(filt_eeg)
%                 standards_eeg(i_stnd) = [];
%             else
%                 %%%save data points so much time before and after
%                 %%%the start of each trigger
%                 standards_erp(:,i_chan,i_stnd) = filt_eeg(standards_eeg(i_stnd)-baseline:standards_eeg(i_stnd)+epoch-1);
%                 %%%determine the average voltage during our
%                 %%%baseline period
%                 standards_baseline(i_chan,i_stnd) = nanmean(filt_eeg(standards_eeg(i_stnd)-baseline:standards_eeg(i_stnd)));
%                 %%%subtract our baseline from the epoch we recently
%                 %%%saved
%                 standards_erp(:,i_chan,i_stnd) = standards_erp(:,i_chan,i_stnd) - standards_baseline(i_chan,i_stnd);
%             end
%             %%%if a value is greater than our threshold, we turn
%             %%%entire epoch into NaN and keep track our the number
%             %%%of epochs we rejected
%             if max(abs(squeeze(standards_erp(:,i_chan,i_stnd)))) > threshold
%                 standards_erp(:,i_chan,i_stnd) = NaN;
%                 stnd_rej_list_eeg(i_stnd) = i_stnd;
%             end
%         end
%         
%         for i_targ = 1:length(targets_eeg)
%             %%%sometimes the last trigger is too close to the end
%             %%%of the EEG file, so we just skip it if this is the
%             %%%case
%             if (targets_eeg(i_targ)+epoch-1) > length(filt_eeg)
%                 targets_eeg(i_targ) = [];
%             else
%                 %%%save data points so much time before and after
%                 %%%the start of each trigger
%                 targets_erp(:,i_chan,i_targ) = filt_eeg(targets_eeg(i_targ)-baseline:targets_eeg(i_targ)+epoch-1);
%                 %%%determine the average voltage during our
%                 %%%baseline period
%                 targets_baseline(i_chan,i_targ) = nanmean(filt_eeg(targets_eeg(i_targ)-baseline:targets_eeg(i_targ)));
%                 %%%subtract our baseline from the epoch we recently
%                 %%%saved
%                 targets_erp(:,i_chan,i_targ) = targets_erp(:,i_chan,i_targ) - targets_baseline(i_chan,i_targ);
%             end
%             %%%if a value is greater than our threshold, we turn
%             %%%entire epoch into NaN and keep track our the number
%             %%%of epochs we rejected
%             if max(abs(squeeze(targets_erp(:,i_chan,i_targ)))) > threshold
%                 targets_erp(:,i_chan,i_targ) = NaN;
%                 targ_rej_list_eeg(i_targ) = i_targ;
%             end
%         end
%         
%     end
    
    %%%keep track of all our ERPs for each participant%%%
    %%%this will be (ERP length X channel number X ERP Number X Participant)
    all_standards(:,:,:,i_part) = standards_erp;
    all_targets(:,:,:,i_part) = targets_erp;
    
    %%% caculate the average waveform of each epoch to generate our ERP%%%
    %%%for this we need to average across ALL standards and ALL targets%%%
    standard_part(:,:,i_part) = squeeze(nanmean(standards_erp,3));
    target_part(:,:,i_part) = squeeze(nanmean(targets_erp,3));
    
    %%%now let's average across TP9/TP10 and AF7/AF8
    %%%first, we need to make sure that the same trials across all
    %%%channels are removed
    standard_parts_combined(:,1,i_part) = squeeze(nanmean(standard_part(:,[1,4],i_part),2));
    standard_parts_combined(:,2,i_part) = squeeze(nanmean(standard_part(:,[2,3],i_part),2));
    %     standard_parts_combined(:,3,i_part) = squeeze(standard_part(:,5,i_part));
    
    target_parts_combined(:,1,i_part) = squeeze(nanmean(target_part(:,[1,4],i_part),2));
    target_parts_combined(:,2,i_part) = squeeze(nanmean(target_part(:,[2,3],i_part),2));
    %     target_parts_combined(:,3,i_part) = squeeze(target_part(:,5,i_part));
    
end

%%
%%%now let's determine our standard error for each ERP
standard_se = nanstd(standard_parts_combined,[],3)./sqrt(length(parts));
target_se = nanstd(target_parts_combined,[],3)./sqrt(length(parts));

standard_se_all_chan = nanstd(standard_part,[],3)./sqrt(length(parts));
target_se_all_chan = nanstd(standard_part,[],3)./sqrt(length(parts));

%%%average across participants to get a grand average ERP
standard_grand_avg = squeeze(nanmean(standard_parts_combined,3));
target_grand_avg = squeeze(nanmean(target_parts_combined,3));

standard_grand_avg_all_chan = squeeze(nanmean(standard_part,3));
target_grand_avg_all_chan = squeeze(nanmean(target_part,3));

%%
%%%first we will plot the ERPs for each participant
epoch_times = -baseline*period:period:(epoch-1)*period;
electrodes_comb = {'TP9/TP10';'AF7/AF8'};

for i_chan = 1:length(electrodes_comb)
    figure;
    counts = 0;
    for i_part = 1:length(parts)
        counts = counts + 1;
        subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),counts);
        hold on;
        if i_chan == 3
            line([0,0],[-20,20],'Color','k');
            line([-0.2,1.0],[0,0],'Color','k');
            ylim([-20 20]);
            xlim([-.2 1.0])
            targ_col = 'b';
        elseif i_chan == 2
            line([0,0],[-20,20],'Color','k');
            line([-0.2,1.0],[0,0],'Color','k');
            ylim([-20 20]);
            xlim([-.2 1.0])
            targ_col = 'g';
        elseif i_chan == 1
            line([0,0],[-20,20],'Color','k');
            line([-0.2,1.0],[0,0],'Color','k');
            ylim([-20 20]);
            xlim([-.2 1.0])
            targ_col = 'r';
        end
        
        plot(epoch_times,standard_parts_combined(:,i_chan,i_part), 'color', 'k');
        plot(epoch_times,target_parts_combined(:,i_chan,i_part),'color', targ_col);
        
        %                 legend('Standard','Target');
        set(gca,'Ydir','reverse');
        title([electrodes_comb{i_chan} ' , ' parts{i_part}]);
        hold off;
    end
end
%%
%%%and now for plots of the grand average ERP at each combined electrode
for i_chan = 1:length(electrodes_comb)
    
    figure;
    
    if i_chan == 3
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'b';
    elseif i_chan == 2
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'g';
    elseif i_chan == 1
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'r';
    end
    
    boundedline(epoch_times,standard_grand_avg(:,i_chan),standard_se(:,i_chan),'k',...
        epoch_times,target_grand_avg(:,i_chan),target_se(:,i_chan), targ_col);
    
    legend('Standard','Target');
    set(gca,'Ydir','reverse');
    title([electrodes_comb{i_chan}]);
    
end

%%
%%%now let's plot the difference waveform, overlayed with all conditions%%%
col = {'r';'g';'b'};
for i_chan = 1:length(electrodes_comb)
    figure;
    hold on;
    
    if i_chan == 3
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
    elseif i_chan == 2
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
    elseif i_chan == 1
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
    end
    
    boundedline(epoch_times,target_grand_avg(:,i_chan) - standard_grand_avg(:,i_chan), ...
        nanstd(squeeze(target_parts_combined(:,i_chan,:) - standard_parts_combined(:,i_chan,:)),[],2)./sqrt(length(parts)),col{i_chan});
    
    set(gca,'Ydir','reverse');
    title(['Difference Waveforms for ' electrodes_comb{i_chan}]);
    
end
%%
%%%here we will plot for each of the FIVE electrodes
for i_chan = 1:length(electrodes)
    
    figure;
    
    if i_chan == 5
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'b';
    elseif i_chan == 2 || i_chan == 3
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'g';
    elseif i_chan == 1 || i_chan == 4
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'r';
    end
    
    boundedline(epoch_times,standard_grand_avg_all_chan(:,i_chan),standard_se_all_chan(:,i_chan),'k',...
        epoch_times,target_grand_avg_all_chan(:,i_chan),target_se_all_chan(:,i_chan), targ_col);
    
    legend('Standard','Target');
    set(gca,'Ydir','reverse');
    title([electrodes{i_chan}]);
    
end

%%
%%%here we will plot difference waveform for each of the FIVE electrodes
col = {'r';'g';'g';'r';'b'};
for i_chan = 1:length(electrodes)
    
    figure;
    
    if i_chan == 5
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'b';
    elseif i_chan == 2 || i_chan == 3
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'g';
    elseif i_chan == 1 || i_chan == 4
        line([0,0],[-20,20],'Color','k');
        line([-0.2,1.0],[0,0],'Color','k');
        ylim([-20 20]);
        xlim([-.2 1.0])
        targ_col = 'r';
    end
    
    boundedline(epoch_times,target_grand_avg_all_chan(:,i_chan) - standard_grand_avg_all_chan(:,i_chan), ...
        nanstd(squeeze(target_part(:,i_chan,:) - standard_part(:,i_chan,:)),[],2)./sqrt(length(parts)),col{i_chan});
    
    legend('Standard','Target');
    set(gca,'Ydir','reverse');
    title([electrodes{i_chan}]);
    
end

%%
%%%t-test results testing the P3 region%%%
time1 = find(epoch_times >= 0.3,1) - 1;
time2 = find(epoch_times >= 0.6,1);

i_chan = 1;

figure; hold on;
plot(epoch_times,...
    nanmean(squeeze(target_parts_combined(:,i_chan,:) - standard_parts_combined(:,i_chan,:)),2));
set(gca,'Ydir','reverse');
line([0,0],[-30,10],'Color','k');
line([-0.2,1.5],[0,0],'Color','k');
line([epoch_times(time1),epoch_times(time1)],[-30,10],'Color','k');
line([epoch_times(time2),epoch_times(time2)],[-30,10],'Color','k');
ylim([-10 10]);
xlim([-.2 1.5])
hold off;

aux_diff_nvs = squeeze(target_parts_combined(time1:time2,i_chan,1,:) - standard_parts_combined(time1:time2,i_chan,1,:));
aux_diff_blk = squeeze(target_parts_combined(time1:time2,i_chan,2,:) - standard_parts_combined(time1:time2,i_chan,2,:));
aux_diff_nvs_r = squeeze(target_parts_combined(time1:time2,i_chan,3,:) - standard_parts_combined(time1:time2,i_chan,3,:));
aux_diff_blk_r = squeeze(target_parts_combined(time1:time2,i_chan,4,:) - standard_parts_combined(time1:time2,i_chan,4,:));

%%%first let's test each condition to 0, to see that we are getting a significant P3 response%%%
[h,p,ci,stats] = ttest(nanmean(aux_diff_nvs,1),0, 'alpha', 0.05, 'Tail', 'right');
[h,p,ci,stats] = ttest(nanmean(aux_diff_nvs,1),0, 'alpha', 0.05, 'Tail', 'left');




%%
%%%%%IGNORE FOR NOW%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Calculate RMS%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pick_trials = 360;
perms = 10000;

nparts = length(parts);
nsets = 1; %number of conditions

rms_out = zeros(nparts,nsets,perms);
rms_erp_out = zeros(nparts,nsets,perms);
rms_out_allchans = zeros(nparts,nsets,perms,n_chans);
rms_erp_out_allchans = zeros(nparts,nsets,perms,n_chans);

for i_set = 1:nsets
    data_out = [];%%Only want to grab information from the low tone trials
    for i_part = 1:nparts
        for i_chan = 1:n_chans
            temp_data = [];
            temp_data = squeeze(all_standards(:,i_chan,~isnan(squeeze(all_standards(1,i_chan,:,i_part))),i_part));
            n_trials = length(temp_data(1,:));
            for i_perm = 1:perms
                these_trials = randperm(n_trials,pick_trials);
                %%%ALLEEG.data is organised by electrodes x timepoints x trials%%%
                %%%this will first calculate the root mean squared (rms) values for the baseline, at each electrode and each trial%%%
                %%%it will then average across electrodes and trials to obtain a single grand average rms%%%
                %%%this is done 10000 times (based on the value of perms)%%%
                %%%here, we want to grab only the baseline from 'these_trials'%%%
                rms_out_allchan(i_part,i_set,i_perm,i_chan) = mean(squeeze(rms(temp_data([1:baseline],these_trials),1)));
                
                %%%this is similar to above, except that it will caluclate the rms to the ERP, rather than for each individual trial%%%
                %%%it will then average across electrodes%%%
                rms_erp_out_allchan(i_part,i_set,i_perm,i_chan) = rms(mean(temp_data([1:baseline],these_trials),2),1);
            end
        end
    end
end

rms_out = mean(rms_out_allchan,4);
rms_erp_out = mean(rms_erp_out_allchan,4);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Calculate Trial Count%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pick_trials_stand = [5 10:10:360 ]; % 5 10:10:360 ]360pick per resample 400 350 300 250 200 150 100 75 50 40 30 20 10 5
pick_trials_targ = pick_trials_stand/5; %%5
pick_trials_stand = pick_trials_stand-pick_trials_targ;

electrode = 9;%Fz = 1; Pz = 12
electrode_muse = 1;
perms = 10000;
window = [300 550];
