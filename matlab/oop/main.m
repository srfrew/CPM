%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  N is the number of subjects
%  T is the number of tasks
%  x: 268*268*N*T
%  y: N*1
%  d: number of elements in lower triangular part of 268*268
%  group: 1*N of type subject
%  subject: a class of 9 task-based connectome and single label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [results] = main(x, y,thresh)
    dataset = "ocd.24"; % LDA on UCLA + ages on 3 bins for HCP
    x = x; %rand(268,268,48,2);%load('all_mats.mat');
    y = y; %randi(30,48,1);%load('IQ.mat');
    g = buildGroup(x,dataset,'none'); % mask=false, Bins
    options = [];
    options.thresh=thresh;
    options.seed = randi([1 10000]);
    options.k = length(y); % 24, 48
    options.phenotype = phenotype('behav',y);
    %options.diagnosis = randi(2,175,1);
    m = rcpm(g,options);
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


