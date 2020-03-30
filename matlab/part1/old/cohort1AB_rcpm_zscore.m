% add paths to rcpm scripts
fprintf('Adding paths...\n')
addpath('/scratch/st-tv01-1/ocd/analysis/part1/');
addpath('/scratch/st-tv01-1/ocd/analysis/rcpm_scripts/');
addpath('/scratch/st-tv01-1/ocd/analysis/rcpm_scripts/oop_scripts');

% load demographics and FC matrices
fprintf('Loading data...\n')
load('cohort_1AB.mat');
cohort_1AB = cohort_1AB(cohort_1AB.group ~= 'SIB', :);
load('/arc/project/st-tv01-1/ocd/data/derivatives/connectome/shen_denoisedGSR_n53.mat');

% reshape corr_clusters into required (cluster(n),cluster(n),sub(i),task(j))
fprintf('Reshaping FD data...\n')
[corr_clusters, info] = reshape_corr_clusters(out, "r");

% p-value for initial threshold
thresh = 0.1;

% initialize parallel computing pool 
fprintf('Initializing parpool...\n')
start_parpool; 

%% Part 1 rCPM
% run 1A, rest_tolpre_spt_x_distress
fprintf('Running rcpm_1A...\n')
rcpm_1A = run_rcpm(corr_clusters, zscore(cohort_1AB.distress), thresh, "rest_tolpre_spt_x_distress");

% run 1B, rest_tolpre_spt_x_tolrt
fprintf('Running rcpm_1B...\n')
rcpm_1B = run_rcpm(corr_clusters, zscore(cohort_1AB.meanrt2), thresh, "rest_tolpre_spt_x_tolrt");

clearvars -except rcpm_1A rcpm_1B

save('/scratch/st-tv01-1/ocd/analysis/part1/rcpm_part1AB_n53-zscore.mat')