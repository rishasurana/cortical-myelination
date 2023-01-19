% Function to test if certain files have been added before beginning a
% section of code. Needs two components to work: 1. An array of files to
% check for (which can just be the last known file for EACH section (for each timepoint)
% and 2. a destination dependent on the subject name and TP1 or TP2
function [beginSec] = subjectProgressCheck(checkFile, destLoc)

%dir(destLoc);
%addpath(destLoc);

count = 0;
file = fullfile(destLoc,checkFile);
numExist = isfile(file);
if numExist
    count = count + 1;
end
    

if count == 1
    beginSec =  0;
else
    beginSec = 1;
end

end
        
