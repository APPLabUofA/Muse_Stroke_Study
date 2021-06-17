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



for i_part = 1:length(parts)
    file = strcat(datapath, parts(i_part));
    file = string(file);
    disp(['Loading data for participant ' parts{i_part}]);
    load(file);

    parts_eeg(:,:,i_part) = avg_closed_all_chan_eeg;
    parts_eeg_fooof(:,:,i_part) = avg_closed_all_chan_eeg_fooof;
    parts_eeg_bad(:,:,i_part) = avg_closed_bad_eeg;
    parts_eeg_bad_fooof(:,:,i_part) = avg_closed_bad_eeg_fooof;
    parts_eeg_good(:,:,i_part) = avg_closed_good_eeg;
    parts_eeg_good_fooof(:,:,i_part) = parts_eeg_good_fooof;

    i_part = i_part + 1; 
end 

%%
%%%Saving Delta/theta + alpha/beta ratio as a variable and graphing by
%%%stroke type (I1= ischemic, 2= ICH, 3 = TIA, 0= control)%%%
i_count = 0;
i_sev = 1;
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
delta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(parts_eeg_good(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(beta_bins,1,:),1),2));
gamma_power_good = squeeze(nanmean(nanmean(parts_eeg_good(gamma_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(beta_bins,1,:),1),2));
gamma_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(gamma_bins,1,:),1),2));

DTABR_good = (delta_power_good+theta_power_good)./(alpha_power_good+beta_power_good);

DTABR_bad = (delta_power_bad+theta_power_bad)./(alpha_power_bad+beta_power_bad);

%DTABR calculations
SE_DTABR_good_control = std(nonzeros(DTABR_good.*type_control))/sqrt(sum(type_control));
SE_DTABR_good_ischemic = std(nonzeros(DTABR_good.*type_ischemic))/sqrt(sum(type_ischemic));
SE_DTABR_good_ich = std(nonzeros(DTABR_good.*type_ich))/sqrt(sum(type_ich));
SE_DTABR_good_tia = std(nonzeros(DTABR_good.*type_tia))/sqrt(sum(type_tia));

SE_DTABR_good_all = [SE_DTABR_good_control,SE_DTABR_good_ischemic,SE_DTABR_good_ich,SE_DTABR_good_tia];

SE_DTABR_bad_control = std(nonzeros(DTABR_bad.*type_control))/(sqrt(sum(type_control)));
SE_DTABR_bad_ischemic = std(nonzeros(DTABR_bad.*type_ischemic))/sqrt(sum(type_ischemic));
SE_DTABR_bad_ich = std(nonzeros(DTABR_bad.*type_ich))/sqrt(sum(type_ich));
SE_DTABR_bad_tia = std(nonzeros(DTABR_bad.*type_tia))/sqrt(sum(type_tia));
SE_DTABR_bad_all = [SE_DTABR_bad_control,SE_DTABR_bad_ischemic,SE_DTABR_bad_ich,SE_DTABR_bad_tia];

type_t = {'Control','Ischemic','Hemorrhagic','Transient'};
type_string = string(type_t);
%%%now plot the ratios of delta_theta vs alpha_beta%%%
figure;

for i_sev = 1:4

    hold on;
    B(1:2) = bar(i_count,nanmean((delta_power_good.*(all_type(:,i_sev))+theta_power_good.*(all_type(:,i_sev)))./(alpha_power_good.*(all_type(:,i_sev))+beta_power_good.*(all_type(:,i_sev)))),'b','LineWidth',3);
    er1 = errorbar(i_count,nanmean((delta_power_good.*(all_type(:,i_sev))+theta_power_good.*(all_type(:,i_sev)))./(alpha_power_good.*(all_type(:,i_sev))+beta_power_good.*(all_type(:,i_sev)))),SE_DTABR_good_all(:,i_sev));
    er1.Color = [0 0 0];
    
    B(3:4) = bar((i_count + 1),nanmean((delta_power_bad.*(all_type(:,i_sev))+theta_power_bad.*(all_type(:,i_sev)))./(alpha_power_bad.*(all_type(:,i_sev))+beta_power_bad.*(all_type(:,i_sev)))),'r','LineWidth',3);
    er2 = errorbar((i_count + 1),nanmean((delta_power_bad.*(all_type(:,i_sev))+theta_power_bad.*(all_type(:,i_sev)))./(alpha_power_bad.*(all_type(:,i_sev))+beta_power_bad.*(all_type(:,i_sev)))),SE_DTABR_bad_all(:,i_sev));
    er2.Color = [0 0 0];
    i_count = i_count + 3;
    hold off;
    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
%     if strcmp(sev_labels{i_sev},'Control')
%         legend(B([2,4]),{'TP9';'TP10'});
%     else
%         legend(B([2,4]),{'Ispilateral';'Contralateral'});
%     end

    
    i_sev = i_sev + 1;
end
    ax = gca;
    set(gca,'Xtick',[0.5,3.5,6.5,9.5],'XTickLabel',{'Control','Ischemic','Hemorrhagic','Transient'},'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
    ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
    XTickLabel = {'Control','Ischemic','Hemorrhagic','Transient'};
    xlabel({'Stroke Type'},'FontSize', 12,'FontWeight', 'bold');
    legend('DisplayName', {'contralateral', 'ipsilateral'});
    %%%
    title(['Delta+Theta/Alpha+Beta :  ' electrodes_comb{1}],'FontSize', 12,'FontWeight', 'bold');
    ylim([1,1.5]);

% %%% ANOVA
% DTABR_matrix = [DTABR_good;DTABR_bad];
% DTABR_g_b_identifier = {'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';'Good';...
%     'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad';'Bad'};
% severity_2 = [severity;severity];
% 
% 
% [~,~,stats] = anovan(DTABR_matrix,{severity_2,DTABR_g_b_identifier},'model','full',...
%     'varnames',{'severity','DTABr side'});
% results = multcompare(stats,'Dimension',[1,2])
% %%%%   NO SIGNIFICANT DIFFERENCES, THERE IS A SEVERITY EFFECT %%%

%%
%%%Saving Delta/theta + alpha/beta ratio as a variable and graphing by
%%%severity%%%
i_count = 4;
i_sev = 1;
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
delta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(parts_eeg_good(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(beta_bins,1,:),1),2));
gamma_power_good = squeeze(nanmean(nanmean(parts_eeg_good(gamma_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(beta_bins,1,:),1),2));
gamma_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(gamma_bins,1,:),1),2));

DTABR_good = (delta_power_good+theta_power_good)./(alpha_power_good+beta_power_good);

DTABR_bad = (delta_power_bad+theta_power_bad)./(alpha_power_bad+beta_power_bad);

%DTABR calculations
SE_DTABR_good_control = std(nonzeros(DTABR_good.*severity_control))/sqrt(sum(severity_control));
SE_DTABR_good_no = std(nonzeros(DTABR_good.*severity_no))/sqrt(sum(severity_no));
SE_DTABR_good_minor = std(nonzeros(DTABR_good.*severity_minor))/sqrt(sum(severity_minor));
SE_DTABR_good_moderate = std(nonzeros(DTABR_good.*severity_moderate))/sqrt(sum(severity_moderate));
SE_DTABR_good_mod_sev = std(nonzeros(DTABR_good.*severity_mod_sev))/sqrt(sum(severity_mod_sev));
SE_DTABR_good_severe = std(nonzeros(DTABR_good.*severity_severe))/sqrt(sum(severity_severe));
SE_DTABR_good_all = [SE_DTABR_good_control,SE_DTABR_good_no,SE_DTABR_good_minor,SE_DTABR_good_moderate,SE_DTABR_good_mod_sev,SE_DTABR_good_severe];


SE_DTABR_bad_control = std(nonzeros(DTABR_bad.*severity_control))/(sqrt(sum(severity_control)));
SE_DTABR_bad_no = std(nonzeros(DTABR_bad.*severity_no))/sqrt(sum(severity_no));
SE_DTABR_bad_minor = std(nonzeros(DTABR_bad.*severity_minor))/sqrt(sum(severity_minor));
SE_DTABR_bad_moderate = std(nonzeros(DTABR_bad.*severity_moderate))/sqrt(sum(severity_moderate));
SE_DTABR_bad_mod_sev = std(nonzeros(DTABR_bad.*severity_mod_sev))/sqrt(sum(severity_mod_sev));
SE_DTABR_bad_severe = std(nonzeros(DTABR_bad.*severity_severe))/sqrt(sum(severity_severe));
SE_DTABR_bad_all = [SE_DTABR_bad_control,SE_DTABR_bad_no,SE_DTABR_bad_minor,SE_DTABR_bad_moderate,SE_DTABR_bad_mod_sev,SE_DTABR_bad_severe];

severity_t = {'Control','No Symptoms','Minor','Moderate','Moderate to Severe','Severe'};
severity_type = string(severity_t);
%%%now plot the ratios of delta_theta vs alpha_beta%%%
figure;

for i_sev = 1:6

    hold on;
    B(1:2) = bar(i_count,nanmean((delta_power_good.*(all_severity(:,i_sev))+theta_power_good.*(all_severity(:,i_sev)))./(alpha_power_good.*(all_severity(:,i_sev))+beta_power_good.*(all_severity(:,i_sev)))),'b','LineWidth',3);
    er1 = errorbar(i_count,nanmean((delta_power_good.*(all_severity(:,i_sev))+theta_power_good.*(all_severity(:,i_sev)))./(alpha_power_good.*(all_severity(:,i_sev))+beta_power_good.*(all_severity(:,i_sev)))),SE_DTABR_good_all(:,i_sev));
    er1.Color = [0 0 0];
    
    B(3:4) = bar((i_count + 1),nanmean((delta_power_bad.*(all_severity(:,i_sev))+theta_power_bad.*(all_severity(:,i_sev)))./(alpha_power_bad.*(all_severity(:,i_sev))+beta_power_bad.*(all_severity(:,i_sev)))),'r','LineWidth',3);
    er2 = errorbar((i_count + 1),nanmean((delta_power_bad.*(all_severity(:,i_sev))+theta_power_bad.*(all_severity(:,i_sev)))./(alpha_power_bad.*(all_severity(:,i_sev))+beta_power_bad.*(all_severity(:,i_sev)))),SE_DTABR_bad_all(:,i_sev));
    er2.Color = [0 0 0];
    i_count = i_count + 3;
    hold off;
    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','xtick',[]);
%     if strcmp(sev_labels{i_sev},'Control')
%         legend(B([2,4]),{'TP9';'TP10'});
%     else
%         legend(B([2,4]),{'Ispilateral';'Contralateral'});
%     end

    
    i_sev = i_sev + 1;
end
    ax = gca;
    set(gca,'Xtick',[4.5,7.5,10.5,13.5,16.5,19.5],'XTickLabel',{'Age-Matched Controls','No Symptoms','Minor','Moderate','Moderate to Severe','Severe'},'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
    ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
    XTickLabel = {'Age-Matched Controls','No Symptoms','Minor','Moderate','Moderate to Severe','Severe'};
    xlabel({'Severity'},'FontSize', 12,'FontWeight', 'bold');

    %%%
    title(['Delta+Theta/Alpha+Beta :  ' electrodes_comb{1}],'FontSize', 12,'FontWeight', 'bold');
    ylim([1,1.5]);


%%
%%%Saving Delta/theta + alpha/beta ratio as a variable and graphing by
%%%LVO%%%
i_count = 1;
i_sev = 1;
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
delta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(parts_eeg_good(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(beta_bins,1,:),1),2));
gamma_power_good = squeeze(nanmean(nanmean(parts_eeg_good(gamma_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(beta_bins,1,:),1),2));
gamma_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(gamma_bins,1,:),1),2));

DTABR_good = (delta_power_good+theta_power_good)./(alpha_power_good+beta_power_good);

DTABR_bad = (delta_power_bad+theta_power_bad)./(alpha_power_bad+beta_power_bad);

%DTABR calculations
SE_DTABR_good_no_lvo = std(nonzeros(DTABR_good.*no_lvo))/sqrt(sum(no_lvo));
SE_DTABR_good_lvo = std(nonzeros(DTABR_good.*lvo))/sqrt(sum(lvo));
SE_DTABR_good_all = [SE_DTABR_good_no_lvo,SE_DTABR_good_lvo];


SE_DTABR_bad_no_lvo = std(nonzeros(DTABR_bad.*no_lvo))/(sqrt(sum(no_lvo)));
SE_DTABR_bad_lvo = std(nonzeros(DTABR_bad.*lvo))/sqrt(sum(lvo));
SE_DTABR_bad_all = [SE_DTABR_bad_no_lvo,SE_DTABR_bad_lvo];

severity_t = {'Non LVO ','LVO'};
severity_type = string(severity_t);
%%%now plot the ratios of delta_theta vs alpha_beta%%%

i_part = 1;
figure;
    
for i_sev = 1:2

    hold on;
    B(1:2) = bar(i_count,nanmean((delta_power_good.*(lvo_matrix(:,i_sev))+theta_power_good.*(lvo_matrix(:,i_sev)))./(alpha_power_good.*(lvo_matrix(:,i_sev))+beta_power_good.*(lvo_matrix(:,i_sev)))),'b','LineWidth',3);
    er1 = errorbar(i_count,nanmean((delta_power_good.*(lvo_matrix(:,i_sev))+theta_power_good.*(lvo_matrix(:,i_sev)))./(alpha_power_good.*(lvo_matrix(:,i_sev))+beta_power_good.*(lvo_matrix(:,i_sev)))),SE_DTABR_good_all(:,i_sev));
    er1.Color = [0 0 0];
    
    B(3:4) = bar((i_count + 1),nanmean((delta_power_bad.*(lvo_matrix(:,i_sev))+theta_power_bad.*(lvo_matrix(:,i_sev)))./(alpha_power_bad.*(lvo_matrix(:,i_sev))+beta_power_bad.*(lvo_matrix(:,i_sev)))),'r','LineWidth',3);
    er2 = errorbar((i_count + 1),nanmean((delta_power_bad.*(lvo_matrix(:,i_sev))+theta_power_bad.*(lvo_matrix(:,i_sev)))./(alpha_power_bad.*(lvo_matrix(:,i_sev))+beta_power_bad.*(lvo_matrix(:,i_sev)))),SE_DTABR_bad_all(:,i_sev));
    er2.Color = [0 0 0];
    i_count = i_count + 3;
    hold off;
    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
%     if strcmp(sev_labels{i_sev},'Control')
%         legend(B([2,4]),{'TP9';'TP10'});
%     else
         
%     end

    
    i_sev = i_sev + 1;
end
    ax = gca;
    set(gca,'Xtick',[1.5,4.5],'XTickLabel',{'Large Vessel Occlusion','No Large Vessel Occlusion'},'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
    XTickLabel = {'Large Vessel Occlusion','No Large Vessel Occlusion'};
    xlabel({'Stroke Type'},'FontSize', 12,'FontWeight', 'bold');
        title(['Delta+Theta/Alpha+Beta :  ' electrodes_comb{1}],'FontSize', 12,'FontWeight', 'bold');
    ylabel('Power (uV^2) Ratio','FontSize', 12,'FontWeight', 'bold');
    legend('DisplayName', {'contralateral', 'ipsilateral'});


