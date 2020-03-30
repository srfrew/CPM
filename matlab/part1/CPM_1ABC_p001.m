% add paths to rcpm scripts
fprintf('Adding paths...\n')
% addpath('/scratch/st-tv01-1/ocd/analysis/part1/');
% addpath('/scratch/st-tv01-1/ocd/analysis/rcpm_scripts/');
% addpath('/scratch/st-tv01-1/ocd/analysis/rcpm_scripts/oop_scripts');

demos_path = 'C:\Users\simon\Dropbox\Simon_Tammy\ocd_cpm\cohorts\1AB - basic_cohort\scripts\cohort_1ABC.mat';
fc_path = 'C:\Users\simon\Desktop\shen_denoisedGSR_all.mat'; 

% paths to cohort and fc structures
% demos_path = '/scratch/st-tv01-1/ocd/analysis/part1/cohort_1ABC.mat';
% fc_path = '/arc/project/st-tv01-1/ocd/data/derivatives/connectome/shen_denoisedGSR_all.mat';
% out_path = '/scratch/st-tv01-1/ocd/analysis/part1/out/cpm_1ABC_p001.mat';

% load demographics and FC matrices
fprintf('Loading data...\n')
options = struct;
options.groups = {'OCD', 'HC'};
options.GFC = 1;
options.fc_space = 'z';
options.fc_target = 'r';

cohort_1ABC = fc_cohort(demos_path, fc_path, options);

% p-value for initial threshold
thresh = 0.01;

% initialize parallel computing pool 
fprintf('Initializing parpool...\n')
% start_parpool; 


%% Part 1 rCPM
% run 1A, rest_tolpre_spt_x_distress
fprintf('Running cpm_1A...\n')
CPM(1) = run_cpm(cohort_1ABC.corr_clusters, cohort_1ABC.demos.data.distress, thresh, "cpm_1A");

% run 1B, rest_tolpre_spt_x_tolrt
fprintf('Running cpm_1B...\n')
CPM(2) = run_cpm(cohort_1ABC.corr_clusters, cohort_1ABC.demos.data.meanrt2, thresh, "cpm_1B");

% run 1C, rest_tolpre_spt_x_cybocs_sr_total, with NaN set to 0. 
fprintf('Running cpm_1C...\n')
CPM(3) = run_cpm(cohort_1ABC.corr_clusters, cohort_1ABC.demos.data.cybocs_sr_total, thresh, "cpm_1C");


%% export 
out = table(CPM', 'VariableNames', {'pthresh_0.01'}, 'RowNames', {'cpm_1A', 'cpm_1B', 'cpm_1C'});

% clearvars -except out cohort_1ABC

% save(out_path)