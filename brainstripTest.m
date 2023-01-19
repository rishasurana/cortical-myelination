addpath('/media/sf_VMShared/MyelinationCode');
cd(['/home/andrei/Desktop/Slicer-4.10.2-linux-amd64']);
system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject '/nii/' 'TP2T1Out.nii --movingVolume ' subjectFolder '/' subject '/nii/' 'TP2T2Out.nii --outputVolume ' subjectFolder '/' subject '/nii/'  'TP2T2toT1Regtest.nii --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline --samplingPercentage 0.02']);
cd([subjectFolder '/' subject  '/nii']);
[volbrain,  ~, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/freesurfer/TP2'  '/fs/'  'mri/brainmask']);
TP2nii2 = load_nii(['/media/sf_VMShared/TBIDone/007/nii/TP2T2toT1Regtest.nii']);
[TP2nii2, opp2] = KENNIMatchMatricesDim3(TP2nii2.img,zeros(256,256,256));
if (length(TP2nii2) > 256)
    TP2nii2 = TP2nii2(1:end-1,1:end-1,1:end-1);
end
volbrain = alignVol(volbrain);
brainless = TP2nii2 .* volbrain;
newNii = make_nii(brainless, [1 1 1]);
save_nii(newNii, ['brainlessTP2T2toT1Reg.nii']);

newNii = make_nii(volbrain, [1 1 1]);
save_nii(newNii, ['brainMaskF.nii']);

system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject '/nii/brainMaskF.nii ' '--movingVolume ' subjectFolder '/' subject '/nii/' 'brainlessTP2T2toT1Reg.nii --outputVolume ' subjectFolder '/' subject '/nii/'  'TP2T2toT1Reg2.nii --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline --samplingPercentage 0.05']);

T1 = load_nii(['TP2T1Out_restore.nii']);
[T1, opp2] = KENNIMatchMatricesDim3(T1.img,zeros(256,256,256));
if (length(T1) > 256)
    T1 = T1(1:end-1,1:end-1,1:end-1);
end


figure
subplot(2,2,1); imagesc(T1(:,:,100)); axis equal tight 
subplot(2,2,2); imagesc(TP2nii2(:,:,100)); axis equal tight
subplot(2,2,3); imagesc(brainless(:,:,100)); axis equal tight
subplot(2,2,4); imagesc(volbrain(:,:,100)); axis equal tight

