system(['fast -t 2 -B ' subjectFolder '/' subject '/nii/brainlessnoBiasT2.nii --nopve ' subjectFolder '/' subject '/nii/brainlessTP2T2toT1Reg.nii']);
addpath('/media/sf_VMShared/MyelinationCode');
gunzip('brainlessTP2T2toT1Reg_restore.nii.gz');
T2 = load_nii(['brainlessTP2T2toT1Reg_restore.nii']);
T1 = load_nii(['TP2T1Out_restore.nii']);
T2 = T2.img;
T1 = T1.img;

if (length(T2) > 256)            %ensuring T2 is the same length as T1
    T2 = T2(1:end-1,1:end-1,1:end-1);
end
if (length(T1) > 256)            %ensuring T2 is the same length as T1
    T1 = T1(1:end-1,1:end-1,1:end-1);
end

[vol,  ~, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/freesurfer/TP2'  '/fs/'  'mri/brainmask']);
vole = alignVol(vol);
GMlb = vole;
GMlb = logical(GMlb);
T1 = T1.*GMlb;
T1T2 = (T1./T2);

R2 = T1T2(:,:,100); % time 2
D  = R2;% - R1;
fnan = find(isnan(D));
D(fnan) = 0;

n = numel(find(D~=0));
fneg = numel(find(D<0))/n;
fpos = numel(find(D>0))/n;

figure;
imagesc(D); axis equal tight
colormap jet; caxis([-2 2]); colorbar;
mx = max(max(D));

b = find(T1T2 > 0.02);
newT1T2 = T1T2;
newT1T2(b) = 0;

figure
subplot(2,3,1); imagesc(T1(:,:,100)); axis equal tight 
subplot(2,3,2); imagesc(T2(:,:,100)); axis equal tight
subplot(2,3,3); imagesc(vole(:,:,100)); axis equal tight
subplot(2,3,4); imagesc(newT1T2(:,:,100)); axis equal tight; caxis([0 .15]);
subplot(2,3,5); imagesc(T1T2(:,:,100)); axis equal tight; caxis([0 .15]);
subplot(2,3,6); plot3(lh.vertices(1:100:end, 1), lh.vertices(1:100:end, 2), lh.vertices(1:100:end, 3), 'o');


[vol,  ~, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/freesurfer/TP2'  '/fs/'  'mri/aparc.a2009s+aseg']);
vole = alignVol(vol);
GMlb = vole;
GMlb(GMlb <  11000) = 0;
GMlb(GMlb >= 11000) = 1;
GMlb = logical(GMlb);
xw = find(GMlb > 0);
        
lh = fs_read_surf([subjectFolder '/' subject '/freesurfer/TP2/fs/surf/lh.white']);
rh = fs_read_surf([subjectFolder '/' subject '/freesurfer/TP2/fs/surf/rh.white']);
newVectorslh = surfAnalysis(lh);            %create vectors for each face and does a bunch of averaging
newVectorsrh = surfAnalysis(rh);

TP2mapIntensitieslh = weightedIntensity(lh.vertices, newVectorslh, xw, newT1T2); %takes vertices, vectors, GM voxels, and T1/T2 matrix   
TP2mapIntensitiesrh = weightedIntensity(rh.vertices, newVectorsrh, xw, newT1T2);

cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
disp('TP2');
save(['TP2rhmapVals.mat'], 'TP2mapIntensitiesrh');
TP1reformater(subjectFolder, subject, 'TP2', 'rh');
cd([subjectFolder '/' subject])
save(['TP2lhmapVals.mat'], 'TP2mapIntensitieslh');
TP1reformater(subjectFolder, subject, 'TP2', 'lh');








