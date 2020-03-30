% START_PARPOOL starts a parallel pool with the full number of cores on local machine
% 
% SurveyBott, info@surveybott.com
function pool = start_parpool()
	numCores = feature('numCores');
	pool = gcp('nocreate');
	if ~isempty(pool) && pool.NumWorkers < numCores
	  delete(pool);
	  pool = gcp('nocreate');
	end
	if isempty(pool)
	  pool = parpool('rcpm', numCores);
	end
end