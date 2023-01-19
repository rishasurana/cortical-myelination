function prepareDicomsMyelination(subjectDir, subjectName)
%clear

cd(subjectDir);
cd(subjectName);
mkdir 'nii';

niiName = ['T1'];
indir  = [subjectDir '/' subjectName '/' 'MPRAGE' '/' 'TP2'];
outnii = [subjectDir '/' subjectName '/' 'nii' '/' niiName  '.nii'];
outres = [subjectDir '/' subjectName '/' 'nii' '/' niiName  'Resliced.nii'];

dicom2nii  (indir,outnii);
reslice_nii(outnii, outres, [1 1 1]);

folderHolder = dir('Axial_PD_T2_FSE');
folderMan = folderHolder(4);
folderMan = folderMan.name;
cd('Axial_PD_T2_FSE');
folderHolder = dir([folderMan]);
cd(folderMan);
folderMan2 = folderHolder(3);
folderMan2 = folderMan2.name;


niiName = ['T2'];
indir  = [subjectDir '/' subjectName '/' 'Axial_PD_T2_FSE' '/' 'TP2' '/' folderMan2];
outnii = [subjectDir '/' subjectName '/' 'nii' '/' niiName  '.nii'];
outres = [subjectDir '/' subjectName '/' 'nii' '/' niiName  'Resliced.nii'];

dire = dir(indir);

dicom2nii  (indir,outnii);
reslice_nii(outnii, outres, [1 1 1]);

return