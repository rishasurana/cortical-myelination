%directorStr = '/home/wk1/Documents/Myelin_Project/Subjects/TRACK_TBI'
%global subjectFolder;
directorStr = ['' getSubFold() ''];
director    = dir(directorStr);
%disp(dest);

toSkip = false(length(director),1);
for i=3:length(director)
    sub = director(i).name;
    secSPMFiles = {'m001.nii'};
    [beginSecSPM, limit] = timepointsCheck(directorStr, sub, secSPMFiles, 0);
    
    if (~beginSecSPM || limit ~= 2)
        disp(['Skip ' sub '!']);
        toSkip(i) = 1;
    else
        disp(['Begin ' sub '!']);
    end
end

director(toSkip) = [];

for z = 3:length(director)
    sub = director(z).name;
    %disp(sub);
    %Skipping the first subject in the directory causes the SPM to skip for
    %all of them, even though it makes it to the end of the file for the
    %subjects that did not have SPM. This could indicate that the subjects
    %are interconnected at some point and that the
    %matlabbatch file somehow uses the whole directory/first subject at some point, and
    %skipping the first, seccond, etc one causes the rest to not run. If you try to run
    %from the 2nd file, it still will not work.
    
    %TODO: 1. find out why the subjects are interrconected [black box?] 2. If that is
    %not resolvable, find a way to check which subjects have the neccessary
    %SPM files, move the ones that don't into a temp directory, do the SPM, and then
    %add them back to the main one.
%     secSPMFiles = {'m001.nii'};
%     [beginSecSPM, limit] = timepointsCheck(directorStr, sub, secSPMFiles, 0);
%     
%     if (~beginSecSPM || limit ~= 2)
%         disp(['Skip ' sub '!']);
%         continue;
%     else
%         disp(['Begin ' sub '!']);
%     end
    
    matlabbatch{z-2}.spm.spatial.preproc.channel.vols = {
                                                       [directorStr '/' sub '/TP1fs/mri/T2.prenorm.nii,1']
                                                       [directorStr '/' sub '/TP1fs/mri/orig/001.nii,1']
                                                       [directorStr '/' sub '/TP2fs/mri/T2.prenorm.nii,1']
                                                       [directorStr '/' sub '/TP2fs/mri/orig/001.nii,1']
                                                       };
    matlabbatch{z-2}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{z-2}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{z-2}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(1).tpm = {'/home/wk1/Downloads/spm12/tpm/TPM.nii,1'};
    matlabbatch{z-2}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{z-2}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(2).tpm = {'/home/wk1/Downloads/spm12/tpm/TPM.nii,2'};
    matlabbatch{z-2}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{z-2}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(3).tpm = {'/home/wk1/Downloads/spm12/tpm/TPM.nii,3'};
    matlabbatch{z-2}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{z-2}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(4).tpm = {'/home/wk1/Downloads/spm12/tpm/TPM.nii,4'};
    matlabbatch{z-2}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{z-2}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(5).tpm = {'/home/wk1/Downloads/spm12/tpm/TPM.nii,5'};
    matlabbatch{z-2}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{z-2}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(6).tpm = {'/home/wk1/Downloads/spm12/tpm/TPM.nii,6'};
    matlabbatch{z-2}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{z-2}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{z-2}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{z-2}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{z-2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{z-2}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{z-2}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{z-2}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{z-2}.spm.spatial.preproc.warp.write = [0 0];

    disp('Made it to the end of SPM.');
end
