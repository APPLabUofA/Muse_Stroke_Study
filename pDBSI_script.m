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
%%%Graphing pdBSI by stroke severity%%%
colour_list = ['b','c','g','y','r','m']

%%%all Hz%%%
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);



pdBSP_ear_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed))),1));

SE_pdBSP_control = std(nonzeros(pdBSP_ear_all_closed.*severity_control))/sqrt(sum(severity_control));
SE_pdBSP_no = std(nonzeros(pdBSP_ear_all_closed.*severity_no))/sqrt(sum(severity_no));
SE_pdBSP_minor = std(nonzeros(pdBSP_ear_all_closed.*severity_minor))/sqrt(sum(severity_minor));
SE_pdBSP_moderate = std(nonzeros(pdBSP_ear_all_closed.*severity_moderate))/sqrt(sum(severity_moderate));
SE_pdBSP_mod_sev = std(nonzeros(pdBSP_ear_all_closed.*severity_mod_sev))/sqrt(sum(severity_mod_sev));
SE_pdBSP_severe = std(nonzeros(pdBSP_ear_all_closed.*severity_severe))/sqrt(sum(severity_severe));

SE_pdBSP_all = [SE_pdBSP_control,SE_pdBSP_no,SE_pdBSP_minor,SE_pdBSP_moderate,SE_pdBSP_mod_sev,SE_pdBSP_severe];

i_count = 1;
i_sev = 1;
%%%now plot the pdBSI%%%
figure;
for i_sev = 1:6
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_all_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_all_closed_375)),SE_pdBSP_375(:,:));
%     er.Color = [0 0 0];
%   
 
    B(1:2) = bar(i_count,nanmean(nonzeros(pdBSP_ear_all_closed.*all_severity(:,i_sev))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean(nonzeros(pdBSP_ear_all_closed.*all_severity(:,i_sev))),SE_pdBSP_all(:,i_sev));
    er.Color = [0 0 0];
    i_count = i_count + 1;
    i_sev = i_sev + 1;
    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'Control','No Symptoms','Minor','Moderate','Moderate to Severe','Severe'});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Severity','FontSize', 12,'FontWeight', 'bold');
    xticks([1,2,3,4,5,6]);
    title(['pdBSI: all frequencies at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.035]);

%%
%%%Graphing pdBSI by stroke type%%%
colour_list = ['b','c','g','y']

%%%all Hz%%%
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);



pdBSP_ear_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed))),1));

SE_pdBSP_control = std(nonzeros(pdBSP_ear_all_closed.*type_control))/sqrt(sum(type_control));
SE_pdBSP_ischemic = std(nonzeros(pdBSP_ear_all_closed.*type_ischemic))/sqrt(sum(type_ischemic));
SE_pdBSP_ich = std(nonzeros(pdBSP_ear_all_closed.*type_ich))/sqrt(sum(type_ich));
SE_pdBSP_tia = std(nonzeros(pdBSP_ear_all_closed.*type_tia))/sqrt(sum(type_tia));


SE_pdBSP_all = [SE_pdBSP_control,SE_pdBSP_ischemic,SE_pdBSP_ich,SE_pdBSP_tia];

i_count = 1;
i_sev = 1;
%%%now plot the pdBSI%%%
figure;
for i_sev = 1:4
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_all_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_all_closed_375)),SE_pdBSP_375(:,:));
%     er.Color = [0 0 0];
%   
 
    B(1:2) = bar(i_count,nanmean(nonzeros(pdBSP_ear_all_closed.*all_type(:,i_sev))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean(nonzeros(pdBSP_ear_all_closed.*all_type(:,i_sev))),SE_pdBSP_all(:,i_sev));
    er.Color = [0 0 0];
    i_count = i_count + 1;
    i_sev = i_sev + 1;
    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'Control','Ischemic','Hemorrhagic','Transient'});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Stroke Type','FontSize', 12,'FontWeight', 'bold');
    xticks([1,2,3,4,]);
    title(['pdBSI: all frequencies at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.035]);

%%
%%%Graphing pdBSI by LVO)%%%
colour_list = ['b','r'];

%%%all Hz%%%
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);


pdBSP_ear_all_closed = squeeze(nanmean(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed))),1));

SE_pdBSP_lvo = std(nonzeros(pdBSP_ear_all_closed.*lvo))/sqrt(sum(lvo));
SE_pdBSP_no_lvo = std(nonzeros(pdBSP_ear_all_closed.*no_lvo))/sqrt(sum(no_lvo));


SE_pdBSP_all = [SE_pdBSP_lvo,SE_pdBSP_no_lvo];

i_count = 1;
i_sev = 1;
%%%now plot the pdBSI%%%
figure;
for i_sev = 1:2
    hold on;
%     B(1:2) = bar(1,nanmean((pdBSP_ear_all_closed_375(:,:))),'b','LineWidth',3);
%     er = errorbar(1,nanmean((pdBSP_ear_all_closed_375)),SE_pdBSP_375(:,:));
%     er.Color = [0 0 0];
%   
 
    B(1:2) = bar(i_count,nanmean(nonzeros(pdBSP_ear_all_closed.*lvo_matrix(:,i_sev))),colour_list(i_count),'LineWidth',3);

    er = errorbar(i_count,nanmean(nonzeros(pdBSP_ear_all_closed.*lvo_matrix(:,i_sev))),SE_pdBSP_all(:,i_sev));
    er.Color = [0 0 0];
    i_count = i_count + 1;
    i_sev = i_sev + 1;
    hold off;
    
   
end

    
    set(gca,'FontSize',12,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top','XTickLabel',{'Large Vessel Occlusion','No Large Vessel Occlusion'});
    ylabel('pdBSI Power (uV^2) ','FontSize', 12,'FontWeight', 'bold');
    xlabel('Stroke Type','FontSize', 12,'FontWeight', 'bold');
    xticks([1,2]);
    title(['pdBSI: all frequencies at TP9/TP10 '],'FontSize', 12,'FontWeight', 'bold');
    ylim([0,0.025]);

%%
%%% spectral of pdBSI (TP9 + TP10) by severity%%%

%%%all Hz%%%
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);



pdBSP_spectra = (squeeze(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed)))).');

      group_index_1 = find(severity_control == 1);
            group_index_2 = find(severity_no == 1);
            group_index_3 = find(severity_minor == 1);
            group_index_4 = find(severity_moderate == 1);
            group_index_5 = find(severity_mod_sev == 1);
            group_index_6 = find(severity_severe == 1);
            
            
            
   figure 

            [hl,hr] = boundedline(...
            F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'b','alpha',...
            F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'c','alpha',...
            F,nanmean(pdBSP_spectra(group_index_3,:),1),nanstd(pdBSP_spectra(group_index_3,:),[],1)/sqrt(length(parts(group_index_3))),'g','alpha',...
            F,nanmean(pdBSP_spectra(group_index_4,:),1),nanstd(pdBSP_spectra(group_index_4,:),[],1)/sqrt(length(parts(group_index_4))),'y','alpha',...
            F,nanmean(pdBSP_spectra(group_index_5,:),1),nanstd(pdBSP_spectra(group_index_5,:),[],1)/sqrt(length(parts(group_index_5))),'r','alpha',...
            F,nanmean(pdBSP_spectra(group_index_6,:),1),nanstd(pdBSP_spectra(group_index_6,:),[],1)/sqrt(length(parts(group_index_6))),'m','alpha');
        set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
        set(hl,'linewidth',3);


        legend({'Controls','No Symptoms','Minor','Moderate','Moderate to Severe','Severe',});
        xlim([0 30])
        ylabel('Brain Symmetry Index','FontSize', 14,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
        title('pdBSI Spectra','FontSize', 16,'FontWeight', 'bold');
 
 %%
%%% spectral of pdBSI (TP9 + TP10) by stroke type%%%

%%%all Hz%%%
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);



pdBSP_spectra = (squeeze(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed)))).');

      group_index_1 = find(type_control == 1);
            group_index_2 = find(type_ischemic == 1);
            group_index_3 = find(type_ich == 1);
            group_index_4 = find(type_tia == 1);

            
            
   figure 

            [hl,hr] = boundedline(...
            F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'b','alpha',...
            F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'c','alpha',...
            F,nanmean(pdBSP_spectra(group_index_3,:),1),nanstd(pdBSP_spectra(group_index_3,:),[],1)/sqrt(length(parts(group_index_3))),'g','alpha',...
            F,nanmean(pdBSP_spectra(group_index_4,:),1),nanstd(pdBSP_spectra(group_index_4,:),[],1)/sqrt(length(parts(group_index_4))),'y','alpha');
        set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
        set(hl,'linewidth',3);


        legend({'Controls','Ischemic','Hemorrhagic','Transient'});
        xlim([0 30])
        ylabel('Brain Symmetry Index','FontSize', 14,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
        title('pdBSI Spectra','FontSize', 16,'FontWeight', 'bold');
 
               
%%
%%% spectral of pdBSI (TP9 + TP10) by stroke type (LVO)%%%

%%%all Hz%%%
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);



pdBSP_spectra = (squeeze(abs(((tp9_all_closed - tp10_all_closed) ./ (tp9_all_closed + tp10_all_closed)))).');

      group_index_1 = find(no_lvo == 1);
      group_index_2 = find(lvo == 1);

            
            
            
   figure 

        [hl,hr] = boundedline(...
        F,nanmean(pdBSP_spectra(group_index_1,:),1),nanstd(pdBSP_spectra(group_index_1,:),[],1)/sqrt(length(parts(group_index_1))),'b','alpha',...
        F,nanmean(pdBSP_spectra(group_index_2,:),1),nanstd(pdBSP_spectra(group_index_2,:),[],1)/sqrt(length(parts(group_index_2))),'r','alpha');
        set(gca,'FontSize',14,'FontWeight', 'bold','linewidth',3,'box','off','color','none','Layer','Top');
        set(hl,'linewidth',3);


        legend({'No Large Vessel Occlusions','Large Vessel Occlusion'});
        xlim([0 30])
        ylabel('Brain Symmetry Index','FontSize', 14,'FontWeight', 'bold');
        xlabel('Frequency (Hz)','FontSize', 14,'FontWeight', 'bold');
        title('pdBSI Spectra','FontSize', 16,'FontWeight', 'bold');