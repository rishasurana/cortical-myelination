function [] = myelinationMaster1125(subjectFolder, scriptLocation)
direr = dir(subjectFolder);
for folderNum = 3:length(direr)
    try
        suber = direr(folderNum);
        subject = suber.name;
        cd([subjectFolder '/' subject])
        TP1reformater(subjectFolder, subject, 'TP1', 'rh', scriptLocation);
        cd([subjectFolder '/' subject])
        TP1reformater(subjectFolder, subject, 'TP1', 'lh', scriptLocation);
        
    catch
        disp([string(subject) "didnt work"])
    end
end
end