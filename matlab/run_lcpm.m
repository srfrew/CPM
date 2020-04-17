%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  N is the number of subjects
%  T is the number of tasks
%  x: 268*268*N*T
%  y: N*1
%  d: number of elements in lower triangular part of 268*268
%  group: 1*N of type subject
%  subject: a class of 9 task-based connectome and single label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [results] = run_lcpm(x, y, thresh, dataset, k)
    % generate group
    g = buildGroup(x,dataset,'none'); % mask=false, Bins

    % generate options
    options = [];
    options.thresh=thresh;  % 0.01;
    options.seed = randi([1 10000]);
    options.k = k; % 24, 48
    options.phenotype = phenotype('behav',y);
    %options.diagnosis = randi(2,175,1);

    % generate rcpm 
    m = lcpm(g,options);
    m.run(); 
    m.evaluate(); 
    results = m;
end

function g = buildGroup(x,dataset,mask)
	N =size(x,3);
	subjects(1,N) = subject(N);
	for i=1:N
	    subjects(i) = subject(x(:,:,i,:),i,dataset,mask);
	end
	g = group(subjects);
end
