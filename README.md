# Muse_Stroke_Study
%%%%%%

parts = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'018';'020';'021';'022';'023';'024';'025';'027';};
% stroke_parts = {'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'016';'019';'020';'022';'023';'025';'027'};
% control_parts = {'001';'015';'017';'018;'021';'024'};
% parts = {'999'};
electrodes = {'TP9';'AF7';'AF8';'TP10';'AUX'};%AUX will be used for EKG
electrodes_comb = {'TP9/TP10';'AF7/AF8';'AUX'};
stroke_loc = {'normal';'left';'left';'left';'left';'right';'right';'left';'left';'left';'left';'right';'normal';'left';'normal';'left';'normal';'normal';'left';'normal';'left';'normal';'normal';'right';'normal';};
patients = ~strcmp(stroke_loc,'normal');
controls = strcmp(stroke_loc,'normal');
age = {'91';'87';'61';'65';'83';'19';'71';'71';'86';'85';'37';'87';'66';'53';'53';'66';'64';'81';'75';'56';'87';'59';'48';'72';'29'};
gender = {'M';'M';'F';'M';'F';'F';'F';'M';'F';'M';'M';'M';'M';'F';'M';'M';'F';'F';'M';'M';'M';'M';'F';'F';'M'};
gender_index = [1;1;0;1;0;0;0;1;0;1;1;1;1;0;1;1;0;0;1;1;1;1;0;0;1];
severity = {'control';'small';'moderate';'moderate';'moderate';'small';'moderate';'moderate';'small';'moderate';'moderate';'large';'control';'large';'control';'small';'control';'control';'moderate';'control';'moderate';'control';'control';'large';'control';};
severity_small = strcmp(severity,'small');
severity_moderate = strcmp(severity,'moderate');
severity_large = strcmp(severity,'large');
severity_control = strcmp(severity,'control');
all_severity = [severity_control,severity_small,severity_moderate,severity_large];

time_from_onset = {'C','6','7','1','3','3','2','4','1','0','8','16','3','2','C','3','C','5','2','C','0','C','C','6','C'};
onset = {'Control';'Late';'Late';'Early';'Early';'Early';'Early';'Late';'Early';'Early';'Late';'Late';'Early';'Late';'Control';'Early';'Control';'Late';'Early';'Control';'Early';'Control';'Control';'Late';'Control'};
onset_index =  [0,2,2,1,1,1,1,2,1,1,2,2,1,2,0,1,0,2,1,0,1,0,0,2,0];
NIHSS = [0;0;8;12;16;0;1;14;8;10;15;10;0;14;0;1;0;0;2;0;10;0;0;10;0];
loc = {'Control';'Cortical';'Cortical';'Cortical';'Subcortical';'Subcortical';'Cortical';'Cortical';'Cortical';'Cortical';'Cortical';'Subcortical';'Control';'Cortical';'Control';'Cortical';'Control';'Control';'Cortical';'Control';'Cortical';'Control';'Control';'Cortical';'Control'};
loc_index = [0,1,1,1,2,2,1,1,1,1,1,2,0,1,0,1,0,0,1,0,1,0,0,1,0];

n_chans = length(electrodes);
conds = {'eyes_open';'eyes_closed'};
cond_labels = {'Eyes Open';'Eyes Closed'};
sev_labels = {'control';'small';'moderate';'large'};
n_trigs = 2;


%%%ERP information
baseline = 51; %in samples, 51 is about 200 ms
epoch_eeg = 48640; %in samples, 256 is about 1 second
epoch_acc = 9880; %in samples, 52 is about 1 second
epoch_gyro = 9880; %in samples, 52 is about 1 second

%%%BOSC variables%%%
F = 0.5:.1:31;
wavenum = 15;

%%%first let's determine our frequency bins%%%
delta_bins = find(F >= 0.5 & F <= 3);
theta_bins = find(F >= 4 & F <= 7);
alpha_bins = find(F >= 8 & F <= 12);
beta_bins = find(F >= 13 & F <= 31);
gamma_bins = find(F >= 32 & F <= 100);

bin_ranges = [0.5,3;4,7;8,12;13,31;32,100];

%%%file path and name information
datapath = ['C:\Users\User\Desktop\Muse_Stroke_Study_data\Baseline\'];

%%%variables for EEG%%%
open_all_parts_chan_eeg = NaN(length(F),epoch_eeg, n_chans, length(parts));
closed_all_parts_chan_eeg = NaN(length(F),epoch_eeg, n_chans, length(parts));

% open_parts_combined_eeg = NaN(length(F),epoch_eeg, 3, length(parts));
% closed_parts_combined_eeg = NaN(length(F),epoch_eeg, 3, length(parts));

avg_open_all_chan_eeg = NaN(length(F), n_chans, length(parts));
avg_closed_all_chan_eeg = NaN(length(F), n_chans, length(parts));

% avg_open_combined_eeg = NaN(length(F), 3, length(parts));
% avg_closed_combined_eeg = NaN(length(F), 3, length(parts));

avg_open_good_eeg = NaN(length(F), 2, length(parts));
avg_closed_good_eeg = NaN(length(F), 2, length(parts));

avg_open_bad_eeg = NaN(length(F), 2, length(parts));
avg_closed_bad_eeg = NaN(length(F), 2, length(parts));

avg_open_normal_eeg = NaN(length(F), 4, length(parts));
avg_closed_normal_eeg = NaN(length(F), 4,length(parts));


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
    acc_data = temp_acc_data(:,2:4);
    gyro_data = temp_gyro_data(:,2:4);
    
    markers_eeg = temp_eeg_data(:,7); 
    markers_acc = temp_acc_data(:,5);
    markers_gyro = temp_gyro_data(:,5);
    times_eeg = temp_eeg_data(:,1);
    times_acc = temp_acc_data(:,1);
    times_gyro = temp_gyro_data(:,1);
    
    %%%process eeg data%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i_chan = 1:n_chans
        disp(['Processing data for channel ' electrodes{i_chan}]);
        
        %%%now extract our EEG data%%%
        if strcmp(electrodes{i_chan},'AUX')
            eeg_data_chan = eeg_data(:,i_chan);
        else
            eeg_data_chan = eeg_data(:,i_chan) - nanmean(eeg_data(:,i_chan));
        end
        
        %%%info for BOSC%%%
        period = median(diff(times_eeg));
        srate = 1/period;
        timepoints = period:period:length(times_eeg)*period;
        timepointm = timepoints/60;
        [bosc_eeg_data_chan] = log(BOSC_tf(eeg_data_chan,F,srate,wavenum));
        [bosc_eeg_data_chan_fooof] = (BOSC_tf(eeg_data_chan,F,srate,wavenum));
        
        %%%get marker positions%%%
        eyes_open_eeg_start = find(markers_eeg == 2);
        eyes_open_eeg_end = find(markers_eeg == 3);
        eyes_closed_eeg_start = find(markers_eeg == 5);
        eyes_closed_eeg_end = find(markers_eeg == 6);
        
        if isempty(eyes_closed_eeg_end)
            eyes_closed_eeg_end = eyes_closed_eeg_start + (srate*(180));
        end
        
        if eyes_closed_eeg_end > length(times_eeg)
            eyes_closed_eeg_end = length(times_eeg);
        end
        
        times_eeg_open = times_eeg(eyes_open_eeg_start:eyes_open_eeg_end);
        times_eeg_closed = times_eeg(eyes_closed_eeg_start:eyes_closed_eeg_end);
        
        %%%save eyes open and closed segments%%%
        open_all_parts_chan_eeg(:,1:eyes_open_eeg_end-eyes_open_eeg_start+1,i_chan,i_part) = bosc_eeg_data_chan(:,eyes_open_eeg_start:eyes_open_eeg_end);
        closed_all_parts_chan_eeg(:,1:eyes_closed_eeg_end-eyes_closed_eeg_start+1,i_chan,i_part) = bosc_eeg_data_chan(:,eyes_closed_eeg_start:eyes_closed_eeg_end);
        
        %%%average spectra across time%%%
        avg_open_all_chan_eeg(:,i_chan,i_part) = nanmean(open_all_parts_chan_eeg(:,:,i_chan,i_part),2);
        avg_closed_all_chan_eeg(:,i_chan,i_part) = nanmean(closed_all_parts_chan_eeg(:,:,i_chan,i_part),2);
        
        %%%save eyes open and eyes closed segments fooof%%%
        open_all_parts_chan_eeg_fooof(:,1:eyes_open_eeg_end-eyes_open_eeg_start+1,i_chan,i_part) = bosc_eeg_data_chan_fooof(:,eyes_open_eeg_start:eyes_open_eeg_end);
        closed_all_parts_chan_eeg_fooof(:,1:eyes_closed_eeg_end-eyes_closed_eeg_start+1,i_chan,i_part) = bosc_eeg_data_chan_fooof(:,eyes_closed_eeg_start:eyes_closed_eeg_end);
        
        %%%average spectra across time foof%%%
        avg_open_all_chan_eeg_fooof(:,i_chan,i_part) = nanmean(open_all_parts_chan_eeg_fooof(:,:,i_chan,i_part),2);
        avg_closed_all_chan_eeg_fooof(:,i_chan,i_part) = nanmean(closed_all_parts_chan_eeg_fooof(:,:,i_chan,i_part),2);
        
    end
    
    %%%also average across electrodes%%%
%     open_parts_combined_eeg(:,:,1,i_part) = nanmean(open_all_parts_chan_eeg(:,:,[1,4],i_part),3);
%     closed_parts_combined_eeg(:,:,1,i_part) = nanmean(closed_all_parts_chan_eeg(:,:,[1,4],i_part),3);
%     
%     open_parts_combined_eeg(:,:,2,i_part) = nanmean(open_all_parts_chan_eeg(:,:,[2,3],i_part),3);
%     closed_parts_combined_eeg(:,:,2,i_part) = nanmean(closed_all_parts_chan_eeg(:,:,[2,3],i_part),3);
%     
%     open_parts_combined_eeg(:,:,3,i_part) = open_all_parts_chan_eeg(:,:,5,i_part);
%     closed_parts_combined_eeg(:,:,3,i_part) = closed_all_parts_chan_eeg(:,:,5,i_part);
%     
%     avg_open_combined_eeg(:,1,i_part) = squeeze(nanmean(nanmean(open_all_parts_chan_eeg(:,:,[1,4],i_part),2),3));
%     avg_closed_combined_eeg(:,1,i_part) = squeeze(nanmean(nanmean(closed_all_parts_chan_eeg(:,:,[1,4],i_part),2),3));
%     
%     avg_open_combined_eeg(:,2,i_part) = squeeze(nanmean(nanmean(open_all_parts_chan_eeg(:,:,[2,3],i_part),2),3));
%     avg_closed_combined_eeg(:,2,i_part) = squeeze(nanmean(nanmean(closed_all_parts_chan_eeg(:,:,[2,3],i_part),2),3));
%     
%     avg_open_combined_eeg(:,3,i_part) = squeeze(nanmean(open_all_parts_chan_eeg(:,:,5,i_part),2));
%     avg_closed_combined_eeg(:,3,i_part) = squeeze(nanmean(closed_all_parts_chan_eeg(:,:,5,i_part),2));
    
    %%%sort based on stroke location%%%
    %%%TP9 and TP10 will be index 1%%%
    %%%AF7 and AF8 will be index 2%%%
    if strcmp(stroke_loc{i_part},'left')
        avg_open_bad_eeg(:,1,i_part) = avg_open_all_chan_eeg(:,1,i_part);
        avg_open_bad_eeg(:,2,i_part) = avg_open_all_chan_eeg(:,2,i_part);
        avg_closed_bad_eeg(:,1,i_part) = avg_closed_all_chan_eeg(:,1,i_part);
        avg_closed_bad_eeg(:,2,i_part) = avg_closed_all_chan_eeg(:,2,i_part);
        
        avg_open_good_eeg(:,1,i_part) = avg_open_all_chan_eeg(:,4,i_part);
        avg_open_good_eeg(:,2,i_part) = avg_open_all_chan_eeg(:,3,i_part);
        avg_closed_good_eeg(:,1,i_part) = avg_closed_all_chan_eeg(:,4,i_part);
        avg_closed_good_eeg(:,2,i_part) = avg_closed_all_chan_eeg(:,3,i_part);
        
    elseif strcmp(stroke_loc{i_part},'right')
        avg_open_bad_eeg(:,1,i_part) = avg_open_all_chan_eeg(:,4,i_part);
        avg_open_bad_eeg(:,2,i_part) = avg_open_all_chan_eeg(:,3,i_part);
        avg_closed_bad_eeg(:,1,i_part) = avg_closed_all_chan_eeg(:,4,i_part);
        avg_closed_bad_eeg(:,2,i_part) = avg_closed_all_chan_eeg(:,3,i_part);
        
        avg_open_good_eeg(:,1,i_part) = avg_open_all_chan_eeg(:,1,i_part);
        avg_open_good_eeg(:,2,i_part) = avg_open_all_chan_eeg(:,2,i_part);
        avg_closed_good_eeg(:,1,i_part) = avg_closed_all_chan_eeg(:,1,i_part);
        avg_closed_good_eeg(:,2,i_part) = avg_closed_all_chan_eeg(:,2,i_part);
        
    elseif strcmp(stroke_loc{i_part},'normal')
        
        avg_open_normal_eeg(:,:,i_part) = avg_open_all_chan_eeg(:,[1,2,3,4],i_part);
        avg_closed_normal_eeg(:,:,i_part) = avg_closed_all_chan_eeg(:,[1,2,3,4],i_part);
        
        avg_open_bad_eeg(:,1,i_part) = avg_open_all_chan_eeg(:,4,i_part);
        avg_open_bad_eeg(:,2,i_part) = avg_open_all_chan_eeg(:,3,i_part);
        avg_closed_bad_eeg(:,1,i_part) = avg_closed_all_chan_eeg(:,4,i_part);
        avg_closed_bad_eeg(:,2,i_part) = avg_closed_all_chan_eeg(:,3,i_part);
        
        avg_open_good_eeg(:,1,i_part) = avg_open_all_chan_eeg(:,1,i_part);
        avg_open_good_eeg(:,2,i_part) = avg_open_all_chan_eeg(:,2,i_part);
        avg_closed_good_eeg(:,1,i_part) = avg_closed_all_chan_eeg(:,1,i_part);
        avg_closed_good_eeg(:,2,i_part) = avg_closed_all_chan_eeg(:,2,i_part);
        
    end
        
    %%%sort based on stroke location fooof%%%
    %%%TP9 and TP10 will be index 1%%%
    %%%AF7 and AF8 will be index 2%%%
    if strcmp(stroke_loc{i_part},'left')
        avg_open_bad_eeg_fooof(:,1,i_part) = avg_open_all_chan_eeg_fooof(:,1,i_part);
        avg_open_bad_eeg_fooof(:,2,i_part) = avg_open_all_chan_eeg_fooof(:,2,i_part);
        avg_closed_bad_eeg_fooof(:,1,i_part) = avg_closed_all_chan_eeg_fooof(:,1,i_part);
        avg_closed_bad_eeg_fooof(:,2,i_part) = avg_closed_all_chan_eeg_fooof(:,2,i_part);
        
        avg_open_good_eeg_fooof(:,1,i_part) = avg_open_all_chan_eeg_fooof(:,4,i_part);
        avg_open_good_eeg_fooof(:,2,i_part) = avg_open_all_chan_eeg_fooof(:,3,i_part);
        avg_closed_good_eeg_fooof(:,1,i_part) = avg_closed_all_chan_eeg_fooof(:,4,i_part);
        avg_closed_good_eeg_fooof(:,2,i_part) = avg_closed_all_chan_eeg_fooof(:,3,i_part);
        
    elseif strcmp(stroke_loc{i_part},'right')
        avg_open_bad_eeg_fooof(:,1,i_part) = avg_open_all_chan_eeg_fooof(:,4,i_part);
        avg_open_bad_eeg_fooof(:,2,i_part) = avg_open_all_chan_eeg_fooof(:,3,i_part);
        avg_closed_bad_eeg_fooof(:,1,i_part) = avg_closed_all_chan_eeg_fooof(:,4,i_part);
        avg_closed_bad_eeg_fooof(:,2,i_part) = avg_closed_all_chan_eeg_fooof(:,3,i_part);
        
        avg_open_good_eeg_fooof(:,1,i_part) = avg_open_all_chan_eeg_fooof(:,1,i_part);
        avg_open_good_eeg_fooof(:,2,i_part) = avg_open_all_chan_eeg_fooof(:,2,i_part);
        avg_closed_good_eeg_fooof(:,1,i_part) = avg_closed_all_chan_eeg_fooof(:,1,i_part);
        avg_closed_good_eeg_fooof(:,2,i_part) = avg_closed_all_chan_eeg_fooof(:,2,i_part);
        
    elseif strcmp(stroke_loc{i_part},'normal')
        
        avg_open_normal_eeg_fooof(:,:,i_part) = avg_open_all_chan_eeg_fooof(:,[1,2,3,4],i_part);
        avg_closed_normal_eeg_fooof(:,:,i_part) = avg_closed_all_chan_eeg_fooof(:,[1,2,3,4],i_part);
        
        avg_open_bad_eeg_fooof(:,1,i_part) = avg_open_all_chan_eeg_fooof(:,4,i_part);
        avg_open_bad_eeg_fooof(:,2,i_part) = avg_open_all_chan_eeg_fooof(:,3,i_part);
        avg_closed_bad_eeg_fooof(:,1,i_part) = avg_closed_all_chan_eeg_fooof(:,4,i_part);
        avg_closed_bad_eeg_fooof(:,2,i_part) = avg_closed_all_chan_eeg_fooof(:,3,i_part);
        
        avg_open_good_eeg_fooof(:,1,i_part) = avg_open_all_chan_eeg_fooof(:,1,i_part);
        avg_open_good_eeg_fooof(:,2,i_part) = avg_open_all_chan_eeg_fooof(:,2,i_part);
        avg_closed_good_eeg_fooof(:,1,i_part) = avg_closed_all_chan_eeg_fooof(:,1,i_part);
        avg_closed_good_eeg_fooof(:,2,i_part) = avg_closed_all_chan_eeg_fooof(:,2,i_part);
        
    end
    %%%Process Acc DATA%%%%
    for i_chan = 1:3
        
        acc_data_chan = acc_data(:,i_chan);
        
        %%%find eyes open markers%%%
        eyes_open_acc_start = find(markers_acc == 2);
        eyes_open_acc_end = find(markers_acc == 3);
        
        %%%find eyes closed markers%%%
        eyes_closed_acc_start = find(markers_acc == 5);
        eyes_closed_acc_end = find(markers_acc == 6);
        
        %%%get our acc epochs%%%
        open_all_parts_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part) = acc_data_chan(eyes_open_acc_start:eyes_open_acc_end, 1);
        closed_all_parts_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part) = acc_data_chan(eyes_closed_acc_start:eyes_closed_acc_end, 1);
        
        %%%determine RMS, SD for each epoch%%%
        open_all_parts_chan_acc_rms(i_chan,i_part) = rms(open_all_parts_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part));
        closed_all_parts_chan_acc_rms(i_chan,i_part) = rms(closed_all_parts_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part));
        open_all_parts_chan_acc_sd(i_chan,i_part) = std(open_all_parts_chan_acc(1:eyes_open_acc_end-eyes_open_acc_start+1,i_chan,i_part));
        closed_all_parts_chan_acc_sd(i_chan,i_part) = std(closed_all_parts_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan,i_part));
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Process Gyro data%%%%%
    for i_chan = 1:3
        gyro_data_chan = gyro_data(:,i_chan);
        
        %%%find eyes open markers%%%
        eyes_open_gyro_start = find(markers_gyro == 2);
        eyes_open_gyro_end = find(markers_gyro == 3);
        
        %%%find eyes closed markers%%%
        eyes_closed_gyro_start = find(markers_gyro == 5);
        eyes_closed_gyro_end = find(markers_gyro == 6);
        
        %%%get our gyro epochs%%%
        open_all_parts_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part) = gyro_data_chan(eyes_open_gyro_start:eyes_open_gyro_end, 1);
        closed_all_parts_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part) = gyro_data_chan(eyes_closed_gyro_start:eyes_closed_gyro_end, 1);
        
        %%%determine RMS, SD fpr each epoch%%%
        open_all_parts_chan_gyro_rms(i_chan,i_part) = rms(open_all_parts_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part));
        closed_all_parts_chan_gyro_rms(i_chan,i_part) = rms(closed_all_parts_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part));
        open_all_parts_chan_gyro_sd(i_chan,i_part) = std(open_all_parts_chan_gyro(1:eyes_open_gyro_end-eyes_open_gyro_start+1,i_chan,i_part));
        closed_all_parts_chan_gyro_sd(i_chan,i_part) = std(closed_all_parts_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan,i_part));
    end
        
end

        

%%
%%%FOOOF our data%%%
%%eyes open
settings = struct();
for i_part = 1:length(parts)
    for i_chan = 1:n_chans
            fooof_avg_open_all_chan_eeg(i_chan,i_part) = fooof(F, avg_open_all_chan_eeg_fooof(:,i_chan,i_part)', [0.5,31], settings,'1');
            fooof_avg_open_all_chan_eeg_spectra(:,i_chan,i_part) = fooof_avg_open_all_chan_eeg(i_chan,i_part).power_spectrum;
            fooof_avg_open_all_chan_eeg_fooofed_spectra(:,i_chan,i_part) = fooof_avg_open_all_chan_eeg(i_chan,i_part).fooofed_spectrum;
            fooof_avg_open_all_chan_eeg_bg_spectra(:,i_chan,i_part) = fooof_avg_open_all_chan_eeg(i_chan,i_part).bg_fit;
    end
end

%%eyes closed
settings = struct();
for i_part = 1:length(parts)
    for i_chan = 1:n_chans
            fooof_avg_closed_all_chan_eeg(i_chan,i_part) = fooof(F, avg_closed_all_chan_eeg_fooof(:,i_chan,i_part), [0.5,31], settings,'1');
            fooof_avg_closed_all_chan_eeg_spectra(:,i_chan,i_part) = fooof_avg_closed_all_chan_eeg(i_chan,i_part).power_spectrum;
            fooof_avg_closed_all_chan_eeg_fooofed_spectra(:,i_chan,i_part) = fooof_avg_closed_all_chan_eeg(i_chan,i_part).fooofed_spectrum;
            fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,i_part) = fooof_avg_closed_all_chan_eeg(i_chan,i_part).bg_fit;
    end
end

%%good
settings = struct();
for i_part = 1:length(parts)
    for i_chan = 1:2
            fooof_avg_closed_good_chan_eeg(i_chan,i_part) = fooof(F, avg_closed_good_eeg_fooof(:,i_chan,i_part), [0.5,31], settings,'1');
            fooof_avg_closed_good_chan_eeg_spectra(:,i_chan,i_part) = fooof_avg_closed_good_chan_eeg(i_chan,i_part).power_spectrum;
            fooof_avg_closed_good_chan_eeg_fooofed_spectra(:,i_chan,i_part) = fooof_avg_closed_good_chan_eeg(i_chan,i_part).fooofed_spectrum;
            fooof_avg_closed_good_chan_eeg_bg_spectra(:,i_chan,i_part) = fooof_avg_closed_good_chan_eeg(i_chan,i_part).bg_fit;
    end
end

%%bad
settings = struct();
for i_part = 1:length(parts)
    for i_chan = 1:2
            fooof_avg_closed_bad_chan_eeg(i_chan,i_part) = fooof(F, avg_closed_bad_eeg_fooof(:,i_chan,i_part), [0.5,31], settings,'1');
            fooof_avg_closed_bad_chan_eeg_spectra(:,i_chan,i_part) = fooof_avg_closed_bad_chan_eeg(i_chan,i_part).power_spectrum;
            fooof_avg_closed_bad_chan_eeg_fooofed_spectra(:,i_chan,i_part) = fooof_avg_closed_bad_chan_eeg(i_chan,i_part).fooofed_spectrum;
            fooof_avg_closed_bad_chan_eeg_bg_spectra(:,i_chan,i_part) = fooof_avg_closed_bad_chan_eeg(i_chan,i_part).bg_fit;
    end
end

%%% 1= controls and left stroke, 4 = right stroke to identify ear electrode
%%% on stroke side
stroke_left = [1,1,1,1,1,4,4,1,1,1,1,4,1,1,1,1,1,1,1,1,1,1,1,4,1,1];
i_part = 1;
fooof_bg_intercept = [];
for i_parts = 1:length(parts)
    fooof_bg_intercept = [fooof_bg_intercept;fooof_avg_closed_all_chan_eeg_bg_spectra(1,stroke_left(i_part),i_part)];
    i_part = i_part + 1;
end

i_part = 1;
fooof_bg_end = [];
for i_parts = 1:length(parts)
    fooof_bg_end = [fooof_bg_end;fooof_avg_closed_all_chan_eeg_bg_spectra(306,stroke_left(i_part),i_part)];
    i_part = i_part + 1;
end

i_part = 1;
fooof_bg_slope = [];
for i_parts = 1:length(parts)
    fooof_bg_slope = [fooof_bg_slope;((fooof_bg_end(i_part)-fooof_bg_intercept(i_part))./306)];
    i_part = i_part + 1;
end

from fooof.utils.reports import methods_report_text
methods_report_text(fooof_obj)%%
%%plot fooof results
%%%compare baseline and stroke%%%

figure
colours = {[0,0,1],[1,0,1],[1,0.5,0],[1,0,0],[0,1,1]};
colours = {['c'],['y'],['m'],['r']};
title('BG Fit by Severity','FontSize', 12,'FontWeight', 'bold');
            group_1 = [1;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1;1;0;1;0;1;1;0;1];
            group_index_1 = find(group_1 == 1);
            group_2 = [0;1;0;0;0;1;1;0;1;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0];
            group_index_2 = find(group_2 == 1);
            group_3 = [0;0;1;1;1;0;0;1;0;1;1;0;0;0;0;0;0;0;1;0;1;0;0;0;0];
            group_index_3 = find(group_3 == 1);
            group_4 = [0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0;0;0;0;0;0;0;1;0];
            group_index_4 = find(group_4 == 1);

hold on;
for i_chan = 1:4
    subplot(2,2,i_chan)
    hold on
    boundedline(F, squeeze(mean(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_1),3)),nanstd(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_1),[],3)/sqrt(length(parts(group_index_1))),'color',colours{1,1},'LineWidth',3);
    boundedline(F, squeeze(mean(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_2),3)),nanstd(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_2),[],3)/sqrt(length(parts(group_index_1))),'color',colours{1,2},'LineWidth',3);
    boundedline(F, squeeze(mean(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_3),3)),nanstd(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_3),[],3)/sqrt(length(parts(group_index_1))),'color',colours{1,3},'LineWidth',3);
    boundedline(F, squeeze(mean(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_4),3)),nanstd(fooof_avg_closed_all_chan_eeg_bg_spectra(:,i_chan,group_index_4),[],3)/sqrt(length(parts(group_index_1))),'color',colours{1,4},'LineWidth',3);
    hold off
    set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
    legend({'Control','Small','Moderate','Severe'});
    legend('boxoff');
    title(electrodes(i_chan));
    ylabel('Power(\muV^2)','FontSize', 14,'FontWeight', 'bold');
    xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
end
sgtitle('Background Fit by Stroke Severity', 'FontSize', 18, 'FontWeight', 'bold');
hold off;

fooof_matrix = [fooof_bg_intercept];
severity_2 = [severity];


[~,~,stats] = anovan(fooof_matrix,{severity_2},'model','full',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,2])

%    figure 
%     
%             [hl,hr] = boundedline(...
%             F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'c','alpha',...
%             F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'g','alpha');
%         set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
%         set(hl,'linewidth',3);

%%
%%%Plot spectra for each participant for all electrodes%%%
for i_chan = 1:length(electrodes)
    figure;
    for i_part = 1:length(parts)
        
        subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),i_part);
        plot(F,avg_open_all_chan_eeg(:,i_chan,i_part),F,avg_closed_all_chan_eeg(:,i_chan,i_part),'LineWidth',3);
        set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
        
        xlim([0,30]);
        legend({'open','closed'});
        ylabel('Power (uV^2)','FontSize', 14,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
        title(['Spectra: ' parts{i_part} ': ' electrodes{i_chan}],'FontSize', 16,'FontWeight', 'bold');
        
    end
end
% 
% %%
% %%%Plot spectra for each participant for combined electrodes%%%
% 
% for i_chan = 1:length(electrodes_comb)
%     figure;
%     for i_part = 1:length(parts)
%         
%         subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),i_part);
%         plot(F,avg_open_combined_eeg(:,i_chan,i_part),F,avg_closed_combined_eeg(:,i_chan,i_part),'LineWidth',3);
%         set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
%         legend({'open','closed'});
%         ylabel('Power (uV^2)','FontSize', 14,'FontWeight', 'bold');
%         xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
%         title(['Spectra: ' parts{i_part} ': ' electrodes_comb{i_chan}],'FontSize', 16,'FontWeight', 'bold');
%         
%     end
% end

%%
%%%Plot grand-average spectra for all electrodes%%%

for i_chan = 1:length(electrodes)
    figure;
    
    plot(F,nanmean(avg_open_all_chan_eeg(:,i_chan,patients),3),F,nanmean(avg_closed_all_chan_eeg(:,i_chan,patients),3),'LineWidth',3);
    set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
    legend({'open','closed'});
    ylabel('Power (uV^2)','FontSize', 20,'FontWeight', 'bold');
    xlabel('Frequency (Hz)','FontSize', 20,'FontWeight', 'bold');
    title(['Grand Averaged Patient Spectra : ' electrodes{i_chan}],'FontSize', 24,'FontWeight', 'bold');
    
end

% %%
% %%%Plot grand-average spectra for combined electrodes%%%
% 
% for i_chan = 1:length(electrodes_comb)
%     figure;
%     
%     plot(F,nanmean(avg_open_combined_eeg(:,i_chan,patients),3),F,nanmean(avg_closed_combined_eeg(:,i_chan,patients),3),'LineWidth',3);
%     set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
%     legend({'open','closed'});
%     ylabel('Power (uV^2)','FontSize', 20,'FontWeight', 'bold');
%     xlabel('Frequency (Hz)','FontSize', 20,'FontWeight', 'bold');
%     title(['Grand Averaged Patient Spectra : ' electrodes_comb{i_chan}],'FontSize', 24,'FontWeight', 'bold');
%     
% end


%%
%%%Bar plot spectra for each participant for to compare left and right electrodes%%%
for i_cond = 1:2
    for i_chan = 1:2
        figure;
        for i_part = 1:length(parts)
            
            colours = {'b';'r'};
            
            if i_cond == 1
                
                %%%first let's determine our frequency bins%%%
                good_bins = [nanmean(nanmean(avg_open_good_eeg(delta_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_open_good_eeg(theta_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_open_good_eeg(alpha_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_open_good_eeg(beta_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_open_good_eeg(gamma_bins,i_chan,i_part),3),1),0];
                
                bad_bins = [0,nanmean(nanmean(avg_open_bad_eeg(delta_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_open_bad_eeg(theta_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_open_bad_eeg(alpha_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_open_bad_eeg(beta_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_open_bad_eeg(gamma_bins,i_chan,i_part),3),1)];
                
            elseif i_cond == 2
                %%%first let's determine our frequency bins%%%
                good_bins = [nanmean(nanmean(avg_closed_good_eeg(delta_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_closed_good_eeg(theta_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_closed_good_eeg(alpha_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_closed_good_eeg(beta_bins,i_chan,i_part),3),1),0;...
                    nanmean(nanmean(avg_closed_good_eeg(gamma_bins,i_chan,i_part),3),1),0];
                
                bad_bins = [0,nanmean(nanmean(avg_closed_bad_eeg(delta_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_closed_bad_eeg(theta_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_closed_bad_eeg(beta_bins,i_chan,i_part),3),1);...
                    0,nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,i_part),3),1)];
                
            end
            
            subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),i_part);
            hold on;
            B(1:2) = bar(good_bins,'b','LineWidth',3);
            B(3:4) = bar(bad_bins,'r','LineWidth',3);
            hold off;
            
            set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top', 'XTickLabel',{'Delta','Theta','Alpha','Beta','Gamma'});
            title(['Participant ' parts{i_part} ' : ' cond_labels{i_cond} ' : ' electrodes_comb{i_chan}],'FontSize', 12,'FontWeight', 'bold');
            
            if strcmp(stroke_loc{i_part},'normal')
                legend(B([2,4]),{electrodes_comb{i_chan}},'FontSize',8,'Location','Best');
            else
                legend(B([2,4]),{'good';'bad'},'FontSize',8,'Location','Best');
            end
            ylabel('Power (uV^2)','FontSize', 12,'FontWeight', 'bold');
            xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
            %             ylim([5,20]);
            
        end
    end
end

%%
%%%Grand Average bar plot spectra to compare left and right electrodes%%%
figure;
i_count = 1;

for i_chan = 2:-1:1
    for i_cond = 1:2
        
        colours = {'b';'r'};
        
        if i_cond == 1
            
            %%%first let's determine our frequency bins%%%
            good_bins = [nanmean(nanmean(avg_open_good_eeg(delta_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_open_good_eeg(theta_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_open_good_eeg(alpha_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_open_good_eeg(beta_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_open_good_eeg(gamma_bins,i_chan,patients),3),1),0];
            
            bad_bins = [0,nanmean(nanmean(avg_open_bad_eeg(delta_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_open_bad_eeg(theta_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_open_bad_eeg(alpha_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_open_bad_eeg(beta_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_open_bad_eeg(gamma_bins,i_chan,patients),3),1)];
            
        elseif i_cond == 2
            %%%first let's determine our frequency bins%%%
            good_bins = [nanmean(nanmean(avg_closed_good_eeg(delta_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_closed_good_eeg(theta_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_closed_good_eeg(alpha_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_closed_good_eeg(beta_bins,i_chan,patients),3),1),0;...
                nanmean(nanmean(avg_closed_good_eeg(gamma_bins,i_chan,patients),3),1),0];
            
            bad_bins = [0,nanmean(nanmean(avg_closed_bad_eeg(delta_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_closed_bad_eeg(theta_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_closed_bad_eeg(beta_bins,i_chan,patients),3),1);...
                0,nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,patients),3),1)];
            
        end
        
        subplot(2,2,i_count);
        i_count = i_count + 1;
        hold on;
        B(1:2) = bar(good_bins,'b','LineWidth',3);
        B(3:4) = bar(bad_bins,'r','LineWidth',3);
        hold off;
        
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top', 'XTickLabel',{'Delta','','Theta','','Alpha','','Beta','','Gamma'});
        title(['Grand Average : ' cond_labels{i_cond} ' : ' electrodes_comb{i_chan}],'FontSize', 12,'FontWeight', 'bold');
        
        legend(B([2,4]),{'good';'bad'});
        ylabel('Power (uV^2)','FontSize', 12,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
        ylim([8,15]);
        
    end
end

%%
%%%Now Plot Delta+Theta/Alpha+Beta Ratios for Each Electrode and Participant%%%
%%%just absolute%%%
%%%can also plot relative power (percentage of total)
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

for i_cond = 1:2
    for i_chan = 1:2
        figure;
        for i_part = 1:length(parts)
            
            
            
            subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),i_part);
            if i_cond == 1
                delta_power_good(i_part) = nanmean(avg_open_good_eeg(delta_bins,i_chan,i_part),1);
                theta_power_good(i_part) = nanmean(avg_open_good_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_good(i_part) = nanmean(avg_open_good_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_good(i_part) = nanmean(avg_open_good_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_good(i_part) = nanmean(avg_open_good_eeg(gamma_bins,i_chan,i_part),1);
                
                delta_power_bad(i_part) = nanmean(avg_open_bad_eeg(delta_bins,i_chan,i_part),1);
                theta_power_bad(i_part) = nanmean(avg_open_bad_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_bad(i_part) = nanmean(avg_open_bad_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_bad(i_part) = nanmean(avg_open_bad_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_bad(i_part) = nanmean(avg_open_bad_eeg(gamma_bins,i_chan,i_part),1);
                
            elseif i_cond == 2
                
                delta_power_good(i_part) = nanmean(avg_closed_good_eeg(delta_bins,i_chan,i_part),1);
                theta_power_good(i_part) = nanmean(avg_closed_good_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_good(i_part) = nanmean(avg_closed_good_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_good(i_part) = nanmean(avg_closed_good_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_good(i_part) = nanmean(avg_closed_good_eeg(gamma_bins,i_chan,i_part),1);
                
                delta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(delta_bins,i_chan,i_part),1);
                theta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_bad(i_part) = nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_bad(i_part) = nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,i_part),1);
            end
            
            %%%now plot the ratios of delta_theta vs alpha_beta%%%
            hold on;
            B(1:2) = bar(1,(delta_power_good(i_part)+theta_power_good(i_part))/(alpha_power_good(i_part)+beta_power_good(i_part)),'b','LineWidth',3);
            B(3:4) = bar(2,(delta_power_bad(i_part)+theta_power_bad(i_part))/(alpha_power_bad(i_part)+beta_power_bad(i_part)),'r','LineWidth',3);
            hold off;
            
            ylim([1.0,1.5]);
            set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
            if strcmp(stroke_loc{i_part},'normal')
                legend(B([2,4]),{electrodes_comb{i_chan}});
            else
                legend(B([2,4]),{'good';'bad'});
            end
            ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
            xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
            title(['Delta+Theta/Alpha+Beta : ' cond_labels{i_cond} ' : ' parts{i_part} ' ' electrodes_comb{i_chan}],'FontSize', 8,'FontWeight', 'bold');
            
        end
    end
end

%%
%%%Saving Delta/theta + alpha/beta ratio as a variable and graphing by
%%%severity%%%
i_count = 4;
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

% delta_power_good = squeeze(nanmean(nanmean(avg_open_good_eeg(delta_bins,:,patients),1),2));
delta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(beta_bins,1,:),1),2));
gamma_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(gamma_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(beta_bins,1,:),1),2));
gamma_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,1,:),1),2));

DTABR_good = (delta_power_good+theta_power_good)./(alpha_power_good+beta_power_good);

DTABR_bad = (delta_power_bad+theta_power_bad)./(alpha_power_bad+beta_power_bad);

%375 calculations
% delta_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(delta_bins,1,:),1),2));
% theta_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(theta_bins,1,:),1),2));
% alpha_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(alpha_bins,1,:),1),2));
% beta_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(beta_bins,1,:),1),2));
% gamma_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(gamma_bins,1,:),1),2));
% 
% delta_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(delta_bins,4,:),1),2));
% theta_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(theta_bins,4,:),1),2));
% alpha_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(alpha_bins,4,:),1),2));
% beta_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(beta_bins,4,:),1),2));
% gamma_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(gamma_bins,4,:),1),2));
% 
% DTABR_good_375 = (delta_power_good_375+theta_power_good_375)./(alpha_power_good_375+beta_power_good_375);
% 
% DTABR_bad_375 = (delta_power_bad_375+theta_power_bad_375)./(alpha_power_bad_375+beta_power_bad_375);

%DTABR calculations
% SE_DTABR_good_375 = std(nonzeros(DTABR_good_375))/sqrt(51);
SE_DTABR_good_control = std(nonzeros(DTABR_good.*severity_control))/sqrt(sum(severity_control));
SE_DTABR_good_small = std(nonzeros(DTABR_good.*severity_small))/sqrt(sum(severity_small));
SE_DTABR_good_moderate = std(nonzeros(DTABR_good.*severity_moderate))/sqrt(sum(severity_moderate));
SE_DTABR_good_large = std(nonzeros(DTABR_good.*severity_large))/sqrt(sum(severity_large));
SE_DTABR_good_all = [SE_DTABR_good_control,SE_DTABR_good_small,SE_DTABR_good_moderate,SE_DTABR_good_large];



% SE_DTABR_bad_375 = std(nonzeros(DTABR_bad_375))/sqrt(51);
SE_DTABR_bad_control = std(nonzeros(DTABR_bad.*severity_control))/(sqrt(sum(severity_control)));
SE_DTABR_bad_small = std(nonzeros(DTABR_bad.*severity_small))/sqrt(sum(severity_small));
SE_DTABR_bad_moderate = std(nonzeros(DTABR_bad.*severity_moderate))/sqrt(sum(severity_moderate));
SE_DTABR_bad_large = (std(nonzeros(DTABR_bad.*severity_large)))/sqrt(sum(severity_large));
SE_DTABR_bad_all = [SE_DTABR_bad_control,SE_DTABR_bad_small,SE_DTABR_bad_moderate,SE_DTABR_bad_large];

severity_t = {'Control','Small','Moderate','Large'};
severity_type = string(severity_t);
%%%now plot the ratios of delta_theta vs alpha_beta%%%
figure;

for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((delta_power_good_375+theta_power_good_375)./(alpha_power_good_375+beta_power_good_375)),'b','LineWidth',3);
%         er1 = errorbar(1,nanmean((delta_power_good_375+theta_power_good_375)./(alpha_power_good_375+beta_power_good_375)),SE_DTABR_good_375);
%         er1.Color = [0 0 0];
%     B(3:4) = bar(2,nanmean((delta_power_bad_375+theta_power_bad_375)./(alpha_power_bad_375+beta_power_bad_375)),'r','LineWidth',3);
%         er1 = errorbar(2,nanmean((delta_power_bad_375+theta_power_bad_375)./(alpha_power_bad_375+beta_power_bad_375)),SE_DTABR_bad_375);
%         er1.Color = [0 0 0];

%     hold off
    hold on;
    B(1:2) = bar(i_count,nanmean((delta_power_good(all_severity(:,i_sev))+theta_power_good(all_severity(:,i_sev)))./(alpha_power_good(all_severity(:,i_sev))+beta_power_good(all_severity(:,i_sev)))),'b','LineWidth',3);
    er1 = errorbar(i_count,nanmean((delta_power_good(all_severity(:,i_sev))+theta_power_good(all_severity(:,i_sev)))./(alpha_power_good(all_severity(:,i_sev))+beta_power_good(all_severity(:,i_sev)))),SE_DTABR_good_all(:,i_sev));
    er1.Color = [0 0 0];
    
    B(3:4) = bar((i_count + 1),nanmean((delta_power_bad(all_severity(:,i_sev))+theta_power_bad(all_severity(:,i_sev)))./(alpha_power_bad(all_severity(:,i_sev))+beta_power_bad(all_severity(:,i_sev)))),'r','LineWidth',3);
    er2 = errorbar((i_count + 1),nanmean((delta_power_bad(all_severity(:,i_sev))+theta_power_bad(all_severity(:,i_sev)))./(alpha_power_bad(all_severity(:,i_sev))+beta_power_bad(all_severity(:,i_sev)))),SE_DTABR_bad_all(:,i_sev));
    er2.Color = [0 0 0];
    i_count = i_count + 3;
    hold off;
    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
%     if strcmp(sev_labels{i_sev},'Control')
%         legend(B([2,4]),{'TP9';'TP10'});
%     else
%         legend(B([2,4]),{'Ispilateral';'Contralateral'});
%     end
    ax = gca;
    set(gca,'XTickLabel',severity_type,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'Undergraduate Controls','Age-Matched Controls','Small','Moderate','Severe',});
    ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
    xlabel({' ','Severity'},'FontSize', 12,'FontWeight', 'bold');
    title(['Delta+Theta/Alpha+Beta :  ' electrodes_comb{1}],'FontSize', 12,'FontWeight', 'bold');
    ylim([1.1,1.35]);
end


%%% ANOVA
DTABR_matrix = [DTABR_good;DTABR_bad];
DTABR_g_b_identifier = {'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';...
    'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad'};
severity_2 = [severity;severity];


[~,~,stats] = anovan(DTABR_matrix,{severity_2,DTABR_g_b_identifier},'model','full',...
    'varnames',{'severity','DTABr side'});
results = multcompare(stats,'Dimension',[1,2])
%%%%   NO SIGNIFICANT DIFFERENCES, THERE IS A SEVERITY EFFECT %%%

%%
%%%Saving Delta/Alpha ratio as a variable and graphing by
%%%severity + 375%%%
i_count = 4;
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

% delta_power_good = squeeze(nanmean(nanmean(avg_open_good_eeg(delta_bins,:,patients),1),2));
delta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(beta_bins,1,:),1),2));
gamma_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(gamma_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(beta_bins,1,:),1),2));
gamma_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,1,:),1),2));

DAR_good = (delta_power_good)./(alpha_power_good);

DAR_bad = (delta_power_bad)./(alpha_power_bad);
% 
% %375 calculations
% delta_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(delta_bins,1,:),1),2));
% theta_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(theta_bins,1,:),1),2));
% alpha_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(alpha_bins,1,:),1),2));
% beta_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(beta_bins,1,:),1),2));
% gamma_power_good_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(gamma_bins,1,:),1),2));
% 
% delta_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(delta_bins,4,:),1),2));
% theta_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(theta_bins,4,:),1),2));
% alpha_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(alpha_bins,4,:),1),2));
% beta_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(beta_bins,4,:),1),2));
% gamma_power_bad_375 = squeeze(nanmean(nanmean(avg_closed_all_chan_eeg_375(gamma_bins,4,:),1),2));
% 
% DAR_good_375 = (delta_power_good_375)./(alpha_power_good_375);
% 
% DAR_bad_375 = (delta_power_bad_375)./(alpha_power_bad_375);

%DTABR calculations
% SE_DAR_good_375 = std(nonzeros(DAR_good_375))/sqrt(51);
SE_DAR_good_control = std(nonzeros(DAR_good.*severity_control))/sqrt(sum(severity_control));
SE_DAR_good_small = std(nonzeros(DAR_good.*severity_small))/sqrt(sum(severity_small));
SE_DAR_good_moderate = std(nonzeros(DAR_good.*severity_moderate))/sqrt(sum(severity_moderate));
SE_DAR_good_large = std(nonzeros(DAR_good.*severity_large))/sqrt(sum(severity_large));
SE_DAR_good_all = [SE_DAR_good_control,SE_DAR_good_small,SE_DAR_good_moderate,SE_DAR_good_large];



% SE_DAR_bad_375 = std(nonzeros(DAR_bad_375))/sqrt(51);
SE_DAR_bad_control = std(nonzeros(DAR_bad.*severity_control))/(sqrt(sum(severity_control)));
SE_DAR_bad_small = std(nonzeros(DAR_bad.*severity_small))/sqrt(sum(severity_small));
SE_DAR_bad_moderate = std(nonzeros(DAR_bad.*severity_moderate))/sqrt(sum(severity_moderate));
SE_DAR_bad_large = (std(nonzeros(DAR_bad.*severity_large)))/sqrt(sum(severity_large));
SE_DAR_bad_all = [SE_DAR_bad_control,SE_DAR_bad_small,SE_DAR_bad_moderate,SE_DAR_bad_large];


%%%now plot the ratios of delta_theta vs alpha_beta%%%
figure;

for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((delta_power_good_375)./(alpha_power_good_375)),'b','LineWidth',3);
%         er1 = errorbar(1,nanmean((delta_power_good_375)./(alpha_power_good_375)),SE_DAR_good_375);
%         er1.Color = [0 0 0];
%     B(3:4) = bar(2,nanmean((delta_power_bad_375)./(alpha_power_bad_375)),'r','LineWidth',3);
%         er1 = errorbar(2,nanmean((delta_power_bad_375)./(alpha_power_bad_375)),SE_DAR_bad_375);
%         er1.Color = [0 0 0];

    hold off
    hold on;
    B(1:2) = bar(i_count,nanmean((delta_power_good(all_severity(:,i_sev)))./(alpha_power_good(all_severity(:,i_sev)))),'b','LineWidth',3);
    er1 = errorbar(i_count,nanmean((delta_power_good(all_severity(:,i_sev)))./(alpha_power_good(all_severity(:,i_sev)))),SE_DAR_good_all(:,i_sev));
    er1.Color = [0 0 0];
    
    B(3:4) = bar((i_count + 1),nanmean((delta_power_bad(all_severity(:,i_sev)))./(alpha_power_bad(all_severity(:,i_sev)))),'r','LineWidth',3);
    er2 = errorbar((i_count + 1),nanmean((delta_power_bad(all_severity(:,i_sev)))./(alpha_power_bad(all_severity(:,i_sev)))),SE_DAR_bad_all(:,i_sev));
    er2.Color = [0 0 0];
    i_count = i_count + 3;
    hold off;
    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
    if strcmp(sev_labels{i_sev},'Control')
        legend(B([2,4]),{'TP9';'TP10'});
    else
        legend(B([2,4]),{'Ispilateral';'Contralateral'},'Location','northeastoutside');
    end
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'Undergraduate Controls','Age-Matched Controls','Small','Moderate','Severe',});
    ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
    xlabel({' ','Severity'},'FontSize', 12,'FontWeight', 'bold');
%     xticks([1.5,4.5,7.5,10.5,13.5,]);
    title(['Delta/Alpha Ratio :  ' electrodes_comb{1}],'FontSize', 12,'FontWeight', 'bold');
    ylim([1.05,1.35]);
end

%%% ANOVA
DAR_matrix = [DAR_good;DAR_bad];
DAR_g_b_identifier = {'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';...
    'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad'};
severity_2 = [severity;severity];


[~,~,stats] = anovan(DAR_matrix,{severity_2,DAR_g_b_identifier},'model','full',...
    'varnames',{'severity','DAr side'});
results = multcompare(stats,'Dimension',[1,2])
%%%%   NO SIGNIFICANT DIFFERENCES, THERE IS A SEVERITY EFFECT %%%
%%
%%%Now Plot Grand Average Delta+Theta/Alpha+Beta Ratios for Each Electrode%%%
%%%just absolute%%%
%%%can also plot relative power (percentage of total)
figure;
i_count = 1;
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

for i_chan = 2:-1:1
    for i_cond = 1:2
        
        subplot(2,2,i_count);
        i_count = i_count + 1;
        
        if i_cond == 1
            
            delta_power_good = nanmean(nanmean(avg_open_good_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_good = nanmean(nanmean(avg_open_good_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_good = nanmean(nanmean(avg_open_good_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_good = nanmean(nanmean(avg_open_good_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_good = nanmean(nanmean(avg_open_good_eeg(gamma_bins,i_chan,patients),3),1);
            
            delta_power_bad = nanmean(nanmean(avg_open_bad_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_bad = nanmean(nanmean(avg_open_bad_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_bad = nanmean(nanmean(avg_open_bad_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_bad = nanmean(nanmean(avg_open_bad_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_bad = nanmean(nanmean(avg_open_bad_eeg(gamma_bins,i_chan,patients),3),1);
        elseif i_cond == 2
            
            delta_power_good = nanmean(nanmean(avg_closed_good_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_good = nanmean(nanmean(avg_closed_good_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_good = nanmean(nanmean(avg_closed_good_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_good = nanmean(nanmean(avg_closed_good_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_good = nanmean(nanmean(avg_closed_good_eeg(gamma_bins,i_chan,patients),3),1);
            
            delta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_bad = nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_bad = nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,patients),3),1);
        end
        
        %%%now plot the ratios of delta_theta vs alpha_beta%%%
        hold on;
        B(1:2) = bar(1,(delta_power_good+theta_power_good)/(alpha_power_good+beta_power_good),'b','LineWidth',3);
        B(3:4) = bar(2,(delta_power_bad+theta_power_bad)/(alpha_power_bad+beta_power_bad),'r','LineWidth',3);
        hold off;
        
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
        legend(B([2,4]),{'good';'bad'});
        ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
        title(['Delta+Theta/Alpha+Beta : ' cond_labels{i_cond} ' ' electrodes_comb{i_chan}],'FontSize', 12,'FontWeight', 'bold');
        ylim([1,1.3]);
        
    end
end


%%
%%%Now Plot Delta/Alpha Ratios for Each Electrode and Participant%%%
%%%just absolute%%%
%%%can also plot relative power (percentage of total)
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

for i_chan = 1:2
    for i_cond = 1:2
        figure;
        for i_part = 1:length(parts)
            
            subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),i_part);
            if i_cond == 1
                delta_power_good(i_part) = nanmean(avg_open_good_eeg(delta_bins,i_chan,i_part),1);
                theta_power_good(i_part) = nanmean(avg_open_good_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_good(i_part) = nanmean(avg_open_good_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_good(i_part) = nanmean(avg_open_good_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_good(i_part) = nanmean(avg_open_good_eeg(gamma_bins,i_chan,i_part),1);
                
                delta_power_bad(i_part) = nanmean(avg_open_bad_eeg(delta_bins,i_chan,i_part),1);
                theta_power_bad(i_part) = nanmean(avg_open_bad_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_bad(i_part) = nanmean(avg_open_bad_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_bad(i_part) = nanmean(avg_open_bad_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_bad(i_part) = nanmean(avg_open_bad_eeg(gamma_bins,i_chan,i_part),1);
                
            elseif i_cond == 2
                
                delta_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(delta_bins,i_chan,i_part),1);
                theta_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(gamma_bins,i_chan,i_part),1);
                
                delta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(delta_bins,i_chan,i_part),1);
                theta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_bad(i_part) = nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_bad(i_part) = nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,i_part),1);
            end
            
            %%%now plot the ratios of delta_theta vs alpha_beta%%%
            hold on;
            B(1:2) = bar(1,(delta_power_good(i_part)/(alpha_power_good(i_part))),'b','LineWidth',3);
            B(3:4) = bar(2,(delta_power_bad(i_part)/(alpha_power_bad(i_part))),'r','LineWidth',3);
            hold off;
            
            ylim([1.0,1.5]);
            set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
            if strcmp(stroke_loc{i_part},'normal')
                legend(B([2,4]),{electrodes_comb{i_chan}});
            else
                legend(B([2,4]),{'good';'bad'});
            end
            ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
            xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
            title(['Delta/Alpha : ' cond_labels{i_cond} ' : ' parts{i_part} ' ' electrodes_comb{i_chan}],'FontSize', 8,'FontWeight', 'bold');
            
        end
    end
end


%%
%%%Now Plot Grand Average Delta/Alpha Ratios for Each Electrode%%%
%%%just absolute%%%
%%%can also plot relative power (percentage of total)
figure;
i_count = 1;
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];


for i_chan = 2:-1:1
    for i_cond = 1:2
        
        subplot(2,2,i_count);
        i_count = i_count + 1;
        
        if i_cond == 1
            delta_power_good = nanmean(nanmean(avg_open_good_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_good = nanmean(nanmean(avg_open_good_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_good = nanmean(nanmean(avg_open_good_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_good = nanmean(nanmean(avg_open_good_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_good = nanmean(nanmean(avg_open_good_eeg(gamma_bins,i_chan,patients),3),1);
            
            delta_power_bad = nanmean(nanmean(avg_open_bad_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_bad = nanmean(nanmean(avg_open_bad_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_bad = nanmean(nanmean(avg_open_bad_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_bad = nanmean(nanmean(avg_open_bad_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_bad = nanmean(nanmean(avg_open_bad_eeg(gamma_bins,i_chan,patients),3),1);
            
        elseif i_cond == 2
            delta_power_good = nanmean(nanmean(avg_closed_good_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_good = nanmean(nanmean(avg_closed_good_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_good = nanmean(nanmean(avg_closed_good_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_good = nanmean(nanmean(avg_closed_good_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_good = nanmean(nanmean(avg_closed_good_eeg(gamma_bins,i_chan,patients),3),1);
            
            delta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_bad = nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_bad = nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,patients),3),1);
        end
        
        %%%now plot the ratios of delta_theta vs alpha_beta%%%
        hold on;
        B(1:2) = bar(1,(delta_power_good/(alpha_power_good)),'b','LineWidth',3);
        B(3:4) = bar(2,(delta_power_bad/(alpha_power_bad)),'r','LineWidth',3);
        hold off;
        
        
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
        legend(B([2,4]),{'good';'bad'});
        ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
        title(['Delta/Alpha : ' cond_labels{i_cond} ' ' electrodes_comb{i_chan}],'FontSize', 12,'FontWeight', 'bold');
        ylim([1,1.3]);
        
    end
end

%%
%%%Now Plot Delta/Theta Ratios for Each Electrode and Participant%%%
%%%just absolute%%%
%%%can also plot relative power (percentage of total)
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

for i_cond = 1:2
    for i_chan = 1:2
        figure;
        for i_part = 1:length(parts)
            
            subplot(ceil(sqrt(length(parts))),ceil(sqrt(length(parts))),i_part);
            if i_cond == 1
                delta_power_good(i_part) = nanmean(avg_open_good_eeg(delta_bins,i_chan,i_part),1);
                theta_power_good(i_part) = nanmean(avg_open_good_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_good(i_part) = nanmean(avg_open_good_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_good(i_part) = nanmean(avg_open_good_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_good(i_part) = nanmean(avg_open_good_eeg(gamma_bins,i_chan,i_part),1);
                
                delta_power_bad(i_part) = nanmean(avg_open_bad_eeg(delta_bins,i_chan,i_part),1);
                theta_power_bad(i_part) = nanmean(avg_open_bad_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_bad(i_part) = nanmean(avg_open_bad_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_bad(i_part) = nanmean(avg_open_bad_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_bad(i_part) = nanmean(avg_open_bad_eeg(gamma_bins,i_chan,i_part),1);
                
            elseif i_cond == 2
                
                delta_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(delta_bins,i_chan,i_part),1);
                theta_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_closed_good(i_part) = nanmean(avg_closed_good_eeg(gamma_bins,i_chan,i_part),1);
                
                delta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(delta_bins,i_chan,i_part),1);
                theta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(theta_bins,i_chan,i_part),1);
                alpha_power_bad(i_part) = nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,i_part),1);
                beta_power_bad(i_part) = nanmean(avg_closed_bad_eeg(beta_bins,i_chan,i_part),1);
                gamma_power_bad(i_part) = nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,i_part),1);
            end
            
            %%%now plot the ratios of delta_theta vs alpha_beta%%%
            hold on;
            B(1:2) = bar(1,(delta_power_good(i_part)/(theta_power_good(i_part))),'b','LineWidth',3);
            B(3:4) = bar(2,(delta_power_bad(i_part)/(theta_power_bad(i_part))),'r','LineWidth',3);
            hold off;
            
            ylim([1.0,1.5]);
            set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
            if strcmp(stroke_loc{i_part},'normal')
                legend(B([2,4]),{electrodes_comb{i_chan}});
            else
                legend(B([2,4]),{'good';'bad'});
            end
            ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
            xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
            title(['Delta/Theta : ' cond_labels{i_cond} ' : ' parts{i_part} ' ' electrodes_comb{i_chan}],'FontSize', 8,'FontWeight', 'bold');
            
        end
    end
end

%%
%%%Now Plot Grand Average Delta/Theta Ratios for Each Electrode%%%
%%%just absolute%%%
%%%can also plot relative power (percentage of total)
figure;
i_count = 1;
delta_power_good = [];
theta_power_good = [];
alpha_power_good = [];
beta_power_good = [];
gamma_power_good = [];

delta_power_bad = [];
theta_power_bad = [];
alpha_power_bad = [];
beta_power_bad = [];
gamma_power_bad = [];

for i_chan = 2:-1:1
    for i_cond = 1:2
        
        subplot(2,2,i_count);
        i_count = i_count + 1;
        
        if i_cond == 1
            delta_power_good = nanmean(nanmean(avg_open_good_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_good = nanmean(nanmean(avg_open_good_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_good = nanmean(nanmean(avg_open_good_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_good = nanmean(nanmean(avg_open_good_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_good = nanmean(nanmean(avg_open_good_eeg(gamma_bins,i_chan,patients),3),1);
            
            delta_power_bad = nanmean(nanmean(avg_open_bad_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_bad = nanmean(nanmean(avg_open_bad_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_bad = nanmean(nanmean(avg_open_bad_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_bad = nanmean(nanmean(avg_open_bad_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_bad = nanmean(nanmean(avg_open_bad_eeg(gamma_bins,i_chan,patients),3),1);
            
        elseif i_cond == 2
            delta_power_good = nanmean(nanmean(avg_closed_good_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_good = nanmean(nanmean(avg_closed_good_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_good = nanmean(nanmean(avg_closed_good_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_good = nanmean(nanmean(avg_closed_good_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_good = nanmean(nanmean(avg_closed_good_eeg(gamma_bins,i_chan,patients),3),1);
            
            delta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(delta_bins,i_chan,patients),3),1);
            theta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(theta_bins,i_chan,patients),3),1);
            alpha_power_bad = nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,i_chan,patients),3),1);
            beta_power_bad = nanmean(nanmean(avg_closed_bad_eeg(beta_bins,i_chan,patients),3),1);
            gamma_power_bad = nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,i_chan,patients),3),1);
        end
        
        %%%now plot the ratios of delta_theta vs alpha_beta%%%
        hold on;
        B(1:2) = bar(1,(delta_power_good/(theta_power_good)),'b','LineWidth',3);
        B(3:4) = bar(2,(delta_power_bad/(theta_power_bad)),'r','LineWidth',3);
        hold off;
        
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
        legend(B([2,4]),{'good';'bad'});
        ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 12,'FontWeight', 'bold');
        title(['Delta/Theta : ' cond_labels{i_cond} ' ' electrodes_comb{i_chan}],'FontSize', 12,'FontWeight', 'bold');
        ylim([1,1.2]);
        
    end
end

%%
%%%Graphing pdBSI by stroke severity%%%
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%all Hz%%%
tp9_all_closed = avg_closed_all_chan_eeg(:,1,:);
af7_all_closed = avg_closed_all_chan_eeg(:,2,:);
af8_all_closed = avg_closed_all_chan_eeg(:,3,:);
tp10_all_closed = avg_closed_all_chan_eeg(:,4,:);

tp9_all_open = avg_open_all_chan_eeg(:,1,:);
af7_all_open = avg_open_all_chan_eeg(:,2,:);
af8_all_open = avg_open_all_chan_eeg(:,3,:);
tp10_all_open = avg_open_all_chan_eeg(:,4,:);

%%%375 participants%%%
% tp9_all_closed_375 = avg_closed_all_chan_eeg_375(:,1,:);
% tp10_all_closed_375 = avg_closed_all_chan_eeg_375(:,4,:);


pdBSP_ear_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed))),1));
% pdBSP_ear_all_closed_375 = squeeze(nanmean(abs(((tp9_all_closed_375 - tp10_all_closed_375) ./ (tp9_all_closed_375 + tp10_all_closed_375))),1));

SE_pdBSP_control = std(nonzeros(pdBSP_ear_all_closed.*severity_control))/sqrt(sum(severity_control));
SE_pdBSP_small = std(nonzeros(pdBSP_ear_all_closed.*severity_small))/sqrt(sum(severity_small));
SE_pdBSP_moderate = std(nonzeros(pdBSP_ear_all_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_pdBSP_large = std(nonzeros(pdBSP_ear_all_closed.*severity_large))/sqrt(sum(severity_large));
% SE_pdBSP_375 = std(pdBSP_ear_all_closed_375)/sqrt(51);
SE_pdBSP_all = [SE_pdBSP_control,SE_pdBSP_small,SE_pdBSP_moderate,SE_pdBSP_large];

i_count = 1;
%%%now plot the pdBSI%%%
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_all_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_all_closed_375)),SE_pdBSP_375(:,:));
%     er.Color = [0 0 0];
%   
 
    B(1:2) = bar(i_count,nanmean((pdBSP_ear_all_closed(all_severity(:,i_sev)))),colour_list(i_count+1),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_all_closed(all_severity(:,i_sev)))),SE_pdBSP_all(:,i_sev));
    er.Color = [0 0 0];
    i_count = i_count + 1;
    i_sev = i_sev + 1;
    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([1,2,3,4,5,]);
    title(['pdBSI: all frequencies at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.03]);
  
%%% ANOVA %%%

[~,~,stats] = anovan(pdBSP_ear_all_closed,{severity},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%%%   NO SIGNIFICANT DIFFERENCES %%%

%%
%%%pdBSI at delta%%%
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%delta%%%
tp9_delta_closed = avg_closed_all_chan_eeg(delta_bins,1,:);
tp10_delta_closed = avg_closed_all_chan_eeg(delta_bins,4,:);

pdBSP_ear_delta_closed = squeeze(nanmean(abs(((tp9_delta_closed - tp10_delta_closed) ./ (tp9_delta_closed + tp10_delta_closed))),1));

%%%375 participants%%%
% tp9_delta_closed_375 = avg_closed_all_chan_eeg_375(delta_bins,1,:);
% tp10_delta_closed_375 = avg_closed_all_chan_eeg_375(delta_bins,4,:);

% pdBSP_ear_delta_closed_375 = squeeze(nanmean(abs(((tp9_delta_closed_375 - tp10_delta_closed_375) ./ (tp9_delta_closed_375 + tp10_delta_closed_375))),1));

SE_D_pdBSP_control = std(nonzeros(pdBSP_ear_delta_closed.*severity_control))/sqrt(sum(severity_control));
SE_D_pdBSP_small = std(nonzeros(pdBSP_ear_delta_closed.*severity_small))/sqrt(sum(severity_small));
SE_D_pdBSP_moderate = std(nonzeros(pdBSP_ear_delta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_D_pdBSP_large = std(nonzeros(pdBSP_ear_delta_closed.*severity_large))/sqrt(sum(severity_large));
SE_D_pdBSP_all = [SE_D_pdBSP_control,SE_D_pdBSP_small,SE_D_pdBSP_moderate,SE_D_pdBSP_large];
% SE_pdBSP_375_delta = std(pdBSP_ear_delta_closed_375)/sqrt(51);
i_count = 1;
%%%now plot the pdBSI for Delta%%%
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_delta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_delta_closed_375)),SE_pdBSP_375_delta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(1:2) = bar(i_count,nanmean((pdBSP_ear_delta_closed(all_severity(:,i_sev)))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_delta_closed(all_severity(:,i_sev)))),SE_D_pdBSP_all(:,i_sev));
    er.Color = [0 0 0];

    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'','','Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,5,6,]);
    title(['pdBSI: Delta (0.5-3 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.05]);
%%% ANOVA %%%
[~,~,stats] = anovan(pdBSP_ear_delta_closed,{severity},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%%%   NO SIGNIFICANT DIFFERENCES %%%
    
    %%
%%%pdBSI at theta%%%
i_count = 1;
colour_list = ['c','y','m','r',];
i_sev = 1;
%%%theta%%%
tp9_theta_closed = avg_closed_all_chan_eeg(theta_bins,1,:);
tp10_theta_closed = avg_closed_all_chan_eeg(theta_bins,4,:);

pdBSP_ear_theta_closed = squeeze(nanmean(abs(((tp9_theta_closed - tp10_theta_closed) ./ (tp9_theta_closed + tp10_theta_closed))),1));

%%%375 participants%%%
% tp9_theta_closed_375 = avg_closed_all_chan_eeg_375(theta_bins,1,:);
% tp10_theta_closed_375 = avg_closed_all_chan_eeg_375(theta_bins,4,:);
% 

pdBSP_ear_theta_closed = squeeze(nanmean(abs(((tp9_theta_closed - tp10_theta_closed) ./ (tp9_theta_closed + tp10_theta_closed))),1));
% pdBSP_ear_theta_closed_375 = squeeze(nanmean(abs(((tp9_theta_closed_375 - tp10_theta_closed_375) ./ (tp9_theta_closed_375 + tp10_theta_closed_375))),1));

SE_T_pdBSP_control = std(nonzeros(pdBSP_ear_theta_closed.*severity_control))/sqrt(sum(severity_control));
SE_T_pdBSP_small = std(nonzeros(pdBSP_ear_theta_closed.*severity_small))/sqrt(sum(severity_small));
SE_T_pdBSP_moderate = std(nonzeros(pdBSP_ear_theta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_T_pdBSP_large = std(nonzeros(pdBSP_ear_theta_closed.*severity_large))/sqrt(sum(severity_large));
SE_T_pdBSP = [SE_T_pdBSP_control,SE_T_pdBSP_small,SE_T_pdBSP_moderate,SE_T_pdBSP_large];
% SE_pdBSP_375_theta = std(pdBSP_ear_theta_closed_375)/sqrt(51);
i_count = 1;
%%%now plot the pdBSI for theta%%%
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_theta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_theta_closed_375)),SE_pdBSP_375_theta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(1:2) = bar(i_count,nanmean((pdBSP_ear_theta_closed(all_severity(:,i_sev)))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_theta_closed(all_severity(:,i_sev)))),SE_T_pdBSP(:,i_sev));
    er.Color = [0 0 0];

    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '','Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,5,6,]);
    title(['pdBSI: Theta (4-7 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.03]);
%%% ANOVA %%%
[~,~,stats] = anovan(pdBSP_ear_theta_closed,{severity},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%%%   NO SIGNIFICANT DIFFERENCES, trending towards significance, 0.1788 %%%
     
        %%
%%%pdBSI at alpha%%%
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%alpha%%%
tp9_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,1,:);
tp10_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,4,:);

pdBSP_ear_alpha_closed = squeeze(nanmean(abs(((tp9_alpha_closed - tp10_alpha_closed) ./ (tp9_alpha_closed + tp10_alpha_closed))),1));

%%%375 participants%%%
% tp9_alpha_closed_375 = avg_closed_all_chan_eeg_375(alpha_bins,1,:);
% tp10_alpha_closed_375 = avg_closed_all_chan_eeg_375(alpha_bins,4,:);


pdBSP_ear_alpha_closed = squeeze(nanmean(abs(((tp9_alpha_closed - tp10_alpha_closed) ./ (tp9_alpha_closed + tp10_alpha_closed))),1));
% pdBSP_ear_alpha_closed_375 = squeeze(nanmean(abs(((tp9_alpha_closed_375 - tp10_alpha_closed_375) ./ (tp9_alpha_closed_375 + tp10_alpha_closed_375))),1));

SE_A_pdBSP_control = std(nonzeros(pdBSP_ear_alpha_closed.*severity_control))/sqrt(sum(severity_control));
SE_A_pdBSP_small = std(nonzeros(pdBSP_ear_alpha_closed.*severity_small))/sqrt(sum(severity_small));
SE_A_pdBSP_moderate = std(nonzeros(pdBSP_ear_alpha_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_A_pdBSP_large = std(nonzeros(pdBSP_ear_alpha_closed.*severity_large))/sqrt(sum(severity_large));
SE_A_pdBSP = [SE_A_pdBSP_control,SE_A_pdBSP_small,SE_A_pdBSP_moderate,SE_A_pdBSP_large];
% SE_pdBSP_375_alpha = std(pdBSP_ear_alpha_closed_375)/sqrt(51);

%%%now plot the pdBSI for alpha%%%
i_count = 1;
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_alpha_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_alpha_closed_375)),SE_pdBSP_375_alpha(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(1:2) = bar(i_count,nanmean((pdBSP_ear_alpha_closed(all_severity(:,i_sev)))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_alpha_closed(all_severity(:,i_sev)))),SE_A_pdBSP(:,i_sev));
    er.Color = [0 0 0];

    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '','Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,5,6,]);
    title(['pdBSI: Alpha (8-12 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.02]);
%%% ANOVA %%%
[~,~,stats] = anovan(pdBSP_ear_alpha_closed,{severity},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%%%   NO SIGNIFICANT DIFFERENCES %%%
    
    %%
%%%pdBSI at beta%%%

i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%beta%%%
tp9_beta_closed = avg_closed_all_chan_eeg(beta_bins,1,:);
tp10_beta_closed = avg_closed_all_chan_eeg(beta_bins,4,:);

pdBSP_ear_beta_closed = squeeze(nanmean(abs(((tp9_beta_closed - tp10_beta_closed) ./ (tp9_beta_closed + tp10_beta_closed))),1));

% %%%375 participants%%%
% tp9_beta_closed_375 = avg_closed_all_chan_eeg_375(beta_bins,1,:);
% tp10_beta_closed_375 = avg_closed_all_chan_eeg_375(beta_bins,4,:);
% % pdBSP_ear_beta_closed_375 = zeros(51,1)+0.02;


pdBSP_ear_beta_closed = squeeze(nanmean(abs(((tp9_beta_closed - tp10_beta_closed) ./ (tp9_beta_closed + tp10_beta_closed))),1));
% pdBSP_ear_beta_closed_375 = squeeze(nanmean(abs(((tp9_beta_closed_375 - tp10_beta_closed_375) ./ (tp9_beta_closed_375 + tp10_beta_closed_375))),1));

SE_B_pdBSP_control = std(nonzeros(pdBSP_ear_beta_closed.*severity_control))/sqrt(sum(severity_control));
SE_B_pdBSP_small = std(nonzeros(pdBSP_ear_beta_closed.*severity_small))/sqrt(sum(severity_small));
SE_B_pdBSP_moderate = std(nonzeros(pdBSP_ear_beta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_B_pdBSP_large = std(nonzeros(pdBSP_ear_beta_closed.*severity_large))/sqrt(sum(severity_large));
SE_B_pdBSP = [SE_B_pdBSP_control,SE_B_pdBSP_small,SE_B_pdBSP_moderate,SE_B_pdBSP_large];
% SE_pdBSP_375_beta = std(pdBSP_ear_beta_closed_375)/sqrt(51);

%%%now plot the pdBSI for beta%%%
i_count = 1;
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_beta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_beta_closed_375)),SE_pdBSP_375_beta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(3:4) = bar(i_count,nanmean((pdBSP_ear_beta_closed(all_severity(:,i_sev)))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_beta_closed(all_severity(:,i_sev)))),SE_B_pdBSP(:,i_sev));
    er.Color = [0 0 0];

    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '','Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,5,6,]);
    title(['pdBSI: Beta (13-31 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.03]);
%%% ANOVA %%%
[~,~,stats] = anovan(pdBSP_ear_alpha_closed,{severity},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%%%   NO SIGNIFICANT DIFFERENCES %%%
    
    %%
%%%pdBSI at gamma%%%
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%gamma%%%
tp9_gamma_closed = avg_closed_all_chan_eeg(gamma_bins,1,:);
tp10_gamma_closed = avg_closed_all_chan_eeg(gamma_bins,4,:);

pdBSP_ear_gamma_closed = squeeze(nanmean(abs(((tp9_gamma_closed - tp10_gamma_closed) ./ (tp9_gamma_closed + tp10_gamma_closed))),1));

%%%375 participants%%%
% tp9_gamma_closed_375 = avg_closed_all_chan_eeg_375(gamma_bins,1,:);
% tp10_gamma_closed_375 = avg_closed_all_chan_eeg_375(gamma_bins,4,:);
% pdBSP_ear_gamma_closed_375 = zeros(51,1)+0.02;


pdBSP_ear_gamma_closed = squeeze(nanmean(abs(((tp9_gamma_closed - tp10_gamma_closed) ./ (tp9_gamma_closed + tp10_gamma_closed))),1));
% pdBSP_ear_gamma_closed_375 = squeeze(nanmean(abs(((tp9_gamma_closed_375 - tp10_gamma_closed_375) ./ (tp9_gamma_closed_375 + tp10_gamma_closed_375))),1));

SE_G_pdBSP_control = std(nonzeros(pdBSP_ear_gamma_closed.*severity_control))/sqrt(sum(severity_control));
SE_G_pdBSP_small = std(nonzeros(pdBSP_ear_gamma_closed.*severity_small))/sqrt(sum(severity_small));
SE_G_pdBSP_moderate = std(nonzeros(pdBSP_ear_gamma_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_G_pdBSP_large = std(nonzeros(pdBSP_ear_gamma_closed.*severity_large))/sqrt(sum(severity_large));
SE_G_pdBSP = [SE_G_pdBSP_control,SE_G_pdBSP_small,SE_G_pdBSP_moderate,SE_G_pdBSP_large];
% SE_pdBSP_375_gamma = std(pdBSP_ear_gamma_closed_375)/sqrt(51);

%%%now plot the pdBSI for gamma%%%
i_count = 1;
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_gamma_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_gamma_closed_375)),SE_pdBSP_375_gamma(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(1:2) = bar(i_count,nanmean((pdBSP_ear_gamma_closed(all_severity(:,i_sev)))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_gamma_closed(all_severity(:,i_sev)))),SE_G_pdBSP(:,i_sev));
    er.Color = [0 0 0];

    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '','Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,5,6,]);
    title(['pdBSI: gamma (32-100 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.04]);


%%
%%%pdBSI at delta%%%
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%delta%%%
tp9_delta_closed = avg_closed_all_chan_eeg(delta_bins,1,:);
tp10_delta_closed = avg_closed_all_chan_eeg(delta_bins,4,:);

pdBSP_ear_delta_closed = squeeze(nanmean(abs(((tp9_delta_closed - tp10_delta_closed) ./ (tp9_delta_closed + tp10_delta_closed))),1));

%%%375 participants%%%
% tp9_delta_closed_375 = avg_closed_all_chan_eeg_375(delta_bins,1,:);
% tp10_delta_closed_375 = avg_closed_all_chan_eeg_375(delta_bins,4,:);

% pdBSP_ear_delta_closed_375 = squeeze(nanmean(abs(((tp9_delta_closed_375 - tp10_delta_closed_375) ./ (tp9_delta_closed_375 + tp10_delta_closed_375))),1));

SE_D_pdBSP_control = std(nonzeros(pdBSP_ear_delta_closed.*severity_control))/sqrt(sum(severity_control));
SE_D_pdBSP_small = std(nonzeros(pdBSP_ear_delta_closed.*severity_small))/sqrt(sum(severity_small));
SE_D_pdBSP_moderate = std(nonzeros(pdBSP_ear_delta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_D_pdBSP_large = std(nonzeros(pdBSP_ear_delta_closed.*severity_large))/sqrt(sum(severity_large));
SE_D_pdBSP_all = [SE_D_pdBSP_control,SE_D_pdBSP_small,SE_D_pdBSP_moderate,SE_D_pdBSP_large];
% SE_pdBSP_375_delta = std(pdBSP_ear_delta_closed_375)/sqrt(51);
i_count = 1;
%%%now plot the pdBSI for Delta%%%
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_delta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_delta_closed_375)),SE_pdBSP_375_delta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(1:2) = bar(i_count,nanmean((pdBSP_ear_delta_closed(all_severity(:,i_sev)))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean((pdBSP_ear_delta_closed(all_severity(:,i_sev)))),SE_D_pdBSP_all(:,i_sev));
    er.Color = [0 0 0];

    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'','','Control','Small','Moderate','Severe','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,5,6,]);
    title(['pdBSI: Delta (0.5-3 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.05]);
%%% ANOVA %%%
[~,~,stats] = anovan(pdBSP_ear_delta_closed,{severity},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%%%   NO SIGNIFICANT DIFFERENCES %%%



%%
%%%Each participant Across All Hz
%%%pdBSP (tp9 - tp10/tp9+tp10) + (af7-af8/af7+af8) / 2
%%%pdBSP abs((tp9 - tp10/tp9+tp10) + (af7-af8/af7+af8))

%%%all Hz%%%
tp9_all_closed = avg_closed_all_chan_eeg(:,1,:);
af7_all_closed = avg_closed_all_chan_eeg(:,2,:);
af8_all_closed = avg_closed_all_chan_eeg(:,3,:);
tp10_all_closed = avg_closed_all_chan_eeg(:,4,:);

tp9_all_open = avg_open_all_chan_eeg(:,1,:);
af7_all_open = avg_open_all_chan_eeg(:,2,:);
af8_all_open = avg_open_all_chan_eeg(:,3,:);
tp10_all_open = avg_open_all_chan_eeg(:,4,:);

pdBSP_head_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed)) + ((af7_all_closed - af8_all_closed) ./ (af7_all_closed + af8_all_closed))),1));
pdBSP_ear_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed))),1));

pdBSP_head_all_open = squeeze(nanmean(abs(((tp9_all_open - tp10_all_open) ./ (tp9_all_open + tp10_all_open)) + ((af7_all_open - af8_all_open) ./ (af7_all_open + af8_all_open))),1));
pdBSP_ear_all_open = squeeze(nanmean(abs(((tp9_all_open - tp10_all_open) ./ (tp9_all_open + tp10_all_open))),1));

%%%delta%%%
tp9_delta_closed = avg_closed_all_chan_eeg(delta_bins,1,:);
af7_delta_closed = avg_closed_all_chan_eeg(delta_bins,2,:);
af8_delta_closed = avg_closed_all_chan_eeg(delta_bins,3,:);
tp10_delta_closed = avg_closed_all_chan_eeg(delta_bins,4,:);

tp9_delta_open = avg_open_all_chan_eeg(delta_bins,1,:);
af7_delta_open = avg_open_all_chan_eeg(delta_bins,2,:);
af8_delta_open = avg_open_all_chan_eeg(delta_bins,3,:);
tp10_delta_open = avg_open_all_chan_eeg(delta_bins,4,:);

pdBSP_head_delta_closed = squeeze(nanmean(abs(((tp9_delta_closed - tp10_delta_closed) ./ (tp9_delta_closed + tp10_delta_closed)) + ((af7_delta_closed - af8_delta_closed) ./ (af7_delta_closed + af8_delta_closed))),1));
pdBSP_ear_delta_closed = squeeze(nanmean(abs(((tp9_delta_closed - tp10_delta_closed) ./ (tp9_delta_closed + tp10_delta_closed))),1));

pdBSP_head_delta_open = squeeze(nanmean(abs(((tp9_delta_open - tp10_delta_open) ./ (tp9_delta_open + tp10_delta_open)) + ((af7_delta_open - af8_delta_open) ./ (af7_delta_open + af8_delta_open))),1));
pdBSP_ear_delta_open = squeeze(nanmean(abs(((tp9_delta_open - tp10_delta_open) ./ (tp9_delta_open + tp10_delta_open))),1));

%%%theta%%%
tp9_theta_closed = avg_closed_all_chan_eeg(theta_bins,1,:);
af7_theta_closed = avg_closed_all_chan_eeg(theta_bins,2,:);
af8_theta_closed = avg_closed_all_chan_eeg(theta_bins,3,:);
tp10_theta_closed = avg_closed_all_chan_eeg(theta_bins,4,:);

tp9_theta_open = avg_open_all_chan_eeg(theta_bins,1,:);
af7_theta_open = avg_open_all_chan_eeg(theta_bins,2,:);
af8_theta_open = avg_open_all_chan_eeg(theta_bins,3,:);
tp10_theta_open = avg_open_all_chan_eeg(theta_bins,4,:);

pdBSP_head_theta_closed = squeeze(nanmean(abs(((tp9_theta_closed - tp10_theta_closed) ./ (tp9_theta_closed + tp10_theta_closed)) + ((af7_theta_closed - af8_theta_closed) ./ (af7_theta_closed + af8_theta_closed))),1));
pdBSP_ear_theta_closed = squeeze(nanmean(abs(((tp9_theta_closed - tp10_theta_closed) ./ (tp9_theta_closed + tp10_theta_closed))),1));

pdBSP_head_theta_open = squeeze(nanmean(abs(((tp9_theta_open - tp10_theta_open) ./ (tp9_theta_open + tp10_theta_open)) + ((af7_theta_open - af8_theta_open) ./ (af7_theta_open + af8_theta_open))),1));
pdBSP_ear_theta_open = squeeze(nanmean(abs(((tp9_theta_open - tp10_theta_open) ./ (tp9_theta_open + tp10_theta_open))),1));

%%%alpha%%%
tp9_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,1,:);
af7_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,2,:);
af8_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,3,:);
tp10_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,4,:);

tp9_alpha_open = avg_open_all_chan_eeg(alpha_bins,1,:);
af7_alpha_open = avg_open_all_chan_eeg(alpha_bins,2,:);
af8_alpha_open = avg_open_all_chan_eeg(alpha_bins,3,:);
tp10_alpha_open = avg_open_all_chan_eeg(alpha_bins,4,:);

pdBSP_head_alpha_closed = squeeze(nanmean(abs(((tp9_alpha_closed - tp10_alpha_closed) ./ (tp9_alpha_closed + tp10_alpha_closed)) + ((af7_alpha_closed - af8_alpha_closed) ./ (af7_alpha_closed + af8_alpha_closed))),1));
pdBSP_ear_alpha_closed = squeeze(nanmean(abs(((tp9_alpha_closed - tp10_alpha_closed) ./ (tp9_alpha_closed + tp10_alpha_closed))),1));

pdBSP_head_alpha_open = squeeze(nanmean(abs(((tp9_alpha_open - tp10_alpha_open) ./ (tp9_alpha_open + tp10_alpha_open)) + ((af7_alpha_open - af8_alpha_open) ./ (af7_alpha_open + af8_alpha_open))),1));
pdBSP_ear_alpha_open = squeeze(nanmean(abs(((tp9_alpha_open - tp10_alpha_open) ./ (tp9_alpha_open + tp10_alpha_open))),1));

%%%beta%%%
tp9_beta_closed = avg_closed_all_chan_eeg(beta_bins,1,:);
af7_beta_closed = avg_closed_all_chan_eeg(beta_bins,2,:);
af8_beta_closed = avg_closed_all_chan_eeg(beta_bins,3,:);
tp10_beta_closed = avg_closed_all_chan_eeg(beta_bins,4,:);

tp9_beta_open = avg_open_all_chan_eeg(beta_bins,1,:);
af7_beta_open = avg_open_all_chan_eeg(beta_bins,2,:);
af8_beta_open = avg_open_all_chan_eeg(beta_bins,3,:);
tp10_beta_open = avg_open_all_chan_eeg(beta_bins,4,:);

pdBSP_head_beta_closed = squeeze(nanmean(abs(((tp9_beta_closed - tp10_beta_closed) ./ (tp9_beta_closed + tp10_beta_closed)) + ((af7_beta_closed - af8_beta_closed) ./ (af7_beta_closed + af8_beta_closed))),1));
pdBSP_ear_beta_closed = squeeze(nanmean(abs(((tp9_beta_closed - tp10_beta_closed) ./ (tp9_beta_closed + tp10_beta_closed))),1));

pdBSP_head_beta_open = squeeze(nanmean(abs(((tp9_beta_open - tp10_beta_open) ./ (tp9_beta_open + tp10_beta_open)) + ((af7_beta_open - af8_beta_open) ./ (af7_beta_open + af8_beta_open))),1));
pdBSP_ear_beta_open = squeeze(nanmean(abs(((tp9_beta_open - tp10_beta_open) ./ (tp9_beta_open + tp10_beta_open))),1));

%%%gamma%%%
tp9_gamma_closed = avg_closed_all_chan_eeg(gamma_bins,1,:);
af7_gamma_closed = avg_closed_all_chan_eeg(gamma_bins,2,:);
af8_gamma_closed = avg_closed_all_chan_eeg(gamma_bins,3,:);
tp10_gamma_closed = avg_closed_all_chan_eeg(gamma_bins,4,:);

tp9_gamma_open = avg_open_all_chan_eeg(gamma_bins,1,:);
af7_gamma_open = avg_open_all_chan_eeg(gamma_bins,2,:);
af8_gamma_open = avg_open_all_chan_eeg(gamma_bins,3,:);
tp10_gamma_open = avg_open_all_chan_eeg(gamma_bins,4,:);

pdBSP_head_gamma_closed = squeeze(nanmean(abs(((tp9_gamma_closed - tp10_gamma_closed) ./ (tp9_gamma_closed + tp10_gamma_closed)) + ((af7_gamma_closed - af8_gamma_closed) ./ (af7_gamma_closed + af8_gamma_closed))),1));
pdBSP_ear_gamma_closed = squeeze(nanmean(abs(((tp9_gamma_closed - tp10_gamma_closed) ./ (tp9_gamma_closed + tp10_gamma_closed))),1));

pdBSP_head_gamma_open = squeeze(nanmean(abs(((tp9_gamma_open - tp10_gamma_open) ./ (tp9_gamma_open + tp10_gamma_open)) + ((af7_gamma_open - af8_gamma_open) ./ (af7_gamma_open + af8_gamma_open))),1));
pdBSP_ear_gamma_open = squeeze(nanmean(abs(((tp9_gamma_open - tp10_gamma_open) ./ (tp9_gamma_open + tp10_gamma_open))),1));

%%%all Hz
figure;

subplot(2,2,1);
hold on;
B(1:2) = bar(pdBSP_head_all_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_all_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: All Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,2);
hold on;
B(1:2) = bar(pdBSP_ear_all_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_all_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: All Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,3);
hold on;
B(1:2) = bar(pdBSP_head_all_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_all_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: All Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,4);
hold on;
B(1:2) = bar(pdBSP_ear_all_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_all_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: All Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

%%%delta
figure;

subplot(2,2,1);
hold on;
B(1:2) = bar(pdBSP_head_delta_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_delta_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Delta Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,2);
hold on;
B(1:2) = bar(pdBSP_ear_delta_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_delta_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Delta Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,3);
hold on;
B(1:2) = bar(pdBSP_head_delta_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_delta_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Delta Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,4);
hold on;
B(1:2) = bar(pdBSP_ear_delta_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_delta_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Delta Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

%%%theta
figure;

subplot(2,2,1);
hold on;
B(1:2) = bar(pdBSP_head_theta_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_theta_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Theta Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,2);
hold on;
B(1:2) = bar(pdBSP_ear_theta_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_theta_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Theta Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,3);
hold on;
B(1:2) = bar(pdBSP_head_theta_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_theta_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Theta Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,4);
hold on;
B(1:2) = bar(pdBSP_ear_theta_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_theta_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Theta Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

%%%alpha
figure;

subplot(2,2,1);
hold on;
B(1:2) = bar(pdBSP_head_alpha_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_alpha_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Alpha Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,2);
hold on;
B(1:2) = bar(pdBSP_ear_alpha_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_alpha_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Alpha Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,3);
hold on;
B(1:2) = bar(pdBSP_head_alpha_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_alpha_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Alpha Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,4);
hold on;
B(1:2) = bar(pdBSP_ear_alpha_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_alpha_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Alpha Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

%%%beta
figure;

subplot(2,2,1);
hold on;
B(1:2) = bar(pdBSP_head_beta_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_beta_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Beta Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,2);
hold on;
B(1:2) = bar(pdBSP_ear_beta_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_beta_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Beta Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,3);
hold on;
B(1:2) = bar(pdBSP_head_beta_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_beta_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Beta Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,4);
hold on;
B(1:2) = bar(pdBSP_ear_beta_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_beta_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Beta Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

%%%gamma
figure;

subplot(2,2,1);
hold on;
B(1:2) = bar(pdBSP_head_gamma_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_gamma_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Gamma Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,2);
hold on;
B(1:2) = bar(pdBSP_ear_gamma_closed.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_gamma_closed.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Gamma Hz: Closed'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,3);
hold on;
B(1:2) = bar(pdBSP_head_gamma_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_head_gamma_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP All Electrodes: Gamma Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});

subplot(2,2,4);
hold on;
B(1:2) = bar(pdBSP_ear_gamma_open.*patients,'r','LineWidth',3);
B(3:4) = bar(pdBSP_ear_gamma_open.*controls,'b','LineWidth',3);
hold off;

set(gca,'FontSize',16,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[1:length(parts)]);
ylabel('Hemisphere Dissimilarity','FontSize', 20,'FontWeight', 'bold');
xlabel('Participant','FontSize', 20,'FontWeight', 'bold');
title(['pdBSP Ear Electrodes: Gamma Hz: Open'],'FontSize', 24,'FontWeight', 'bold');
legend(B([2,4]),{'Patients';'Controls'});
%%
%%% spectral of pdBSI (TP9 + TP10) by severity%%%

%%%all Hz%%%
tp9_all_closed = avg_closed_all_chan_eeg(:,1,:);
af7_all_closed = avg_closed_all_chan_eeg(:,2,:);
af8_all_closed = avg_closed_all_chan_eeg(:,3,:);
tp10_all_closed = avg_closed_all_chan_eeg(:,4,:);

tp9_all_open = avg_open_all_chan_eeg(:,1,:);
af7_all_open = avg_open_all_chan_eeg(:,2,:);
af8_all_open = avg_open_all_chan_eeg(:,3,:);
tp10_all_open = avg_open_all_chan_eeg(:,4,:);

%375 participants
% tp9_all_closed_375 = avg_closed_all_chan_eeg_375(:,1,:);
% tp10_all_closed_375 = avg_closed_all_chan_eeg_375(:,4,:);

pdBSP_spectra = (squeeze(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed)))).');
% pdBSP_spectra_375 = (squeeze(abs(((tp9_all_closed_375 - tp10_all_closed_375) ./ (tp9_all_closed_375 + tp10_all_closed_375)))).');

%First Attempt
% figure
%     hold on
% %     plot(F,nanmean(pdBSP_spectra_375(:,:),1),'LineWidth',3);
%     [hl,hr] = boundedline(F,nanmean(pdBSP_spectra_375),nanstd(pdBSP_spectra_375)/sqrt(51),colour_list(i_count),'alpha');
%     set(hl,'linewidth',3);
%     i_count = i_count + 1;
%     hold off
%     for i_sev = 1:4
%         if i_sev == 1
%             group = [1;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1];
%             group_index = find(group == 1);
%         elseif i_sev == 2
%             group = [0;1;0;0;0;1;1;0;1;0;0;0;0;0;0;1;0];
%             group_index = find(group == 1);
%         elseif i_sev == 3
%             group = [0;0;1;1;1;0;0;1;0;1;1;0;0;0;0;0;0];
%             group_index = find(group == 1);
%         else group = [0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0];
%             group_index = find(group == 1);
%         end
%         hold on
% %         plot(F,nanmean(pdBSP_spectra(group_index,:),1),'LineWidth',3);
%         [hl,hr] = boundedline(F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha');
%         set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
%         set(hl,'linewidth',3);
%         i_count = i_count + 1;
%         hold off
%         
%         
%     end
 

%Second Attempt
            group_1 = [1;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1;1;0;1;0;1;1;0;1];
            group_index_1 = find(group_1 == 1);
            group_2 = [0;1;0;0;0;1;1;0;1;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0];
            group_index_2 = find(group_2 == 1);
            group_3 = [0;0;1;1;1;0;0;1;0;1;1;0;0;0;0;0;0;0;1;0;1;0;0;0;0];
            group_index_3 = find(group_3 == 1);
            group_4 = [0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0;0;0;0;0;0;0;1;0];
            group_index_4 = find(group_4 == 1);

   figure 
    
            [hl,hr] = boundedline(...
            F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'c','alpha',...
            F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'g','alpha',...
            F,nanmean(pdBSP_spectra(group_index_3,:),1),nanstd(pdBSP_spectra(group_index_3,:),[],1)/sqrt(length(parts(group_index_3))),'m','alpha',...
            F,nanmean(pdBSP_spectra(group_index_4,:),1),nanstd(pdBSP_spectra(group_index_4,:),[],1)/sqrt(length(parts(group_index_4))),'r','alpha');
        set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
        set(hl,'linewidth',3);
    
        legend({'Controls','Small','Moderate','Severe',});
        xlim([0 30])
        ylabel('Brain Symmetry Index','FontSize', 14,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
        title('pdBSI Spectra','FontSize', 16,'FontWeight', 'bold');
%%       
%%spectra of pdBSI (TP9 + TP10) with all stroke grouped together
        
stroke_patients = sum(all_severity(:,[2:4]),2)


%%%all Hz%%%
tp9_all_closed = avg_closed_all_chan_eeg(:,1,:);
af7_all_closed = avg_closed_all_chan_eeg(:,2,:);
af8_all_closed = avg_closed_all_chan_eeg(:,3,:);
tp10_all_closed = avg_closed_all_chan_eeg(:,4,:);

tp9_all_open = avg_open_all_chan_eeg(:,1,:);
af7_all_open = avg_open_all_chan_eeg(:,2,:);
af8_all_open = avg_open_all_chan_eeg(:,3,:);
tp10_all_open = avg_open_all_chan_eeg(:,4,:);

%375 participants
% tp9_all_closed_375 = avg_closed_all_chan_eeg_375(:,1,:);
% tp10_all_closed_375 = avg_closed_all_chan_eeg_375(:,4,:);

pdBSP_spectra = (squeeze(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed)))).');
% pdBSP_spectra_375 = (squeeze(abs(((tp9_all_closed_375 - tp10_all_closed_375) ./ (tp9_all_closed_375 + tp10_all_closed_375)))).');

%First Attempt
% figure
%     hold on
% %     plot(F,nanmean(pdBSP_spectra_375(:,:),1),'LineWidth',3);
%     [hl,hr] = boundedline(F,nanmean(pdBSP_spectra_375),nanstd(pdBSP_spectra_375)/sqrt(51),colour_list(i_count),'alpha');
%     set(hl,'linewidth',3);
%     i_count = i_count + 1;
%     hold off
%     for i_sev = 1:4
%         if i_sev == 1
%             group = [1;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1];
%             group_index = find(group == 1);
%         elseif i_sev == 2
%             group = [0;1;0;0;0;1;1;0;1;0;0;0;0;0;0;1;0];
%             group_index = find(group == 1);
%         elseif i_sev == 3
%             group = [0;0;1;1;1;0;0;1;0;1;1;0;0;0;0;0;0];
%             group_index = find(group == 1);
%         else group = [0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0];
%             group_index = find(group == 1);
%         end
%         hold on
% %         plot(F,nanmean(pdBSP_spectra(group_index,:),1),'LineWidth',3);
%         [hl,hr] = boundedline(F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha',...
%             F,nanmean(pdBSP_spectra(group_index,:),1),nanstd(pdBSP_spectra(group_index,:),[],1)/sqrt(length(parts(group_index))),colour_list(i_count),'alpha');
%         set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
%         set(hl,'linewidth',3);
%         i_count = i_count + 1;
%         hold off
%         
%         
%     end
 

%Second Attempt
            group_1 = [1;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1;1;0;1;0;1;1;0;1];
            group_index_1 = find(group_1 == 1);
            group_2 = stroke_patients;
            group_index_2 = find(group_2 == 1);


   figure 
    
            [hl,hr] = boundedline(...
            F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'c','alpha',...
            F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'g','alpha');
        set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
        set(hl,'linewidth',3);
    
        legend({'Control','Stroke';});
        xlim([0 30]);
        ylabel('Brain Symmetry Index','FontSize', 14,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
        title('pdBSI Spectra','FontSize', 16,'FontWeight', 'bold');
        

%%
%%%Graphing pdBSI by group, not severity%%%
stroke_patients = sum(all_severity(:,[2:4]),2);
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;


%%%all Hz%%%
tp9_all_closed = avg_closed_all_chan_eeg(:,1,:);
af7_all_closed = avg_closed_all_chan_eeg(:,2,:);
af8_all_closed = avg_closed_all_chan_eeg(:,3,:);
tp10_all_closed = avg_closed_all_chan_eeg(:,4,:);

tp9_all_open = avg_open_all_chan_eeg(:,1,:);
af7_all_open = avg_open_all_chan_eeg(:,2,:);
af8_all_open = avg_open_all_chan_eeg(:,3,:);
tp10_all_open = avg_open_all_chan_eeg(:,4,:);

% %%%375 participants%%%
% tp9_all_closed_375 = avg_closed_all_chan_eeg_375(:,1,:);
% tp10_all_closed_375 = avg_closed_all_chan_eeg_375(:,4,:);


pdBSP_ear_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed))),1));
% pdBSP_ear_all_closed_375 = squeeze(nanmean(abs(((tp9_all_closed_375 - tp10_all_closed_375) ./ (tp9_all_closed_375 + tp10_all_closed_375))),1));

SE_pdBSP_control = std(nonzeros(pdBSP_ear_all_closed.*severity_control))/sqrt(sum(severity_control));
SE_pdBSP_small = std(nonzeros(pdBSP_ear_all_closed.*severity_small))/sqrt(sum(severity_small));
SE_pdBSP_moderate = std(nonzeros(pdBSP_ear_all_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_pdBSP_large = std(nonzeros(pdBSP_ear_all_closed.*severity_large))/sqrt(sum(severity_large));
% SE_pdBSP_375 = std(pdBSP_ear_all_closed_375)/sqrt(51);
SE_pdBSP_all = [SE_pdBSP_control,SE_pdBSP_small,SE_pdBSP_moderate,SE_pdBSP_large];
SE_pdBSP_stroke = std(nonzeros(pdBSP_ear_all_closed.*stroke_patients))/sqrt(sum(stroke_patients));


%%%now plot the pdBSI%%%
figure;


    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_all_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_all_closed_375)),SE_pdBSP_375(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(3:4) = bar(2,nanmean((pdBSP_ear_all_closed(all_severity(:,1)))),'c','LineWidth',3);
    B(5:6) = bar(3,nanmean(nonzeros((pdBSP_ear_all_closed.*stroke_patients))),'y','LineWidth',3);
    
    er = errorbar(2,nanmean((pdBSP_ear_all_closed(all_severity(:,1)))),SE_pdBSP_all(:,1));
    er.Color = [0 0 0];
    
    er = errorbar(3,nanmean(nonzeros((pdBSP_ear_all_closed.*stroke_patients))),SE_pdBSP_stroke);
    er.Color = [0 0 0];

    hold off;



    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '','Control','Stroke','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Group','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,]);
    title(['pdBSI: all frequencies at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.03]);
%%% ANOVA %%%
severity_stroke_control = {'Control','Stroke','Stroke','Stroke','Stroke','Stroke','Stroke',...
     'Stroke','Stroke','Stroke','Stroke','Stroke','Control','Stroke','Control','Stroke',...
     'Control','Control','Stroke','Control','Stroke','Control','Control','Stroke','Control'};
[~,~,stats] = anovan(pdBSP_ear_all_closed,{severity_stroke_control},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%% SIGNIFICANT DIFFERENCE, 0.036 %%% 

%%
%%%pdBSI at delta by group%%%
stroke_patients = sum(all_severity(:,[2:4]),2);
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%delta%%%
tp9_delta_closed = avg_closed_all_chan_eeg(delta_bins,1,:);
tp10_delta_closed = avg_closed_all_chan_eeg(delta_bins,4,:);

pdBSP_ear_delta_closed = squeeze(nanmean(abs(((tp9_delta_closed - tp10_delta_closed) ./ (tp9_delta_closed + tp10_delta_closed))),1));

%%%375 participants%%%
% tp9_delta_closed_375 = avg_closed_all_chan_eeg_375(delta_bins,1,:);
% tp10_delta_closed_375 = avg_closed_all_chan_eeg_375(delta_bins,4,:);
% 
% pdBSP_ear_delta_closed_375 = squeeze(nanmean(abs(((tp9_delta_closed_375 - tp10_delta_closed_375) ./ (tp9_delta_closed_375 + tp10_delta_closed_375))),1));

SE_D_pdBSP_control = std(nonzeros(pdBSP_ear_delta_closed.*severity_control))/sqrt(sum(severity_control));
SE_D_pdBSP_small = std(nonzeros(pdBSP_ear_delta_closed.*severity_small))/sqrt(sum(severity_small));
SE_D_pdBSP_moderate = std(nonzeros(pdBSP_ear_delta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_D_pdBSP_large = std(nonzeros(pdBSP_ear_delta_closed.*severity_large))/sqrt(sum(severity_large));
SE_D_pdBSP_all = [SE_D_pdBSP_control,SE_D_pdBSP_small,SE_D_pdBSP_moderate,SE_D_pdBSP_large];
% SE_pdBSP_375_delta = std(pdBSP_ear_delta_closed_375)/sqrt(51);
SE_D_pdBSP_stroke = std(nonzeros(pdBSP_ear_delta_closed.*stroke_patients))/sqrt(sum(stroke_patients));

%%%now plot the pdBSI for Delta%%%
figure;


    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_delta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_delta_closed_375)),SE_pdBSP_375_delta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(3:4) = bar(2,nanmean((pdBSP_ear_delta_closed(all_severity(:,1)))),'c','LineWidth',3);
    B(5:6) = bar(3,nanmean(nonzeros((pdBSP_ear_delta_closed.*stroke_patients))),'y','LineWidth',3);

    er = errorbar(2,nanmean((pdBSP_ear_delta_closed(all_severity(:,1)))),SE_D_pdBSP_all(:,1));
    er.Color = [0 0 0];
    
    er = errorbar(3,nanmean(nonzeros((pdBSP_ear_delta_closed.*stroke_patients))),SE_D_pdBSP_stroke);
    er.Color = [0 0 0];

    hold off;
    
  

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '375 Controls','Control','Stroke','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Group','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,]);
    title(['pdBSI: Delta (0.5-3 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.05]);

%%% ANOVA %%%
severity_stroke_control = {'Control','Stroke','Stroke','Stroke','Stroke','Stroke','Stroke',...
     'Stroke','Stroke','Stroke','Stroke','Stroke','Control','Stroke','Control','Stroke',...
     'Control','Control','Stroke','Control','Stroke','Control','Control','Stroke','Control'};
[~,~,stats] = anovan(pdBSP_ear_delta_closed,{severity_stroke_control},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%% NO SIGNIFICANT DIFFERENCE %%% 

    
%%
%%%pdBSI at theta by group%%%
stroke_patients = sum(all_severity(:,[2:4]),2);
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%theta%%%
tp9_theta_closed = avg_closed_all_chan_eeg(theta_bins,1,:);
tp10_theta_closed = avg_closed_all_chan_eeg(theta_bins,4,:);

pdBSP_ear_theta_closed = squeeze(nanmean(abs(((tp9_theta_closed - tp10_theta_closed) ./ (tp9_theta_closed + tp10_theta_closed))),1));

% %%%375 participants%%%
% tp9_theta_closed_375 = avg_closed_all_chan_eeg_375(theta_bins,1,:);
% tp10_theta_closed_375 = avg_closed_all_chan_eeg_375(theta_bins,4,:);


pdBSP_ear_theta_closed = squeeze(nanmean(abs(((tp9_theta_closed - tp10_theta_closed) ./ (tp9_theta_closed + tp10_theta_closed))),1));
% pdBSP_ear_theta_closed_375 = squeeze(nanmean(abs(((tp9_theta_closed_375 - tp10_theta_closed_375) ./ (tp9_theta_closed_375 + tp10_theta_closed_375))),1));

SE_T_pdBSP_control = std(nonzeros(pdBSP_ear_theta_closed.*severity_control))/sqrt(sum(severity_control));
SE_T_pdBSP_small = std(nonzeros(pdBSP_ear_theta_closed.*severity_small))/sqrt(sum(severity_small));
SE_T_pdBSP_moderate = std(nonzeros(pdBSP_ear_theta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_T_pdBSP_large = std(nonzeros(pdBSP_ear_theta_closed.*severity_large))/sqrt(sum(severity_large));
SE_T_pdBSP = [SE_T_pdBSP_control,SE_T_pdBSP_small,SE_T_pdBSP_moderate,SE_T_pdBSP_large];
% SE_pdBSP_375_theta = std(pdBSP_ear_theta_closed_375)/sqrt(51);
SE_T_pdBSP_stroke = std(nonzeros(pdBSP_ear_theta_closed.*stroke_patients))/sqrt(sum(stroke_patients));

%%%now plot the pdBSI for theta%%%
figure;

    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_theta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_theta_closed_375)),SE_pdBSP_375_theta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(3:4) = bar(2,nanmean((pdBSP_ear_theta_closed(all_severity(:,1)))),'c','LineWidth',3);
    B(5:6) = bar(3,nanmean(nonzeros((pdBSP_ear_theta_closed.*stroke_patients))),'y','LineWidth',3);

    er = errorbar(2,nanmean((pdBSP_ear_theta_closed(all_severity(:,1)))),SE_T_pdBSP(:,1));
    er.Color = [0 0 0];
    
    er = errorbar(3,nanmean(nonzeros((pdBSP_ear_theta_closed.*stroke_patients))),SE_T_pdBSP_stroke);
    er.Color = [0 0 0];
    
    hold off;
    


    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '375 Controls','Control','Stroke','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Group','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,]);
    title(['pdBSI: Theta (4-7 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.03]);
 
%%% ANOVA %%%
severity_stroke_control = {'Control','Stroke','Stroke','Stroke','Stroke','Stroke','Stroke',...
     'Stroke','Stroke','Stroke','Stroke','Stroke','Control','Stroke','Control','Stroke',...
     'Control','Control','Stroke','Control','Stroke','Control','Control','Stroke','Control'};
[~,~,stats] = anovan(pdBSP_ear_theta_closed,{severity_stroke_control},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%% NO SIGNIFICANT DIFFERENCE, trending towards significance, 0.1619 %%% 
    
%%
%%%pdBSI at alpha by group%%%

stroke_patients = sum(all_severity(:,[2:4]),2);
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%alpha%%%
tp9_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,1,:);
tp10_alpha_closed = avg_closed_all_chan_eeg(alpha_bins,4,:);

pdBSP_ear_alpha_closed = squeeze(nanmean(abs(((tp9_alpha_closed - tp10_alpha_closed) ./ (tp9_alpha_closed + tp10_alpha_closed))),1));

%%%375 participants%%%
% tp9_alpha_closed_375 = avg_closed_all_chan_eeg_375(alpha_bins,1,:);
% tp10_alpha_closed_375 = avg_closed_all_chan_eeg_375(alpha_bins,4,:);


pdBSP_ear_alpha_closed = squeeze(nanmean(abs(((tp9_alpha_closed - tp10_alpha_closed) ./ (tp9_alpha_closed + tp10_alpha_closed))),1));
% pdBSP_ear_alpha_closed_375 = squeeze(nanmean(abs(((tp9_alpha_closed_375 - tp10_alpha_closed_375) ./ (tp9_alpha_closed_375 + tp10_alpha_closed_375))),1));

SE_A_pdBSP_control = std(nonzeros(pdBSP_ear_alpha_closed.*severity_control))/sqrt(sum(severity_control));
SE_A_pdBSP_small = std(nonzeros(pdBSP_ear_alpha_closed.*severity_small))/sqrt(sum(severity_small));
SE_A_pdBSP_moderate = std(nonzeros(pdBSP_ear_alpha_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_A_pdBSP_large = std(nonzeros(pdBSP_ear_alpha_closed.*severity_large))/sqrt(sum(severity_large));
SE_A_pdBSP = [SE_A_pdBSP_control,SE_A_pdBSP_small,SE_A_pdBSP_moderate,SE_A_pdBSP_large];
% alpha = std(pdBSP_ear_alpha_closed_375)/sqrt(51);
SE_A_pdBSP_stroke = std(nonzeros(pdBSP_ear_alpha_closed.*stroke_patients))/sqrt(sum(stroke_patients));

%%%now plot the pdBSI for alpha%%%
figure;

    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_alpha_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_alpha_closed_375)),SE_pdBSP_375_alpha(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(3:4) = bar(2,nanmean((pdBSP_ear_alpha_closed(all_severity(:,1)))),'c','LineWidth',3);
    B(5:6) = bar(3,nanmean(nonzeros((pdBSP_ear_alpha_closed.*stroke_patients))),'y','LineWidth',3);

    er = errorbar(2,nanmean((pdBSP_ear_alpha_closed(all_severity(:,1)))),SE_A_pdBSP(:,1));
    er.Color = [0 0 0];
    
    er = errorbar(3,nanmean(nonzeros((pdBSP_ear_alpha_closed.*stroke_patients))),SE_A_pdBSP_stroke);
    er.Color = [0 0 0];

    hold off;
    


    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '375 Controls','Control','Stroke','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Group','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,]);
    title(['pdBSI: Alpha (8-12 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.02]);

  
%%% ANOVA %%%
severity_stroke_control = {'Control';'Stroke';'Stroke';'Stroke';'Stroke';'Stroke';'Stroke';...
     'Stroke';'Stroke';'Stroke';'Stroke';'Stroke';'Control';'Stroke';'Control';'Stroke';...
     'Control';'Control';'Stroke';'Control';'Stroke';'Control';'Control';'Stroke';'Control'};
[~,~,stats] = anovan(pdBSP_ear_alpha_closed,{severity_stroke_control},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%% NO SIGNIFICANT DIFFERENCE %%%    
    %%
%%%pdBSI at beta by group%%%
stroke_patients = sum(all_severity(:,[2:4]),2)
i_count = 1;
colour_list = ['b','c','y','m','r',];
i_sev = 1;
%%%beta%%%
tp9_beta_closed = avg_closed_all_chan_eeg(beta_bins,1,:);
tp10_beta_closed = avg_closed_all_chan_eeg(beta_bins,4,:);

pdBSP_ear_beta_closed = squeeze(nanmean(abs(((tp9_beta_closed - tp10_beta_closed) ./ (tp9_beta_closed + tp10_beta_closed))),1));

%%%375 participants%%%
% tp9_beta_closed_375 = avg_closed_all_chan_eeg_375(beta_bins,1,:);
% tp10_beta_closed_375 = avg_closed_all_chan_eeg_375(beta_bins,4,:);
% pdBSP_ear_beta_closed_375 = zeros(51,1)+0.02;


pdBSP_ear_beta_closed = squeeze(nanmean(abs(((tp9_beta_closed - tp10_beta_closed) ./ (tp9_beta_closed + tp10_beta_closed))),1));
% pdBSP_ear_beta_closed_375 = squeeze(nanmean(abs(((tp9_beta_closed_375 - tp10_beta_closed_375) ./ (tp9_beta_closed_375 + tp10_beta_closed_375))),1));

SE_B_pdBSP_control = std(nonzeros(pdBSP_ear_beta_closed.*severity_control))/sqrt(sum(severity_control));
SE_B_pdBSP_small = std(nonzeros(pdBSP_ear_beta_closed.*severity_small))/sqrt(sum(severity_small));
SE_B_pdBSP_moderate = std(nonzeros(pdBSP_ear_beta_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_B_pdBSP_large = std(nonzeros(pdBSP_ear_beta_closed.*severity_large))/sqrt(sum(severity_large));
SE_B_pdBSP = [SE_B_pdBSP_control,SE_B_pdBSP_small,SE_B_pdBSP_moderate,SE_B_pdBSP_large];
% SE_pdBSP_375_beta = std(pdBSP_ear_beta_closed_375)/sqrt(51);
SE_B_pdBSP_stroke = std(nonzeros(pdBSP_ear_beta_closed.*stroke_patients))/sqrt(sum(stroke_patients));

%%%now plot the pdBSI for beta%%%
figure;

    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_beta_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_beta_closed_375)),SE_pdBSP_375_beta(:,:));
%     er.Color = [0 0 0];
    i_count = i_count + 1;
 
    B(3:4) = bar(2,nanmean((pdBSP_ear_beta_closed(all_severity(:,1)))),'c','LineWidth',3);
    B(5:6) = bar(3,nanmean(nonzeros((pdBSP_ear_beta_closed.*stroke_patients))),'y','LineWidth',3);

    er = errorbar(2,nanmean((pdBSP_ear_beta_closed(all_severity(:,1)))),SE_B_pdBSP(:,1));
    er.Color = [0 0 0];
    er = errorbar(3,nanmean(nonzeros((pdBSP_ear_beta_closed.*stroke_patients))),SE_B_pdBSP_stroke);
    er.Color = [0 0 0];
    
    hold off;
    
   
    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'', '375 Controls','Control','Stroke','',});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Group','FontSize', 12,'FontWeight', 'bold');
    xticks([0,1,2,3,4,]);
    title(['pdBSI: Beta (13-31 Hz) at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.035]);

%%% ANOVA %%%
severity_stroke_control = {'Control','Stroke','Stroke','Stroke','Stroke','Stroke','Stroke',...
     'Stroke','Stroke','Stroke','Stroke','Stroke','Control','Stroke','Control','Stroke',...
     'Control','Control','Stroke','Control','Stroke','Control','Control','Stroke','Control'};
[~,~,stats] = anovan(pdBSP_ear_beta_closed,{severity_stroke_control},'model','linear',...
    'varnames',{'severity'});
results = multcompare(stats,'Dimension',[1,1])
%%% SIGNIFICANT DIFFERENCES, 0.0049 %%%    
%%
%%%Plot ACC data for each participant%%%

for i_part = 1:length(parts)
    figure;

    subplot(1,3,1);
    plot(1:length(closed_all_parts_chan_acc(:,1,i_part)),closed_all_parts_chan_acc(:,1,i_part));
    ylabel('X Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);

    subplot(1,3,2);
    plot(1:length(closed_all_parts_chan_acc(:,2,i_part)),closed_all_parts_chan_acc(:,2,i_part));
    ylabel('Y Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);

    subplot(1,3,3);
    plot(1:length(closed_all_parts_chan_acc(:,3,i_part)),closed_all_parts_chan_acc(:,3,i_part));
    ylabel('Z Coordinates - Eyes Closed');
    xlabel('Sample Point');
    title(['ACC for Participant ' num2str(i_part)]);
end

%%
%%% RMS for ACC data by severity
colours = {['c'],['y'],['m'],['r']};
for i_chan = 1
 figure;
    subplot(1,3,1);
    boxplot(closed_all_parts_chan_acc_rms(1,:),severity);
    ylabel('Root Mean Squares','FontSize', 12,'FontWeight', 'bold');
    title({' ';' X Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Small','Moderate','Severe'},'XTickLabelRotation',45);
    
    subplot(1,3,2);
    boxplot(closed_all_parts_chan_acc_rms(2,:),severity);
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    title({'Root Mean Squares of Accelerometer data ';' Y Plane'} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Small','Moderate','Severe'},'XTickLabelRotation',45);
    
    subplot(1,3,3);
    boxplot(closed_all_parts_chan_acc_rms(3,:),severity);
    title({' ';' Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Small','Moderate','Severe'},'XTickLabelRotation',45);
end

%%% ANOVA %%%
acc_rms = [];
acc_xyz = [];
for i_part = 1:length(parts)
   acc_rms = [acc_rms;closed_all_parts_chan_acc_rms(:,i_part)]; 
   acc_xyz = strvcat(acc_xyz, 'x','y','z');
end
i_part = 1;
severity_3 = [];
parts_3 = [];
for i_count = 1:(length(parts)*3)
    severity_3 = [severity_3;severity(i_part)];
    parts_3 = [parts_3;parts(i_part)];
    if mod(i_count,3)==0
        i_part = i_part + 1;
    end
end
acc_xyz = cellstr(acc_xyz);

[~,~,stats] = anovan(acc_rms,{severity_3 acc_xyz},'model','full',...
    'varnames',{'severity','axis'});
results = multcompare(stats,'Dimension',[1,2])
%%% SIGNIFICANT DIFFERENCES in all forms, severity, only signifigant difference
%%% in X axis between severity.   

%%
%%% GYRO plot of each axis over time for each participant
i_part = 1;


for i_part = 1:length(parts)
    if all_severity(i_part,1)==1
        color = [1,0,0];
    elseif all_severity(i_part,2)==1
        color = [0,0,1];
    elseif all_severity(i_part,3)==1
        color = [0,1,0];
    else
        color = [0,1,1];
    end
    figure;
        subplot(3,1,1);
        plot(closed_all_parts_chan_gyro(:,1,i_part),'Color',color);
        xlim ([0 9000]);
        title({'Gyroscope data';' X Plane '} ,'FontSize', 12,'FontWeight', 'bold');
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','Layer','Top');
    
        subplot(3,1,2);
        plot(closed_all_parts_chan_gyro(:,2,i_part),'Color',color);
        xlim ([0 9000]);
        ylabel('Gyro Data','FontSize', 12,'FontWeight', 'bold');
        title({' ';' Y Plane'} ,'FontSize', 12,'FontWeight', 'bold');
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','Layer','Top');
    
        subplot(3,1,3);
        plot(closed_all_parts_chan_gyro(:,3,i_part),'Color',color);
        xlabel('Time','FontSize', 12,'FontWeight', 'bold');
        xlim ([0 9000]);
        title({' ';' Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','Layer','Top');
        i_part = i_part+1;
        i_sev = i_sev+1;
end


%%% RMS for gyro data by severity
for i_chan = 1
 figure;
    subplot(1,3,1);
    boxplot(closed_all_parts_chan_gyro_rms(1,:),severity);
    ylabel('Root Mean Squares','FontSize', 12,'FontWeight', 'bold');
    ylim([0,6]);
    title({' ';' X Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Small','Moderate','Severe'},'XTickLabelRotation',45);
    
    subplot(1,3,2);
    boxplot(closed_all_parts_chan_gyro_rms(2,:),severity);
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    ylim([0,6]);
    title({'Root Mean Squares of Gyroscope data ';' Y Plane'} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Small','Moderate','Severe'},'XTickLabelRotation',45);
    
    subplot(1,3,3);
    boxplot(closed_all_parts_chan_gyro_rms(3,:),severity);
    ylim([0,6]);
    title({' ';' Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Small','Moderate','Severe',},'XTickLabelRotation',45);

end

%%% ANOVA %%%
gyro_rms = [];
gyro_xyz = [];
for i_part = 1:length(parts)
   gyro_rms = [gyro_rms;closed_all_parts_chan_gyro_rms(:,i_part)]; 
   gyro_xyz = strvcat(gyro_xyz, 'x','y','z');
end
i_part = 1;
severity_3 = [];
parts_3 = [];
for i_count = 1:(length(parts)*3)
    severity_3 = [severity_3;severity(i_part)];
    parts_3 = [parts_3;parts(i_part)];
    if mod(i_count,3)==0
        i_part = i_part + 1;
    end
end
gyro_xyz = cellstr(gyro_xyz);

[~,~,stats] = anovan(gyro_rms,{severity_3 gyro_xyz},'model','full',...
    'varnames',{'severity','axis'});
results = multcompare(stats,'Dimension',[1,2])
%%% SIGNIFICANT DIFFERENCES in axis (p=0), none in interactions, moderate has
%%% some significant differences across axis

%%
%%% plot of Z vs. X for each participant
i_part = 1;

figure;
for i_part = 1:length(parts)
    if all_severity(i_part,1)==1
        color = [1,0,0];
    elseif all_severity(i_part,2)==1
        color = [0,0,1];
    elseif all_severity(i_part,3)==1
        color = [0,1,0];
    else
        color = [0,1,1];
    end


        subplot(5,5,i_part);
        plot((closed_all_parts_chan_gyro(:,1,i_part) - mean(closed_all_parts_chan_gyro(:,1,i_part))),(closed_all_parts_chan_gyro(:,3,i_part) - mean(closed_all_parts_chan_gyro(:,3,i_part))), 'Color',color);
        set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','Layer','Top')
        xlim([-30,30]);
        ylim([-30,30]);
        
        i_part = i_part+1;
 
end
    sgtitle({'Gyroscope data';' X Plane vs Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');

   
%%
%%% heat map
%%% track is our counting matrix, to keep track of how many data points are
%%% in each section. Datamatrix is to find where the data falls in relation
%%% to other points

track = zeros(2,2);
datamatrix = [1 2; 3 4];

% x_coord = {[-2,-1],[-1,0],[0,-1],[-1,-2]};
% 
% find(x_coord
time = 1:9282;
i_time = 1;
i_part = 1;

% x_min = [-60,0,60];
% x_coord = find(x_min < closed_all_parts_chan_gyro(i_time,1,i_part),1);
% z_min = [-105,0,105];
% z_coord = find(z_min > 1.5,1);
% track = zeros(4,4);
% track(z_coord,x_coord) = track(z_coord,x_coord) + 1;
% min(closed_all_parts_chan_gyro)

            group_1 = [1;0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;1;1;0;1;0;1;1;0;1];
            group_index_1 = find(group_1 == 1);
            group_2 = [0;1;0;0;0;1;1;0;1;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0];
            group_index_2 = find(group_2 == 1);
            group_3 = [0;0;1;1;1;0;0;1;0;1;1;0;0;0;0;0;0;0;1;0;1;0;0;0;0];
            group_index_3 = find(group_3 == 1);
            group_4 = [0;0;0;0;0;0;0;0;0;0;0;1;0;1;0;0;0;0;0;0;0;0;0;1;0];
            group_index_4 = find(group_4 == 1);
            severity_index = [1,2,3,3,3,2,2,3,2,3,3,4,1,4,1,2,1,1,3,1,3,1,1,4,1];
            all_x = [];
            all_group = [];
            all_z = [];
             
            
            for i_part = 1:length(parts)
                all_x = [all_x;closed_all_parts_chan_gyro(:,1,i_part)];
                temp_group = zeros(length(closed_all_parts_chan_gyro(:,1,i_part)),1)+severity_index(i_part);
                all_group = [all_group,temp_group];
                all_z = [all_z;closed_all_parts_chan_gyro(:,3,i_part)];
                i_part = i_part+1;
            end

          
            
            
 X = [all_x,all_z];
 Y =  X(X(:,1)>=-10 & X(:,1)<=10 & X(:,2)>=-10 & X(:,2)<=10,:);
 
hist3(Y)
N = hist3(Y);

%%% seperate into serverity


%  [hl,hr] = boundedline(...
%             F,nanmean(pdBSP_spectra_375,1),nanstd(pdBSP_spectra_375)/sqrt(51),'b','alpha',...
%             F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'c','alpha',...
%             F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'g','alpha',...
%             F,nanmean(pdBSP_spectra(group_index_3,:),1),nanstd(pdBSP_spectra(group_index_3,:),[],1)/sqrt(length(parts(group_index_3))),'m','alpha',...
%             F,nanmean(pdBSP_spectra(group_index_4,:),1),nanstd(pdBSP_spectra(group_index_4,:),[],1)/sqrt(length(parts(group_index_4))),'r','alpha');
control_x = [];
control_z = [];
small_x = [];
small_z = [];
moderate_x = [];
moderate_z = [];
large_x = [];
large_z = [];
control_x = [control_x;closed_all_parts_chan_gyro(:,1,group_index_1)];
control_z = [control_z;closed_all_parts_chan_gyro(:,3,group_index_1)];
small_x = [small_x;closed_all_parts_chan_gyro(:,1,group_index_2)];
small_z = [small_z;closed_all_parts_chan_gyro(:,3,group_index_2)];
moderate_x = [moderate_x;closed_all_parts_chan_gyro(:,1,group_index_3)];
moderate_z = [moderate_z;closed_all_parts_chan_gyro(:,3,group_index_3)];
large_x = [large_x;closed_all_parts_chan_gyro(:,1,group_index_4)];
large_z = [large_z;closed_all_parts_chan_gyro(:,3,group_index_4)];


control_x_vec = control_x(:);
control_z_vec = control_z(:);
small_x_vec = small_x(:);
small_z_vec = small_z(:);
moderate_x_vec = moderate_x(:);
moderate_z_vec = moderate_z(:);
large_x_vec = large_x(:);
large_z_vec = large_z(:);


 control_comb = [control_x_vec,control_z_vec];
 small_comb = [small_x_vec,small_z_vec];
 moderate_comb = [moderate_x_vec,moderate_z_vec];
 large_comb = [large_x_vec,large_z_vec];
 
control_comb_filtered =  control_comb(control_comb(:,1)>=-5 & control_comb(:,1)<=5 & control_comb(:,2)>=-5 & control_comb(:,2)<=5,:);
small_comb_filtered =  small_comb(small_comb(:,1)>=-5 & small_comb(:,1)<=5 & small_comb(:,2)>=-5 & small_comb(:,2)<=5,:);
moderate_comb_filtered =  moderate_comb(moderate_comb(:,1)>=-5 & moderate_comb(:,1)<=5 & moderate_comb(:,2)>=-5 & moderate_comb(:,2)<=5,:);
large_comb_filtered =  large_comb(large_comb(:,1)>=-5 & large_comb(:,1)<=5 & large_comb(:,2)>=-5 & large_comb(:,2)<=5,:);


nonzero_control = control_comb_filtered(any(control_comb_filtered,2),:);
nonzero_small = small_comb_filtered(any(small_comb_filtered,2),:);
nonzero_moderate = moderate_comb_filtered(any(moderate_comb_filtered,2),:);
nonzero_large = large_comb_filtered(any(large_comb_filtered,2),:);




subplot(2,2,1)
colormap(jet)
hist3(nonzero_control,'Nbins', [200 200],'CDataMode','auto','FaceColor','interp')
title({'Control'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)
subplot(2,2,2)
hist3(nonzero_small,'Nbins', [200 200],'CDataMode','auto','FaceColor','interp')
title({'Small'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)
subplot(2,2,3)
hist3(nonzero_moderate,'Nbins', [200 200],'CDataMode','auto','FaceColor','interp')
title({'Moderate'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)
subplot(2,2,4)
hist3(nonzero_large,'Nbins', [200 200],'CDataMode','auto','FaceColor','interp')
title({'Large'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)

%%
%%% Gyroscope Heat map by location

track = zeros(2,2);
datamatrix = [1 2; 3 4];


time = 1:9282;
i_time = 1;
i_part = 1;

% 
%          stroke_loc = {'normal';'left';'left';'left';'left';'right';'right';'left';'left';'left';'left';'right';'normal';'left';'normal';'left';'normal';'normal';'left';'normal';'left';'normal';'normal';'right';'normal';'normal';};
           % Control =1, left = 2, right = 3
           loc_index = [1,2,2,2,2,3,3,2,2,2,2,3,1,2,1,2,1,1,2,1,2,1,1,3,1,1];
%             all_x = [];
%             all_group = [];
%             all_z = [];
%              
            
            for i_part = 1:length(parts)
                all_x = [all_x;closed_all_parts_chan_gyro(:,1,i_part)];
                temp_group = zeros(length(closed_all_parts_chan_gyro(:,1,i_part)),1)+loc_index(i_part);
                all_group = [all_group,temp_group];
                all_z = [all_z;closed_all_parts_chan_gyro(:,3,i_part)];
                i_part = i_part+1;
            end

       
            
 X = [all_x,all_z];
 Y =  X(X(:,1)>=-10 & X(:,1)<=10 & X(:,2)>=-10 & X(:,2)<=10,:);
 
hist3(Y)
N = hist3(Y);

control_x = [];
control_z = [];
left_x = [];
left_z = [];
right_x = [];
right_z = [];
control_x = [control_x;closed_all_parts_chan_gyro(:,1,group_index_1)];
control_z = [control_z;closed_all_parts_chan_gyro(:,3,group_index_1)];
left_x = [left_x;closed_all_parts_chan_gyro(:,1,group_index_2)];
left_z = [left_z;closed_all_parts_chan_gyro(:,3,group_index_2)];
right_x = [right_x;closed_all_parts_chan_gyro(:,1,group_index_3)];
right_z = [right_z;closed_all_parts_chan_gyro(:,3,group_index_3)];



control_x_vec = control_x(:);
control_z_vec = control_z(:);
left_x_vec = left_x(:);
left_z_vec = left_z(:);
right_x_vec = right_x(:);
right_z_vec = right_z(:);



 control_comb = [control_x_vec,control_z_vec];
 left_comb = [left_x_vec,left_z_vec];
 right_comb = [right_x_vec,right_z_vec];

 
control_comb_filtered =  control_comb(control_comb(:,1)>=-5 & control_comb(:,1)<=5 & control_comb(:,2)>=-5 & control_comb(:,2)<=5,:);
left_comb_filtered =  left_comb(left_comb(:,1)>=-5 & left_comb(:,1)<=5 & left_comb(:,2)>=-5 & left_comb(:,2)<=5,:);
right_comb_filtered =  right_comb(right_comb(:,1)>=-5 & right_comb(:,1)<=5 & right_comb(:,2)>=-5 & right_comb(:,2)<=5,:);


nonzero_control = control_comb_filtered(any(control_comb_filtered,2),:);
nonzero_left = left_comb_filtered(any(left_comb_filtered,2),:);
nonzero_right = right_comb_filtered(any(right_comb_filtered,2),:);


subplot(1,3,1)
colormap(jet)
hist3(nonzero_control,'Nbins', [25 50],'CDataMode','auto','FaceColor','interp')
title({'Control'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)
subplot(1,3,2)
hist3(nonzero_left,'Nbins', [50 50],'CDataMode','auto','FaceColor','interp')
title({'Left'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)
subplot(1,3,3)
hist3(nonzero_right,'Nbins', [50 50],'CDataMode','auto','FaceColor','interp')
title({'Right'} ,'FontSize', 12,'FontWeight', 'bold');
xlabel('Z axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
ylabel('X-axis (degrees / s)','FontSize', 12,'FontWeight', 'bold');
xlim([-2,2]);
ylim([-4,0]);
colorbar
view(2)
%%
%%% Forest analysis
%%% Variables: stroke location, PDBSI, rms ACC, rms GYRO, DAr, DTABr,
%%% age, gender, fooof intercept, fooof slope, relative band powers. 
%%% All variables are 25x1 
%%% Trying to predict the stroke severity


%%% stroke location %%%
stroke_loc;


%%% Age %%%
age; 


%%% Gender%%%
gender;

%%% Time from onset %%%


%%% PDBSI %%%
i_part = 1;
pdBSI = [];
tp9_all_closed = avg_closed_all_chan_eeg(:,1,:);
af7_all_closed = avg_closed_all_chan_eeg(:,2,:);
af8_all_closed = avg_closed_all_chan_eeg(:,3,:);
tp10_all_closed = avg_closed_all_chan_eeg(:,4,:);

tp9_all_open = avg_open_all_chan_eeg(:,1,:);
af7_all_open = avg_open_all_chan_eeg(:,2,:);
af8_all_open = avg_open_all_chan_eeg(:,3,:);
tp10_all_open = avg_open_all_chan_eeg(:,4,:);

pdBSP_head_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./...
    (tp9_all_closed + tp10_all_closed)) + ((af7_all_closed - af8_all_closed) ./ ...
    (af7_all_closed + af8_all_closed))),1));

for i_part = 1:length(parts)
    pdBSI = [pdBSI;pdBSP_head_all_closed(i_part,:)];
    i_part = i_part + 1;
end

%%%low and high frequency pdBSI %%%
pdBSP_spectra = (squeeze(abs((tp9_all_closed - tp10_all_closed) ./ ...
    (tp9_all_closed + tp10_all_closed))+ ((af7_all_closed - af8_all_closed) ./ ...
    (af7_all_closed + af8_all_closed))).');
low_spectra = [];
high_spectra = [];
low_pdBSI =[];
high_pdBSI = [];
for i_part = 1:length(parts)
    low_spectra = [low_spectra;pdBSP_spectra(i_part,1:116)];
    high_spectra = [high_spectra;pdBSP_spectra(i_part,116:end)];
    i_part = i_part + 1;
end
low_pdBSI = abs(nanmean(low_spectra,2));
high_pdBSI = abs(nanmean(high_spectra,2));

%%%front and back electrode pdBSI%%%
front_pdBSI = squeeze(nanmean(abs((af7_all_closed - af8_all_closed) ./ ...
    (af7_all_closed + af8_all_closed)),1));
back_pdBSI = squeeze(nanmean(abs((tp9_all_closed - tp10_all_closed) ./ ...
    (tp9_all_closed + tp10_all_closed)),1));


%%% GYRO + ACC %%%
i_part = 1;

rms_gyro_x =  [];
rms_gyro_y =  [];
rms_gyro_z =  [];

sd_gyro_x =  [];
sd_gyro_y =  [];
sd_gyro_z =  [];

rms_acc_x =  [];
rms_acc_y =  [];
rms_acc_z =  [];

sd_acc_x =  [];
sd_acc_y =  [];
sd_acc_z = [];

for i_part = 1:length(parts)

%%% root mean squares gyro
    rms_gyro_x =  [rms_gyro_x;closed_all_parts_chan_gyro_rms(1,i_part)];
    rms_gyro_y =  [rms_gyro_y;closed_all_parts_chan_gyro_rms(2,i_part)];
    rms_gyro_z =  [rms_gyro_z;closed_all_parts_chan_gyro_rms(3,i_part)];

%%% sd gyro
    sd_gyro_x =  [sd_gyro_x;closed_all_parts_chan_gyro_sd(1,i_part)];
    sd_gyro_y =  [sd_gyro_y;closed_all_parts_chan_gyro_sd(2,i_part)];
    sd_gyro_z =  [sd_gyro_z;closed_all_parts_chan_gyro_sd(3,i_part)];

%%% ACC %%%
%%% root mean squares acc
    rms_acc_x =  [rms_acc_x;closed_all_parts_chan_acc_rms(1,i_part)];
    rms_acc_y =  [rms_acc_y;closed_all_parts_chan_acc_rms(2,i_part)];
    rms_acc_z =  [rms_acc_z;closed_all_parts_chan_acc_rms(3,i_part)];

%%% sd acc
    sd_acc_x =  [sd_acc_x;closed_all_parts_chan_acc_sd(1,i_part)];
    sd_acc_y =  [sd_acc_y;closed_all_parts_chan_acc_sd(2,i_part)];
    sd_acc_z =  [sd_acc_z;closed_all_parts_chan_acc_sd(3,i_part)];
    
    i_part = i_part + 1;

end


%%% DELTA/ALPHA RATIO %%%
i_part = 1;
dar_g = [];
dar_b = [];

delta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(beta_bins,1,:),1),2));
gamma_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(gamma_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(beta_bins,1,:),1),2));
gamma_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(gamma_bins,1,:),1),2));

DAR_good = (delta_power_good)./(alpha_power_good);
DAR_bad = (delta_power_bad)./(alpha_power_bad);

for i_part = 1:length(parts)
    dar_g = [dar_g;DAR_good(i_part,:)];
    dar_b = [dar_b;DAR_bad(i_part,:)];
    i_part = i_part + 1;
end



%%% DELTA + THETA / ALPHA + BETA RATIO %%%
i_part = 1;
dtabr_g = [];
dtabr_b = [];

delta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(avg_closed_good_eeg(beta_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(avg_closed_bad_eeg(beta_bins,1,:),1),2));


DTABR_good = (delta_power_good+theta_power_good)./(alpha_power_good+beta_power_good);

DTABR_bad = (delta_power_bad+theta_power_bad)./(alpha_power_bad+beta_power_bad);

for i_part = 1:length(parts)
    dtabr_g = [dtabr_g;DTABR_good(i_part,:)];
    dtabr_b = [dtabr_b;DTABR_bad(i_part,:)];
    i_part = i_part + 1;
end


%%% FOOOF INTERCEPT AND SLOPE %%%
fooof_bg_intercept;
fooof_bg_slope;


%%% RELATIVE BAND POWER %%%
delta_relative = [];
theta_relative = [];
alpha_relative = [];
beta_relative = [];

relative_power = [delta_power_bad,theta_power_bad,alpha_power_bad,beta_power_bad];
total_relative = sum(relative_power,2);

i_part = 1;
for i_part = 1:length(parts)
    delta_relative = [delta_relative;delta_power_bad(i_part)./total_relative(i_part)];
    theta_relative = [theta_relative;theta_power_bad(i_part)./total_relative(i_part)];
    alpha_relative = [alpha_relative;alpha_power_bad(i_part)./total_relative(i_part)];
    beta_relative = [beta_relative;beta_power_bad(i_part)./total_relative(i_part)];
    i_part = i_part + 1;
end


%%% STROKE SEVERITY INDEX %%%  
severity_index = [1,2,3,3,3,2,2,3,2,3,3,4,1,4,1,2,1,1,3,1,3,1,1,4,1];
severity_stroke_control = {'Control','Stroke','Stroke','Stroke','Stroke','Stroke','Stroke',...
     'Stroke','Stroke','Stroke','Stroke','Stroke','Control','Stroke','Control','Stroke',...
     'Control','Control','Stroke','Control','Stroke','Control','Control','Stroke','Control'};
stroke_index = [0,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,0,1,0,1,0,0,1,0];
severity_controlsmall = {'Control or Small','Control or Small','Moderate to Large','Moderate to Large',...
    'Moderate to Large','Control or Small','Control or Small','Moderate to Large','Control or Small',...
    'Moderate to Large','Moderate to Large','Moderate to Large','Control or Small','Moderate to Large',...
    'Control or Small','Control or Small','Control or Small','Control or Small','Moderate to Large',...
    'Control or Small','Moderate to Large','Control or Small','Control or Small','Moderate to Large','Control or Small'};
control_index = [0,0,1,1,1,0,0,1,0,1,1,1,0,1,0,0,0,0,1,0,1,0,0,1,0];


%%% TABLE OF VARIABLES %%%
stroke_loc = categorical(stroke_loc);
gender = categorical(gender);
age = double(categorical(age));
tab = table(gender,age,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_g,dtabr_g,fooof_bg_intercept,...
    fooof_bg_slope,beta_relative,theta_relative,alpha_relative,delta_relative,high_pdBSI,low_pdBSI,...
    front_pdBSI,back_pdBSI);



%%% DETERMINE LEVELS IN PREDICTORS %%%
func = @(x)numel(categories(categorical(x)));
num_levels = varfun(func,tab,'OutputFormat','uniform');

figure
bar(num_levels)
title('Number of Levels Among Predictors')
xlabel('Predictor Variable')
ylabel('Number of Levels')
h = gca;
h.XTick = [1:length(tab.Properties.VariableNames)];
h.XTickLabel = tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';



%%% Train Bagged Ensemble of regression trees%%%
tree = templateTree('NumVariablesToSample','all',...
    'PredictorSelection','interaction-curvature','Surrogate','on');
rng(1); % For reproducibility
Mdl = fitrensemble(tab,severity_index,'Method','Bag','NumLearningCycles',200, ...
    'Learners',tree);

%%%estimate the model R^2 using out-of-bag predition
yHat = oobPredict(Mdl);
R2 = corr(Mdl.Y,yHat)^2

%%% importance estimation %%%
impOOB = oobPermutedPredictorImportance(Mdl);
[impGain,predAssociation] = predictorImportance(Mdl);

figure
bar(impOOB)
title('Unbiased Predictor Importance Estimates')
xlabel('Predictor variable')
ylabel('Importance')
h = gca;
h.XTick = [1:length(tab.Properties.VariableNames)];
h.XTickLabel = tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

figure
imagesc(predAssociation)
title('Predictor Association Estimates')
colorbar
h = gca;
h.XTick = [1:length(tab.Properties.VariableNames)];
h.XTickLabel = tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
h.YTick = [1:length(tab.Properties.VariableNames)];
h.YTickLabel = Mdl.PredictorNames;

predAssociation(1,2)

%%% TREEBAGGER SEVERITY %%%
rng(1);
severity_tree = TreeBagger(50,tab,severity,'Method','classification','oobpred','On','OOBPredictorImportance','on');

view(severity_tree.Trees{1},'Mode','graph');

severity_predicted = predict(severity_tree,severity);
RMSE = sqrt(nanmean(severity_predicted-severity).^2);
RMSE0 = nanstd(severity-nanmean(severity));
r_sq = 1- (RMSE-RMSE0)

[pred_severity_tree_oobseverity, pred_severity_tree_oobseverityscores] = oobPredict(severity_tree);
[conf,sev_labels] = confusionmat(severity,pred_severity_tree_oobseverity,'order',sev_labels);
disp(dataset({conf,sev_labels{:}},'obsnames',sev_labels));


%%% TREEBAGGER STROKE VS CONTROL %%%
rng(1);
stroke_tree = TreeBagger(50,tab,severity_stroke_control,'OOBPrediction','On','Method','classification');

view(stroke_tree.Trees{1},'Mode','graph');



stroke_control = {'Control','Stroke'};
[pred_stroke_tree_oobseverity, pred_stroke_tree_oobseverityscores] = oobPredict(stroke_tree);
[conf,stroke_control] = confusionmat(severity_stroke_control,pred_stroke_tree_oobseverity,'order',stroke_control);
disp(dataset({conf,stroke_control{:}},'obsnames',stroke_control));


%%% TREEBAGGER CONTROL AND SMALL VS MODERATE LARGE %%% 
rng(1);
control_small_tree = TreeBagger(50,tab,severity_controlsmall,'OOBPrediction','On','Method','classification');

view(control_small_tree.Trees{1},'Mode','graph');

tree = templateTree('NumVariablesToSample','all',...
    'PredictorSelection','interaction-curvature','Surrogate','on');


controlsmall_moderatelarge = {'Control or Small','Moderate to Large'};
[pred_control_small_tree_oobseverity, pred_control_small_tree_oobseverityscores] = oobPredict(control_small_tree);
[conf,control_small_tree] = confusionmat(severity_controlsmall,pred_control_small_tree_oobseverity,'order',controlsmall_moderatelarge);
disp(dataset({conf,controlsmall_moderatelarge{:}},'obsnames',controlsmall_moderatelarge));


%%% ONSET DECISION TREE %%%
onset_tab = table(gender,age,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_g,dtabr_g,fooof_bg_intercept,...
    fooof_bg_slope,beta_relative,theta_relative,alpha_relative,delta_relative,high_pdBSI,low_pdBSI,...
    front_pdBSI,back_pdBSI);

func = @(x)numel(categories(categorical(x)));
num_levels = varfun(func,onset_tab,'OutputFormat','uniform');

figure
bar(num_levels)
title('Number of Levels Among Predictors')
xlabel('Predictor Variable')
ylabel('Number of Levels')
h = gca;
h.XTick = [1:length(onset_tab.Properties.VariableNames)];
h.XTickLabel = onset_tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';


tree = templateTree('NumVariablesToSample','all',...
    'PredictorSelection','interaction-curvature','Surrogate','on');
rng(1); % For reproducibility
onset_tree = fitrensemble(onset_tab,onset_index,'Method','Bag','NumLearningCycles',200, ...
    'Learners',tree);

yHat = oobPredict(onset_tree);
R2 = corr(onset_tree.Y,yHat)^2

impOOB = oobPermutedPredictorImportance(onset_tree);
[impGain,predAssociation] = predictorImportance(onset_tree);

figure
bar(impOOB)
title('Unbiased Predictor Importance Estimates')
xlabel('Predictor variable')
ylabel('Importance')
h = gca;
h.XTick = [1:length(onset_tab.Properties.VariableNames)];
h.XTickLabel = onset_tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

figure
imagesc(predAssociation)
title('Predictor Association Estimates')
colorbar
h = gca;
h.XTick = [1:length(onset_tab.Properties.VariableNames)];
h.XTickLabel = onset_tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
h.YTick = [1:length(onset_tab.Properties.VariableNames)];
h.YTickLabel = onset_tree.PredictorNames;

predAssociation(1,2)

rng(1);
time_tree = TreeBagger(50,onset_tab,onset,'OOBPrediction','On','Method','classification');

view(time_tree.Trees{1},'Mode','graph');

%%% CORTICAL VS SUBCORTICAL %%%
onset_tab = table(gender,age,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_g,dtabr_g,fooof_bg_intercept,...
    fooof_bg_slope,beta_relative,theta_relative,alpha_relative,delta_relative,high_pdBSI,low_pdBSI,...
    front_pdBSI,back_pdBSI);

func = @(x)numel(categories(categorical(x)));
num_levels = varfun(func,onset_tab,'OutputFormat','uniform');

figure
bar(num_levels)
title('Number of Levels Among Predictors')
xlabel('Predictor Variable')
ylabel('Number of Levels')
h = gca;
h.XTick = [1:length(onset_tab.Properties.VariableNames)];
h.XTickLabel = onset_tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';


tree = templateTree('NumVariablesToSample','all',...
    'PredictorSelection','interaction-curvature','Surrogate','on');
rng(1); % For reproducibility
loc_tree = fitrensemble(onset_tab,loc_index,'Method','Bag','NumLearningCycles',200, ...
    'Learners',tree);

yHat = oobPredict(loc_tree);
R2 = corr(loc_tree.Y,yHat)^2

impOOB = oobPermutedPredictorImportance(loc_tree);
[impGain,predAssociation] = predictorImportance(loc_tree);

figure
bar(impOOB)
title('Unbiased Predictor Importance Estimates')
xlabel('Predictor variable')
ylabel('Importance')
h = gca;
h.XTick = [1:length(onset_tab.Properties.VariableNames)];
h.XTickLabel = onset_tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

figure
imagesc(predAssociation)
title('Predictor Association Estimates')
colorbar
h = gca;
h.XTick = [1:length(onset_tab.Properties.VariableNames)];
h.XTickLabel = onset_tab.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
h.YTick = [1:length(onset_tab.Properties.VariableNames)];
h.YTickLabel = loc_tree.PredictorNames;

predAssociation(1,2)

rng(1);
time_tree = TreeBagger(50,onset_tab,loc,'OOBPrediction','On','Method','classification');

view(time_tree.Trees{1},'Mode','graph');


%%
%%% MUTIPLE REGRESSION FOR NIHSS %%%
tab_NIHSS = table(gender_index,age,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_g,dtabr_g,fooof_bg_intercept,...
    fooof_bg_slope,beta_relative,theta_relative,alpha_relative,delta_relative,high_pdBSI,low_pdBSI,...
    front_pdBSI,back_pdBSI);
matrix_NIHSS = table2array(tab_NIHSS);

[~,~,~,~,stats] = regress(NIHSS,matrix_NIHSS)
