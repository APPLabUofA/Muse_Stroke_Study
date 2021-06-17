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
lams = [full_data(:,6)];
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
parts_acc = [];
parts_acc_rms = [];
parts_acc_sd = [];


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
   
    if length(closed_all_parts_chan_gyro)> 9135
        closed_all_parts_chan_gyro([9136:end],:) = [];
    end
    parts_gyro(:,:,i_part) = closed_all_parts_chan_gyro;
    parts_gyro_rms = vertcat(parts_gyro_rms, closed_all_parts_chan_gyro_rms);
    parts_gyro_sd = vertcat(parts_gyro_sd, closed_all_parts_chan_gyro_sd);

    if length(closed_all_parts_chan_acc)> 9135
        closed_all_parts_chan_acc([9136:end],:) = [];
    end
    parts_acc(:,:,i_part) = closed_all_parts_chan_acc;
    parts_acc_rms = vertcat(parts_acc_rms, closed_all_parts_chan_acc_rms);
    parts_acc_sd = vertcat(parts_acc_sd, closed_all_parts_chan_acc_sd);

    i_part = i_part + 1; 
end 

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
tp9_all_closed = parts_eeg(:,1,:);
af7_all_closed = parts_eeg(:,2,:);
af8_all_closed = parts_eeg(:,3,:);
tp10_all_closed = parts_eeg(:,4,:);


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
i_part = 1;

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
    rms_gyro_x =  [rms_gyro_x;parts_gyro_rms(i_part,1)];
    rms_gyro_y =  [rms_gyro_y;parts_gyro_rms(i_part,2)];
    rms_gyro_z =  [rms_gyro_z;parts_gyro_rms(i_part,3)];

%%% sd gyro
    sd_gyro_x =  [sd_gyro_x;parts_gyro_sd(i_part,1)];
    sd_gyro_y =  [sd_gyro_y;parts_gyro_sd(i_part,2)];
    sd_gyro_z =  [sd_gyro_z;parts_gyro_sd(i_part,3)];

%%% ACC %%%
%%% root mean squares acc
    rms_acc_x =  [rms_acc_x;parts_acc_rms(i_part,1)];
    rms_acc_y =  [rms_acc_y;parts_acc_rms(i_part,2)];
    rms_acc_z =  [rms_acc_z;parts_acc_rms(i_part,3)];

%%% sd acc
    sd_acc_x =  [sd_acc_x;parts_acc_sd(i_part,1)];
    sd_acc_y =  [sd_acc_y;parts_acc_sd(i_part,2)];
    sd_acc_z =  [sd_acc_z;parts_acc_sd(i_part,3)];
    
    i_part = i_part + 1;

end


%%% DELTA/ALPHA RATIO %%%
i_part = 1;
dar_g = [];
dar_b = [];

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

delta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(delta_bins,1,:),1),2));
theta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(theta_bins,1,:),1),2));
alpha_power_good = squeeze(nanmean(nanmean(parts_eeg_good(alpha_bins,1,:),1),2));
beta_power_good = squeeze(nanmean(nanmean(parts_eeg_good(beta_bins,1,:),1),2));

delta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(delta_bins,1,:),1),2));
theta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(theta_bins,1,:),1),2));
alpha_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(alpha_bins,1,:),1),2));
beta_power_bad = squeeze(nanmean(nanmean(parts_eeg_bad(beta_bins,1,:),1),2));


DTABR_good = (delta_power_good+theta_power_good)./(alpha_power_good+beta_power_good);

DTABR_bad = (delta_power_bad+theta_power_bad)./(alpha_power_bad+beta_power_bad);

for i_part = 1:length(parts)
    dtabr_g = [dtabr_g;DTABR_good(i_part,:)];
    dtabr_b = [dtabr_b;DTABR_bad(i_part,:)];
    i_part = i_part + 1;
end


%%% FOOOF INTERCEPT AND SLOPE %%%
% fooof_bg_intercept;
% fooof_bg_slope;


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
severity_index = severity.';
lvo_cell = num2cell(lvo.');
lvo_hor = lvo.';
lvo_string = []; 
lvo_string = string(lvo_hor);
lvo_string = replace(lvo_string,'1','LVO');
lvo_string = replace(lvo_string,'0','No LVO');

type_hor = type.';
type_string = string(type_hor);
type_string = replace(type_string,'0','Control');
type_string = replace(type_string,'1','Ischemic');
type_string = replace(type_string,'2','Hemorrhagic');
type_string = replace(type_string,'3','Transient');



%%% TABLE OF VARIABLES %%%
stroke_loc = categorical(string(stroke_loc));
gender = categorical(gender);
tab = table(gender,age,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_b,dtabr_b,...
    high_pdBSI,low_pdBSI,front_pdBSI,back_pdBSI);



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

%%% TREEBAGGER LVO %%%
rng(1);
lvo_tree = TreeBagger(50,tab,lvo,'Method','classification','oobpred','On','OOBPredictorImportance','on');

view(lvo_tree.Trees{1},'Mode','graph');

lvo_predicted = predict(lvo_tree,lvo);
RMSE = sqrt(nanmean(lvo_predicted-lvo).^2);
RMSE0 = nanstd(lvo-nanmean(lvo));
r_sq = 1- (RMSE-RMSE0)

[pred_lvo_tree_ooblvo, pred_lvo_tree_ooblvoscores] = oobPredict(lvo_tree);
[conf,lvo_labels] = confusionmat(lvo,pred_lvo_tree_ooblvo,'order',lvo_labels);
disp(dataset({conf,lvo_labels{:}},'obsnames',lvo_labels));


%%% TREEBAGGER STROKE TYPE %%%
rng(1);
stroke_tree = TreeBagger(50,tab,type_string,'OOBPrediction','On','Method','classification');

view(stroke_tree.Trees{1},'Mode','graph');

type_predicted = predict(stroke_tree,type);
RMSE = sqrt(nanmean(type_predicted-type).^2);
RMSE0 = nanstd(type-nanmean(type));
r_sq = 1- (RMSE-RMSE0)


[pred_stroke_tree_oobtype, pred_stroke_tree_oobtypescores] = oobPredict(stroke_tree);
[conf,type_labels] = confusionmat(type_string,pred_stroke_tree_oobtype,'order',type_labels);
disp(dataset({conf,type_labels{:}},'obsnames',type_labels));

%%%TREEBAGER LVO WITH LAMS%%%
tab_2 = table(gender,age,lams,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_b,dtabr_b,high_pdBSI,low_pdBSI,...
    front_pdBSI,back_pdBSI);



%%% DETERMINE LEVELS IN PREDICTORS %%%
func = @(x)numel(categories(categorical(x)));
num_levels = varfun(func,tab_2,'OutputFormat','uniform');

figure
bar(num_levels)
title('Number of Levels Among Predictors')
xlabel('Predictor Variable')
ylabel('Number of Levels')
h = gca;
h.XTick = [1:length(tab_2.Properties.VariableNames)];
h.XTickLabel = tab_2.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';



%%% Train Bagged Ensemble of regression trees%%%
tree = templateTree('NumVariablesToSample','all',...
    'PredictorSelection','interaction-curvature','Surrogate','on');
rng(1); % For reproducibility
Mdl = fitrensemble(tab_2,severity_index,'Method','Bag','NumLearningCycles',200, ...
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
h.XTick = [1:length(tab_2.Properties.VariableNames)];
h.XTickLabel = tab_2.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

figure
imagesc(predAssociation)
title('Predictor Association Estimates')
colorbar
h = gca;
h.XTick = [1:length(tab_2.Properties.VariableNames)];
h.XTickLabel = tab_2.Properties.VariableNames(1:end);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
h.YTick = [1:length(tab_2.Properties.VariableNames)];
h.YTickLabel = Mdl.PredictorNames;

predAssociation(1,2)


rng(1);
lvo_tree = TreeBagger(50,tab_2,lvo,'Method','classification','oobpred','On','OOBPredictorImportance','on');

view(lvo_tree.Trees{1},'Mode','graph');

lvo_predicted = predict(lvo_tree,lvo);
RMSE = sqrt(nanmean(lvo_predicted-lvo).^2);
RMSE0 = nanstd(lvo-nanmean(lvo));
r_sq = 1- (RMSE-RMSE0)

[pred_lvo_tree_ooblvo, pred_lvo_tree_ooblvoscores] = oobPredict(lvo_tree);
[conf,lvo_labels] = confusionmat(lvo,pred_lvo_tree_ooblvo,'order',lvo_labels);
disp(dataset({conf,lvo_labels{:}},'obsnames',lvo_labels));




%%
%%% MUTIPLE REGRESSION FOR NIHSS %%%
tab_NIHSS = table(gender_index,age,pdBSI,rms_gyro_x,rms_gyro_y,rms_gyro_z,sd_gyro_x,sd_gyro_y,sd_gyro_z,...
    rms_acc_x,rms_acc_y,rms_acc_z,sd_acc_x,sd_acc_y,sd_acc_z,dar_g,dtabr_g,fooof_bg_intercept,...
    fooof_bg_slope,beta_relative,theta_relative,alpha_relative,delta_relative,high_pdBSI,low_pdBSI,...
    front_pdBSI,back_pdBSI);
matrix_NIHSS = table2array(tab_NIHSS);

[~,~,~,~,stats] = regress(NIHSS,matrix_NIHSS)