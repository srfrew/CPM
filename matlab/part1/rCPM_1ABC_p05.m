% add paths to rcpm scripts
fprintf('Adding paths...\n')
addpath('/scratch/st-tv01-1/ocd/analysis/part1/');
addpath('/scratch/st-tv01-1/ocd/analysis/scripts/');
addpath('/scratch/st-tv01-1/ocd/analysis/scripts/oop');

% paths to cohort and fc structures
demos_path = '/scratch/st-tv01-1/ocd/analysis/part1/cohort_1ABC.mat';
fc_path = '/arc/project/st-tv01-1/ocd/data/derivatives/connectome/shen_denoisedGSR_all.mat';
out_path = '/scratch/st-tv01-1/ocd/analysis/part1/out/rcpm_1ABC_p05.mat';

% load demographics and FC matrices
fprintf('Loading data...\n')
options = struct;
options.groups = {'OCD', 'HC'};
options.GFC = 0;
options.fc_space = 'z';
options.fc_target = 'r';

cohort_1ABC = fc_cohort(demos_path, fc_path, options);

% p-value for initial threshold
thresh = 0.5;

% initialize parallel computing pool 
fprintf('Initializing parpool...\n')
start_parpool; 


%% Part 1 rCPM
% run 1A, rest_tolpre_spt_x_distress
fprintf('Running rcpm_1A...\n')
rCPM(1) = run_rcpm(cohort_1ABC.corr_clusters, cohort_1ABC.demos.data.distress, thresh, "rcpm_1A");

% run 1B, rest_tolpre_spt_x_tolrt
fprintf('Running rcpm_1B...\n')
rCPM(2) = run_rcpm(cohort_1ABC.corr_clusters, cohort_1ABC.demos.data.meanrt2, thresh, "rcpm_1B");

% run 1C, rest_tolpre_spt_x_cybocs_sr_total, with NaN set to 0. 
fprintf('Running rcpm_1C...\n')
rCPM(3) = run_rcpm(cohort_1ABC.corr_clusters, cohort_1ABC.demos.data.cybocs_sr_total, thresh, "rcpm_1C");


%% export 
out = table(rCPM', 'VariableNames', {'pthresh_0.5'}, 'RowNames', {'rcpm_1A', 'rcpm_1B', 'rcpm_1C'});

clearvars -except out cohort_1ABC out_path

save(out_path)