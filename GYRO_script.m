%% 
%%% Pull Patient Data %%%

%%% ALL DATA IS CLOSED DATA %%%

%%%file path and name information %%%
datapath = ['M:\Data\Muse_Stroke_Study_data\Revamped\'];

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
%%% mimic/control = 0, no symptoms = 1, minor = 2, moderate = 3, moderate-severe = 4, severe =
%%% 5%%%
severity_no = double(severity == 1);
severity_minor = double(severity == 2);
severity_moderate = double(severity == 3);
severity_mod_sev = double(severity == 4);
severity_severe = double(severity == 5);
severity_control = double(severity == 0);
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


all_severity = [severity_control,severity_no,severity_minor,severity_moderate,severity_mod_sev,severity_severe];
n_chans = length(electrodes);
conds = {'eyes_open';'eyes_closed'};
cond_labels = {'Eyes Open';'Eyes Closed'};
sev_labels = {'Control';'No Symptoms';'Minor';'Moderate';'Moderate to Severe';'Severe'};
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

%%
%%% Load in data %%%
i_part = 1;

datapath = ['M:\Analysis\Muse_Stroke_Study\Participant_Processed_Data\Participant_'];
parts_eeg = [];
parts_eeg_fooof = [];
parts_eeg_bad = [];
parts_eeg_bad_fooof = [];
parts_eeg_good = [];
parts_eeg_good_fooof = [];
parts_gyro = [];
parts_gyro_rms = [];
parts_gyro_sd = [];


for i_part = 1:length(parts)
    file = strcat(datapath, parts(i_part));
    file = string(file);
    disp(['Loading data for participant ' parts{i_part}]);
    load(file);
    
    if length(closed_all_parts_chan_gyro)> 9135
        closed_all_parts_chan_gyro([9136:end],:) = [];
    end
    parts_gyro(:,:,i_part) = closed_all_parts_chan_gyro;
    parts_gyro_rms = vertcat(parts_gyro_rms, closed_all_parts_chan_gyro_rms);
    parts_gyro_sd = vertcat(parts_gyro_sd, closed_all_parts_chan_gyro_sd);

    i_part = i_part + 1; 
end 

%% 

%%% RMS for gyro data by severity
for i_chan = 1
 figure;
    subplot(1,3,1);
    boxplot(parts_gyro_rms(:,1),severity);
    ylabel('Root Mean Squares','FontSize', 12,'FontWeight', 'bold');
    title({' ';' X Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','No Symptoms','Minor','Moderate','Moderate to Severe','Severe',},'XTickLabelRotation',45);
    
    subplot(1,3,2);
    boxplot(parts_gyro_rms(:,2),severity);
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    title({'Root Mean Squares of Gyroscope data ';' Y Plane'} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','No Symptoms','Minor','Moderate','Moderate to Severe','Severe',},'XTickLabelRotation',45);
    
    subplot(1,3,3);
    boxplot(parts_gyro_rms(:,3),severity);
    title({' ';' Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','No Symptoms','Minor','Moderate','Moderate to Severe','Severe',},'XTickLabelRotation',45);
end

% %%% ANOVA %%%
% gyro_rms = [];
% gyro_xyz = [];
% for i_part = 1:length(parts)
%    gyro_rms = [gyro_rms;parts_gyro_rms(:,i_part)]; 
%    gyro_xyz = strvcat(gyro_xyz, 'x','y','z');
% end
% i_part = 1;
% severity_3 = [];
% parts_3 = [];
% for i_count = 1:(length(parts)*3)
%     severity_3 = [severity_3;severity(i_part)];
%     parts_3 = [parts_3;parts(i_part)];
%     if mod(i_count,3)==0
%         i_part = i_part + 1;
%     end
% end
% gyro_xyz = cellstr(gyro_xyz);
% 
% [~,~,stats] = anovan(gyro_rms,{severity_3 gyro_xyz},'model','full',...
%     'varnames',{'severity','axis'});
% results = multcompare(stats,'Dimension',[1,2])
% %%% SIGNIFICANT DIFFERENCES in axis (p=0), none in interactions, moderate has
% %%% some significant differences across axis


%%

%%% RMS for gyro data by LVO
for i_chan = 1
 figure;
    subplot(1,3,1);
    boxplot(parts_gyro_rms(:,1),lvo_matrix);
    ylabel('Root Mean Squares','FontSize', 12,'FontWeight', 'bold');
    title({' ';' X Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Large Vessel Occlusions','No Large Vessel Occlusions'},'XTickLabelRotation',45);
    
    subplot(1,3,2);
    boxplot(parts_gyro_rms(:,2),lvo_matrix);
    xlabel('Stroke Type','FontSize', 12,'FontWeight', 'bold');
    title({'Root Mean Squares of Gyroscope data ';' Y Plane'} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Large Vessel Occlusions','No Large Vessel Occlusions'},'XTickLabelRotation',45);
    
    subplot(1,3,3);
    boxplot(parts_gyro_rms(:,3),lvo_matrix);
    title({' ';' Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Large Vessel Occlusions','No Large Vessel Occlusions'},'XTickLabelRotation',45);
end

%%

%%% RMS for gyro data by Stroke Type
for i_chan = 1
 figure;
    subplot(1,3,1);
    boxplot(parts_gyro_rms(:,1),type);
    ylabel('Root Mean Squares','FontSize', 12,'FontWeight', 'bold');
    title({' ';' X Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Ischemic','Hemorrhagic','Transient'},'XTickLabelRotation',45);
    
    subplot(1,3,2);
    boxplot(parts_gyro_rms(:,2),type);
    xlabel('Stroke Type','FontSize', 12,'FontWeight', 'bold');
    title({'Root Mean Squares of Gyroscope data ';' Y Plane'} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Ischemic','Hemorrhagic','Transient'},'XTickLabelRotation',45);
    
    subplot(1,3,3);
    boxplot(parts_gyro_rms(:,3),type);
    title({' ';' Z Plane '} ,'FontSize', 12,'FontWeight', 'bold');
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none',...
        'Layer','Top','XTickLabel',{'Controls','Ischemic','Hemorrhagic','Transient'},'XTickLabelRotation',45);
end
