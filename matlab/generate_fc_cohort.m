function [cohort, corr_clusters, info] = generate_fc_cohort(cohort_path, fc_path)
% simon frew, srfrew, vanderlab march 2020 
%
% generate corr_clusters and info of FC data given a cohort table.
% accounts for desired tasks and runs. 
%
% INPUT:
%   cohort_path     path to .mat file containing 'cohort' structure that must include a .data field containing a table of demographics.
%                       table must include at least .sub, .task, fields. 
%   fc_path         path to .mat file containing 'out' structure that must include a .corr_clusters field containing FC data and a .info field containing preprocessing info
%
% OUTPUT:
%   cohort          cohort structure submitted in cohort_path
%   corr_clusters   4D array of FC data compatible with YaleMRRC oop-(r)CPM: cluster(n),cluster(n),sub(i),task(j)
%   info            2D array of .info structs corresponding to corr_clusters: sub(i),task(j)
% 
    
    % load cohort data, FC data, generating struct "out" and "cohort"
    load(cohort_path)
    load(fc_path)
    
    sub_count = size(cohort.data, 1);
    task_count = size(cohort.data.task, 2);

    corr_clusters = zeros(size(out.corr_clusters,1), size(out.corr_clusters,2), sub_count, task_count);
    info = out.info([]);

    for i = 1:sub_count % iterate through subjects
        for j = 1:task_count % iterate through tasks for subject 
            % create index into appropriate FC matrix based on sub ID and task ID (really bad implementation, wip) 
            idx = [out.info.sub] == str2double(regexp(string(cohort.data.sub(i)), '\d..', 'match')) & contains({out.info.task}, cohort.data.task{i, j}(1:4));
            if sum(idx) == 1
                corr_clusters(:,:,i,j) = out.corr_clusters(:,:,idx);
                info(i,j) = out.info(idx);
            else
                if sum(idx) == numel([out.info(idx).run]) % if there are multiple runs, match and use the correct run from the cohort.data table. 
                    idx_idx = find(idx);
                    idx(idx_idx([out.info(idx).run] ~= str2double(cohort.data.task{i, j}(end)))) = 0;
                    corr_clusters(:,:,i,j) = out.corr_clusters(:,:,idx);
                    info(i,j) = out.info(idx);
                else
                    error('ERROR: %s has %d %s runs',cohort.data.sub(i),sum(idx),cohort.data.task{i,j});
                end
            end
        end
    end
end
