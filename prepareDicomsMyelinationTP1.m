function prepareDicomsMyelinationTP1(subjectDir, subjectName, timePoint)
%clear

mkdir([subjectDir '/' subjectName '/' 'nii']);

niiName = [timePoint 'T1'];
indir  = [subjectDir '/' subjectName '/' 'T1' '/' timePoint];
outnii = [subjectDir '/' subjectName '/' 'nii' '/' niiName  '.nii'];
outres = [subjectDir '/' subjectName '/' 'nii' '/' niiName  'Resliced.nii'];

dicom2nii  (indir,outnii);
reslice_nii(outnii, outres, [1 1 1]);

niiName = [timePoint 'T2'];
indir  = [subjectDir '/' subjectName '/' 'T2' '/' timePoint];
outnii = [subjectDir '/' subjectName '/' 'nii' '/' niiName  '.nii'];
outres = [subjectDir '/' subjectName '/' 'nii' '/' niiName  'Resliced.nii'];

dicom2nii  (indir,outnii);
reslice_nii(outnii, outres, [1 1 1]);

return