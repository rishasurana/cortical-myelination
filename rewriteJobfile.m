function rewriteJobfile(jobfile,subjectDir,timepoint)
% Rewrites the job file to automatically refer to the subject directory, as
% well as editing it to deal with 1 or 2 timepoints as needed.


temp    = 'temp.m'; % file that will hold the edited version
% Open the input file to read and the output file to append
[jobfileID,~] = fopen(jobfile,'rt');
[tempID,~]    = fopen(temp,'at');
textLine      = fgetl(jobfileID);
lineCounter   = 1;

while ischar(textLine)
    % edit the line if it sets the directorStr variable
    if contains(textLine,'directorStr = ')
        textLine = char(['directorStr = ''' subjectDir ''';']);
    end
    % edit it to be single timepoint if needed
    if contains(textLine,'TP2fs') && timepoint == 1 && ~(contains(textLine,'%'))
        textLine = char(['%' textLine]); 
    end
    % edit it to be two timepoints if needed
    if contains(textLine,'TP2fs') && timepoint == 2
       textLine = char(erase(textLine,'%')); 
    end
    
    % write the line to temp
    fprintf(tempID,'%s\n',textLine);
    % grab the next line 
    textLine    = fgetl(jobfileID);
    lineCounter = lineCounter + 1;
end

% close file
fclose(jobfileID);
fclose(tempID);
delete(jobfile);
movefile(temp,jobfile,'f');

end