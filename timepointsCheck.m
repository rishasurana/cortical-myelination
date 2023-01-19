% Function to test if following timepoint is availible for a particular
% subject, for any number of timepoints
function [beginSec, maxNum] = timepointsCheck(subjectFolder, subject, secFiles, backtrace)
    TPDest = ([subjectFolder '/' subject]);
    dirPath = dir(TPDest);
    maxNum = nnz(~ismember({dirPath.name},{'.','..'})&[dirPath.isdir]);
    
    beginSec = 0;
    
    % For each timepoint, check if it has already run the section files for
    % the subject.
    for tp = 1:maxNum
        tpStr = int2str(tp);
        if backtrace == 0
            secDestTP = ([subjectFolder '/' subject '/TP' tpStr 'fs/mri/orig']);
        else
            %disp('Backtracing for T2.prenorm.nii');
            secDestTP = ([subjectFolder '/' subject '/TP' tpStr 'fs/mri']);
        end
        beginSecTP = subjectProgressCheck(secFiles, secDestTP);
        % If even one timepoint is incomplete, must begin the section.
        if beginSecTP == 1
            beginSec = 1;
            break;
        end        
    end
end
