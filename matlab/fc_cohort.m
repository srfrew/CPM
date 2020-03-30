classdef fc_cohort < handle
    % add description here
    properties
        
        demos;          % struct with tables. Cohort structure containing demographic and task data. data used for analysis is in the .data field. 
        fc_info;        % sub(i),task(j) struct array. Modified info struct from fc_path .mat file. Modified to map directly onto corr_cluster's sub(i),task(j)
        corr_clusters;  % cluster(n),cluster(n),sub(i),task(j) numerical array. Contains FC matrices for subjects to be used for analysis. 
        tasks;          % Cell array with char. List of all tasks selected for analysis. Currently preselected in this.demos.data.tasks as they are subject specific.
        groups;         % Cell array with char: Any combination of {'OCD', 'HC', 'SIB'}. List of groups included in this.corr_clusters and this.demos.data for analysis.
        fc_space        % string: 'r', 'z'. Represents current space of corr_clusters FC values, either r - pearson, or z - fischer z transform
        fc_target       % string: 'r', 'z'. Represents target space of corr_clusters. When equal to fc_space, transformation is complete. When this.update() or this.transform_fc() is called, transformation will occur. 
        GFC;            % Boolean: 0, 1. General functional connectivity matrix option. If 1, edges will be averaged across tasks and within subjects, and updated in this.corr_clusters

        
        all_tasks;      % List of all tasks present in source FC data from fc_path
        all_groups;     % Cell array with char: Any combination of {'OCD', 'HC', 'SIB'}. List of all groups present in source demographic data from this.demos.all
        
        demos_path;     % string / character. Path to .mat file containing struct named 'cohort' of demographic/task data (fields all and info)
        fc_path;        % string / character. Path to .mat file containing struct named 'out' of FC data (fields corr_clusters and info)(e.g., shen_denoisedGSR_all.mat)

        initial_options % Struct. Inital options submitted when initializing instance of class for reference. 

    end
    methods
        function this = fc_cohort(varargin)
            % Input: demos_path, fc_path, options


            % load default properties    
            
            this.demos_path = 'C:\Users\simon\Dropbox\Simon_Tammy\ocd_cpm\cohorts\1AB - basic_cohort\scripts\cohort_1ABC.mat';
            this.fc_path = 'C:\Users\simon\Desktop\shen_denoisedGSR_all.mat'; 
            options = struct;
            this.fc_space = 'z';
            this.fc_target = 'r';
            this.GFC = 0;

            this.groups = {'OCD', 'HC'};
            this.tasks = {'rest', 'tol', 'spt'};
            
            if numel(varargin) == 3
                this.demos_path = varargin{1};
                this.fc_path = varargin{2}; 
                this.initial_options = varargin{3};
                options = varargin{3};
            end
            
            
            % apply options
            if isfield(options, 'groups')
                this.groups = options.groups;
            end

            if isfield(options, 'GFC')
                this.GFC = options.GFC;
            end

            if isfield(options, 'fc_space')
                this.fc_space = options.fc_space;
            end

            if isfield(options, 'fc_target')
                this.fc_target = options.fc_target;
            end

            this.update()

        end
    end

    methods
        function [] = update(this)
            % run all functions to update data: 

            this.generate_fc_cohort()
            this.transform_fc()
            this.create_GFC()

        end

        function [] = generate_fc_cohort(this)
        % simon frew, srfrew, vanderlab march 2020 
        %
        % generate corr_clusters and info of FC data given a cohort table.
        % accounts for desired tasks and runs. 
        %
        % Required INPUT:
        %   this.demos_path     path to .mat file containing 'cohort' structure that must include a .data field containing a table of demographics.
        %                       table must include at least .sub, .task, fields. 
        %   this.fc_path         path to .mat file containing 'out' structure that must include a .corr_clusters field containing FC data and a .info field containing preprocessing info
        %
        % OUTPUT:
        %   this.demos           cohort structure submitted in demos_path
        %   this.corr_clusters   4D array of FC data compatible with YaleMRRC oop-(r)CPM: cluster(n),cluster(n),sub(i),task(j)
        %   this.info            2D array of .info structs corresponding to corr_clusters: sub(i),task(j)
        % 
            
            % load cohort data, FC data, generating struct "out" and "cohort"
            load(this.demos_path)
            load(this.fc_path)

            % assign all_tasks / all_groups parameters
            this.all_tasks = unique({out.info.task});
            this.all_groups = unique(cellstr(cohort.all.group)');


            cohort.data = cohort.all(any(cohort.all.group == this.groups, 2), :);
            
            sub_count = size(cohort.data, 1);
            task_count = size(cohort.data.task, 2);

            corr_clusters = zeros(size(out.corr_clusters,1), size(out.corr_clusters,2), sub_count, task_count);
            info = out.info([]);

            for i = 1:sub_count % iterate through subjects
                for j = 1:task_count % iterate through tasks for subject 
                    % create index into appropriate FC matrix based on sub ID and task ID (really bad implementation, wip) 
                    idx = [out.info.sub] == str2double(extractAfter(string(cohort.data.sub(i)), '-')) & contains({out.info.task}, regexp(string(cohort.data.task{i, j}), "^[^_]*", 'match'));
                    if sum(idx) == 1
                        corr_clusters(:,:,i,j) = out.corr_clusters(:,:,idx);
                        info(i,j) = out.info(idx);
                    else
                        if sum(idx) == numel([out.info(idx).run]) % if there are multiple runs, match and use the correct run from the cohort.data table. 
                            idx_idx = find(idx);
                            idx(idx_idx([out.info(idx).run] ~= str2double(regexp(string(cohort.data.task{i, j}), "[^-]$", 'match')))) = 0;
                            corr_clusters(:,:,i,j) = out.corr_clusters(:,:,idx);
                            info(i,j) = out.info(idx);
                        else
                            error('ERROR: %s has %d %s runs',cohort.data.sub(i),sum(idx),cohort.data.task{i,j});
                        end
                    end
                end
            end
            this.demos = cohort; 
            this.corr_clusters = corr_clusters;
            this.fc_info = info;
        end

        function [] = transform_fc(this)
            if ~(any(this.fc_target == ['r', 'z']))
                fprintf("this.fc_target must = ['r', 'z'], currently = '%s'\n", this.fc_target)
            elseif ~(any(this.fc_space== ['r', 'z']))
                fprintf("this.fc_space must = ['r', 'z'], currently = '%s'\n", this.fc_space)

            elseif this.fc_space == 'z' && this.fc_target == 'r'
                this.corr_clusters = tanh(this.corr_clusters);
                this.fc_space = this.fc_target;
            elseif this.fc_space == 'r' && this.fc_target == 'z'
                this.corr_clusters = atanh(this.corr_clusters);
                this.fc_space = this.fc_target;
            end
        end

        function [] = create_GFC(this)
            if this.GFC && (ndims(this.corr_clusters) == 4)
                this.corr_clusters = mean(this.corr_clusters, 4);
            elseif length(size(this.corr_clusters)) ~= 4
                fprintf('GFC already created, corr_clusters has %d dimensions.\n', ndims(this.corr_clusters))
            end
        end


    end
end
