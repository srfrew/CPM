% add paths to rcpm scripts
fprintf('Adding paths...\n')
addpath('/scratch/st-tv01-1/ocd/analysis/part1/');
addpath('/scratch/st-tv01-1/ocd/analysis/rcpm_scripts/');
addpath('/scratch/st-tv01-1/ocd/analysis/rcpm_scripts/oop_scripts');

% load demographics and FC matrices
fprintf('Loading data...\n')
load('cohort_1AB.mat');
cohort_1AB = cohort_1AB(cohort_1AB.group ~= 'SIB', :);
sub_idx = cohort_1AB.group ~= 'SIB';
load('/arc/project/st-tv01-1/ocd/data/derivatives/connectome/shen_denoisedGSR_n53.mat');

% reshape corr_clusters into required (cluster(n),cluster(n),sub(i),task(j))
fprintf('Reshaping FD data...\n')
[corr_clusters, info] = reshape_corr_clusters(out, "r");

% p-value for initial threshold
thresh = 0.1;
iter = 5;

% initialize parallel computing pool 
fprintf('Initializing parpool...\n')
start_parpool; 

%% Part 1 rCPM
% run 1A, rest_tolpre_spt_x_distress
fprintf('Running rcpm_1A...\n')

% run 1A, rest_tolpre_spt_x_distress
rcpm_1A = cell(1, iter);
for i = 1:iter
    fprintf("%d", iter)
	rcpm_1A{i} = run_rcpm(corr_clusters(:, :,sub_idx, :), cohort_1AB.distress(sub_idx), thresh, "rest_tolpre_spt_x_distress");
end
rcpm_1A = cell2rcpm(rcpm_1A); % convert from cell array to array of rcpm objects

clearvars -except rcpm_1A

save('/scratch/st-tv01-1/ocd/analysis/part1/rcpm_part1A_n53-p01-iter.mat')