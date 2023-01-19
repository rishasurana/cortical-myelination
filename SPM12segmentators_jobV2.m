directorStr = '/media/sf_VMShared/MyelinAllSubjects/TestingGroups/2_TP_Test';
director = dir(directorStr);


for z = 3:length(director)
    sub = director(z).name;
    disp(sub);
    
matlabbatch{z-2}.spm.spatial.preproc.channel.vols = {
                                                   [directorStr '/' sub '/TP1fs/mri/T2.prenorm.nii,1']
                                                   [directorStr '/' sub '/TP1fs/mri/orig/001.nii,1']
                                                   [directorStr '/' sub '/TP2fs/mri/T2.prenorm.nii,1']
                                                   [directorStr '/' sub '/TP2fs/mri/orig/001.nii,1']
                                                   };
matlabbatch{z-2}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{z-2}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{z-2}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{z-2}.spm.spatial.preproc.tissue(1).tpm = {'/media/sf_VMShared/spm12/tpm/TPM.nii,1'};
matlabbatch{z-2}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{z-2}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(2).tpm = {'/media/sf_VMShared/spm12/tpm/TPM.nii,2'};
matlabbatch{z-2}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{z-2}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(3).tpm = {'/media/sf_VMShared/spm12/tpm/TPM.nii,3'};
matlabbatch{z-2}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{z-2}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(4).tpm = {'/media/sf_VMShared/spm12/tpm/TPM.nii,4'};
matlabbatch{z-2}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{z-2}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(5).tpm = {'/media/sf_VMShared/spm12/tpm/TPM.nii,5'};
matlabbatch{z-2}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{z-2}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{z-2}.spm.spatial.preproc.tissue(6).tpm = {'/media/sf_VMShared/spm12/tpm/TPM.nii,6'};
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
end
