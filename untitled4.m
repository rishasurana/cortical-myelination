cd /media/sf_VMShared/SeanControls2
folder = dir('ADNI');
cd('ADNI');
for subjectNum = 3:length(folder)
    try
    subject = folder(subjectNum);
    subject = subject.name;
    cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject]);
    cd('Axial_PD_T2_FSE');
    folderHolder = dir('TP1');
    cd('TP1');
    cd(folderHolder(3).name);
    system('mv * ..');
    cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/Axial_PD_T2_FSE/TP1'])
    rmdir(folderHolder(3).name);
    catch
    end
end