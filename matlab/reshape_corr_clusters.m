function [corr_clusters, info] = reshape_corr_clusters(out, conversion)
% quick script to restructure n53 corr_clusters to (cluster(n),cluster(n),sub(i),task(j))
%  and make new info(sub,task)
% load original data
% load('shen_denoisedGSR_n53.mat');

% restructure
sub = unique([out.info.sub]);
task = {'tol' 'spt'};

corr_clusters = zeros(size(out.corr_clusters,1),size(out.corr_clusters,2),numel(sub),numel(task));

info = out.info([]);

for i=1:numel(sub)
    for j=1:numel(task)
        idx = [out.info.sub] == sub(i) & contains({out.info.task},task{j});
        if sum(idx) == 1
            corr_clusters(:,:,i,j) = out.corr_clusters(:,:,idx);
            info(i,j) = out.info(idx);
        else
           error('ERROR: sub-%03d has %d %s runs',sub(i),sum(idx),task{j});
        end
    end
end

if conversion == "r"
	corr_clusters = tanh(corr_clusters);
end

end
