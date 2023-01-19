% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/home/wk1/Documents/Myelin_Project/MyelinationCode/SPM12segmentators_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
try
spm_jobman('run', jobs, inputs{:});
catch
end


