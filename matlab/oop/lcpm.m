classdef lcpm < predictory
    methods
        function this = lcpm(group,options)
        %function this = rcpm(varargin)
            this = this@predictory(group,options);
            %this = this@predictory(varargin);
        end
        function run(this)
            
            all_edges = this.group.all_edges;
            all_edges = permute(all_edges, [1, 3, 2]);
            all_edges = reshape(all_edges, [],this.num_sub_total);
            
            rng(this.seed);
            indices = cvpartition(this.num_sub_total,'k',this.k);
            
            for i_fold = 1 : this.k
                fprintf('%dth fold\n', i_fold);
                test.indx = indices.test(i_fold);
                train.indx = indices.training(i_fold);
                test.x = all_edges(:,test.indx);
                train.x = all_edges(:,train.indx);
                test.y = this.phenotype.all_behav(indices.test(i_fold),:);
                train.y = this.phenotype.all_behav(indices.training(i_fold),:);
                
                % first step univariate edge selection
                if size(this.control,1)
                    [edge_corr, edge_p] = partialcorr(train.x', train.y, train.control);
                else
                    [~, edge_p] = corr(train.x', train.y);
                end
                
                edges_1 = find(edge_p < this.thresh);
                
                options = statset('UseParallel', true); %then in lasso, include ‘Options’, options)


                % build model on TRAIN subs
                if ~exist('lambda', 'var')  && length(this.lambda) ~= 1
                    [fit_coef, fit_info] = lassoglm(train.x(edges_1, :)', train.y, 'binomial', 'Alpha',this.v_alpha, 'CV', 4, 'Options', options);
                    idxLambda1SE = fit_info.Index1SE;
                    coef = fit_coef(:,idxLambda1SE);
                    coef0 = fit_info.Intercept(idxLambda1SE);
                    this.lambda_total(i_fold) = fit_info.Lambda(idxLambda1SE);
                else
                    [coef, fit_info] = lasso(train.x(edges_1, :)', train.y, 'Alpha',this.v_alpha, 'Lambda', this.lambda);
                    coef0 = fit_info.Intercept;
                end
                
                % run model on TEST sub with the best lambda parameter
                test.x = all_edges(:, test.indx);
                this.Y(test.indx) = glmval([coef0;coef], test.x(edges_1, :)', 'logit');
                
                this.coef_total(edges_1, i_fold) = coef;
                this.coef0_total(:, i_fold) = coef0;
            end
        end
        
        function evaluate(this)
            % compare predicted and observed behaviors
            [this.r_pearson, ~] = corr(this.Y, this.phenotype.all_behav);
            [this.r_rank, ~] = corr(this.Y, this.phenotype.all_behav, 'type', 'spearman');
            this.mse = sum((this.Y - this.phenotype.all_behav).^2) / this.num_sub_total;
            this.q_s = 1 - this.mse / var(this.phenotype.all_behav, 1);
            fprintf('mse=%f\n',this.mse);
            fprintf('r_pearson=%f\n',this.r_pearson);
            fprintf('r_rank=%f\n',this.r_rank);
            fprintf('q_s=%f\n',this.q_s);
        end
    end
end
