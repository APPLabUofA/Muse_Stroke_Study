%%
%%%file path and name information
datapath = ['M:\Data\Muse_Stroke_Study_data\Revamped\'];


%%% Pull Patient Data %%%
full_data = csvread([datapath 'Stroke_revamped_data_50.csv'],1,0);
part = ([full_data(:,2)]);
parts = cellstr(num2str(part,'%03d'));
electrodes = {'TP9';'AF7';'AF8';'TP10'};
electrodes_comb = {'TP9/TP10';'AF7/AF8'};
%%% left is 1, right is 2 %%%
stroke_loc = num2cell([full_data(:,19)]);
patients = cell2mat(stroke_loc >=1 );
controls = cell2mat(stroke_loc == 0 );
age = [full_data(:,3)];
%%% male = 1, female = 2 %%%
gender = [full_data(:,4)];
severity = [full_data(:,16)];
%%% Core and Penumbra %%%  
core = [full_data(:,13)];
penumb = [full_data(:,14)];

%%% LVO including M2
lvo = [];
i_part = 1;
for i_part= 1:length(parts)
if full_data(i_part,20) == 1
   lvo(i_part) = 1;
elseif full_data(i_part,21) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,22) == 1
  lvo(i_part) = 1;
elseif full_data(i_part,23) == 1
  lvo(i_part) = 1;
elseif full_data(i_part,24) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,25) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,30) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,31) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,32) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,33) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,34) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,35) == 1
    lvo(i_part) = 1;
elseif full_data(i_part,36) == 1
    lvo(i_part) = 1;
else lvo(i_part) = 0;
end 
 i_part = i_part + 1;
 end 
lvo = lvo.';
no_lvo = [];
i_part = 1;
for i_parts = 1:length(parts)
if lvo(i_part) == 0
   no_lvo(i_part) = 1;
end    
i_part = i_part + 1;
end
no_lvo = no_lvo.';
%%% lvo matrix
lvo_matrix = [lvo,no_lvo];
lvo_labels = {'Non Large Vessel Occulusion','Large Vesssel Occlusion'};

%%% Stroke Type 1= ischemic, 2= ICH, 3 = TIA, 0= control
type = [];
i_part = 1;
for i_part= 1:length(parts)
if full_data(i_part,17) == 1
   type(i_part) = 1;
elseif full_data(i_part,17) == 2
    type(i_part) = 2;
elseif full_data(i_part,17) == 3
  type(i_part) = 3;
else type(i_part) = 0;
end 
 i_part = i_part + 1;
 end 
type = type.';

type_ischemic= double(type == 1);
type_ich = double(type == 2);
type_tia = double(type == 3);
type_control = double(type == 0);

all_type = [type_control,type_ischemic,type_ich,type_tia];
type_labels = {'Control','Ischemic','Intracerebral Hemorrhage','Transient Ischemic Attack'};


n_chans = length(electrodes);
conds = {'eyes_open';'eyes_closed'};
cond_labels = {'Eyes Open';'Eyes Closed'};
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


i_part = 13;
for i_part = 1:length(parts)
    disp(['Processing data for participant ' parts{i_part} ' and experiment Revamped']);
    
    %%% get the filename for each device, condition, and participant %%%
    filename_eeg = [parts{i_part} '_EEG_baseline_stroke_study_updated.csv'];
    filename_acc = [parts{i_part} '_ACC_baseline_stroke_study_updated.csv'];
    filename_gyro = [parts{i_part} '_GYRO_baseline_stroke_study_updated.csv'];
    
    %%% import our data file, these files are organized in the following
    %%% way:
    %%% column 1 = TP9
    %%% column 2 = AF7
    %%% column 3 = AF8
    %%% column 4 = TP10
    %%% column 5 = AUX NOT USED IN ANALYSIS
    
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
    
    %%% Process participant EEG data %%%
    for i_chan = 1:n_chans
        disp(['Processing data for channel ' electrodes{i_chan}]);
        
        %%% extact EEG data %%%
        if strcmp(electrodes{i_chan},'AUX')
            eeg_data_chan = eeg_data(:,i_chan);
        else
            eeg_data_chan = eeg_data(:,i_chan) - nanmean(eeg_data(:,i_chan));
        end
        
        %%% info for BOSC %%%
        period = median(diff(times_eeg));
        srate = 1/period;
        timepoints = period:period:length(times_eeg)*period;
        timepointm = timepoints/60;
        [bosc_eeg_data_chan] = log(BOSC_tf(eeg_data_chan,F,srate,wavenum));
        [bosc_eeg_data_chan_fooof] = (BOSC_tf(eeg_data_chan,F,srate,wavenum));
        
        %%% get marker positions %%%
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
        

        
        %%% save eyes open and closed segments %%%
        closed_all_parts_chan_eeg(:,1:eyes_closed_eeg_end-eyes_closed_eeg_start+1,i_chan) = bosc_eeg_data_chan(:,eyes_closed_eeg_start:eyes_closed_eeg_end);
        
        %%% average spectra across time %%%
        avg_closed_all_chan_eeg(:,i_chan) = nanmean(closed_all_parts_chan_eeg(:,:,i_chan),2);
       
        
        %%%save eyes open and eyes closed segments fooof%%%
        closed_all_parts_chan_eeg_fooof(:,1:eyes_closed_eeg_end-eyes_closed_eeg_start+1,i_chan) = bosc_eeg_data_chan_fooof(:,eyes_closed_eeg_start:eyes_closed_eeg_end);
        
        %%%average spectra across time foof%%%
        avg_closed_all_chan_eeg_fooof(:,i_chan) = nanmean(closed_all_parts_chan_eeg_fooof(:,:,i_chan),2);
        
        
    end
 
    %%%sort based on stroke location%%%
    %%%TP9 and TP10 will be index 1%%%
    %%%AF7 and AF8 will be index 2%%%
    if strcmp(string(stroke_loc{i_part}), '1')
        avg_closed_bad_eeg(:,1) = avg_closed_all_chan_eeg(:,1);
        avg_closed_bad_eeg(:,2) = avg_closed_all_chan_eeg(:,2);
        
        avg_closed_good_eeg(:,1) = avg_closed_all_chan_eeg(:,4);
        avg_closed_good_eeg(:,2) = avg_closed_all_chan_eeg(:,3);
        
    elseif strcmp(string(stroke_loc{i_part}), '2')
        avg_closed_bad_eeg(:,1) = avg_closed_all_chan_eeg(:,4);
        avg_closed_bad_eeg(:,2) = avg_closed_all_chan_eeg(:,3);
        
        avg_closed_good_eeg(:,1) = avg_closed_all_chan_eeg(:,1);
        avg_closed_good_eeg(:,2) = avg_closed_all_chan_eeg(:,2);
        
    elseif strcmp(string(stroke_loc{i_part}), '0')
        
        avg_closed_normal_eeg(:,:) = avg_closed_all_chan_eeg(:,[1,2,3,4]);
        
        avg_closed_bad_eeg(:,1) = avg_closed_all_chan_eeg(:,4);
        avg_closed_bad_eeg(:,2) = avg_closed_all_chan_eeg(:,3);
        
        avg_closed_good_eeg(:,1) = avg_closed_all_chan_eeg(:,1);
        avg_closed_good_eeg(:,2) = avg_closed_all_chan_eeg(:,2);
        
    end
    
    %%%sort based on stroke location fooof%%%
    %%%TP9 and TP10 will be index 1%%%
    %%%AF7 and AF8 will be index 2%%%
    if strcmp(string(stroke_loc{i_part}),'1')
        avg_closed_bad_eeg_fooof(:,1) = avg_closed_all_chan_eeg_fooof(:,1);
        avg_closed_bad_eeg_fooof(:,2) = avg_closed_all_chan_eeg_fooof(:,2);
        
        avg_closed_good_eeg_fooof(:,1) = avg_closed_all_chan_eeg_fooof(:,4);
        avg_closed_good_eeg_fooof(:,2) = avg_closed_all_chan_eeg_fooof(:,3);
        
    elseif strcmp(string(stroke_loc{i_part}),'2')
        avg_closed_bad_eeg_fooof(:,1) = avg_closed_all_chan_eeg_fooof(:,4);
        avg_closed_bad_eeg_fooof(:,2) = avg_closed_all_chan_eeg_fooof(:,3);
        
        avg_closed_good_eeg_fooof(:,1) = avg_closed_all_chan_eeg_fooof(:,1);
        avg_closed_good_eeg_fooof(:,2) = avg_closed_all_chan_eeg_fooof(:,2);
        
    elseif strcmp(string(stroke_loc{i_part}),'0')
        
        avg_closed_normal_eeg_fooof(:,:) = avg_closed_all_chan_eeg_fooof(:,[1,2,3,4]);
        
        avg_closed_bad_eeg_fooof(:,1) = avg_closed_all_chan_eeg_fooof(:,4);
        avg_closed_bad_eeg_fooof(:,2) = avg_closed_all_chan_eeg_fooof(:,3);
        
        avg_closed_good_eeg_fooof(:,1) = avg_closed_all_chan_eeg_fooof(:,1);
        avg_closed_good_eeg_fooof(:,2) = avg_closed_all_chan_eeg_fooof(:,2);
        
    end
    
     %%% Process Acc data %%%%
    for i_chan = 1:3
        
        acc_data_chan = acc_data(:,i_chan);
        
        %%% find eyes closed markers %%%
        eyes_closed_acc_start = find(markers_acc == 5);
        eyes_closed_acc_end = find(markers_acc == 6);
        
        %%% get our acc epochs %%%
        closed_all_parts_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan) = acc_data_chan(eyes_closed_acc_start:eyes_closed_acc_end, 1);
        
        %%% determine RMS, SD for each epoch %%%
        closed_all_parts_chan_acc_rms(i_chan) = rms(closed_all_parts_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan));
        closed_all_parts_chan_acc_sd(i_chan) = std(closed_all_parts_chan_acc(1:eyes_closed_acc_end-eyes_closed_acc_start+1,i_chan));
        
    end
    
    %%% Process Gyro data %%%%%
 
    for i_chan = 1:3
        gyro_data_chan = gyro_data(:,i_chan);
        
        %%% find eyes closed markers %%%
        eyes_closed_gyro_start = find(markers_gyro == 5);
        eyes_closed_gyro_end = find(markers_gyro == 6);
        
        %%% get our gyro epochs %%%
        closed_all_parts_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan) = gyro_data_chan(eyes_closed_gyro_start:eyes_closed_gyro_end, 1);
        
        %%% determine RMS, SD for each epoch %%%
        closed_all_parts_chan_gyro_rms(i_chan) = rms(closed_all_parts_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan));
        closed_all_parts_chan_gyro_sd(i_chan) = std(closed_all_parts_chan_gyro(1:eyes_closed_gyro_end-eyes_closed_gyro_start+1,i_chan));

    end
    filename = ['Participant_' parts{i_part} '.mat'];
    save(filename,'avg_closed_all_chan_eeg','avg_closed_all_chan_eeg_fooof','avg_closed_bad_eeg','avg_closed_good_eeg',...
        'avg_closed_bad_eeg_fooof','avg_closed_good_eeg_fooof','closed_all_parts_chan_acc','closed_all_parts_chan_acc_rms','closed_all_parts_chan_acc_sd',...
        'closed_all_parts_chan_gyro','closed_all_parts_chan_gyro_rms','closed_all_parts_chan_gyro_sd');
    
end
