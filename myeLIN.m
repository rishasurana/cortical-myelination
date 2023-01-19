addpath(genpath('C:\Users\P06\Desktop\BrainConnectivityMatrix\fstools'));
addpath(genpath('D:\Di\dcm2niix_11-Apr-2019_win'));
addpath(genpath('C:\Users\P06\Desktop\BrainConnectivityMatrix\Kenny'));
addpath(genpath('C:\Users\P06\Desktop\Myelination'));
addpath(genpath('C:\Users\P06\Desktop\BrainConnectivityMatrix\nii'));

subject = '023_S_0058';
lh = fs_read_surf(['D:\SeanMyelinationControls\ADNI\' subject '\freesurfer\TP2\fs\surf\lh.white']);
rh = fs_read_surf(['D:\SeanMyelinationControls\ADNI\' subject '\freesurfer\TP2\fs\surf\rh.white']);

newVectorslh = surfAnalysis(lh);

% loading meshes
[vol,  M , mr_parms , volsz ] = fs_load_mgh(['D:\SeanMyelinationControls\ADNI\' subject '\freesurfer\TP2\fs\mri\aparc.a2009s+aseg']);
[volb, Mb, mr_parmsb, volszb] = fs_load_mgh(['D:\SeanMyelinationControls\ADNI\' subject '\freesurfer\TP2\fs\mri\orig_1']);



nii = load_nii(['D:\SeanMyelinationControls\ADNI\' subject '\nii\T1' subject 'Resliced.nii']);
nii2 = load_nii(['D:\SeanMyelinationControls\ADNI\' subject '\nii\T2toT1_MI.nii']);
[T1moved, T2moved, vol, volb] = alignImages(nii, nii2, vol, volb);

GMlb = vol; 
GMlb(GMlb <  11000) = 0;
GMlb(GMlb >= 11000) = 1;
GMlb = logical(GMlb);
xw = find(GMlb > 0);
GMT1 = volb.*GMlb;
GMT2 = T2moved.*GMlb;
T1T2 = GMT1./GMT2;
f = find(isnan(T1T2)); T1T2(f) = 0;
f = find(isinf(T1T2)); T1T2(f) = 0;

mapIntensities = weightedIntensity(lh.vertices, newVectorslh, xw, T1T2);
mapIntensities = sqrt(mapIntensities);
nullVals = find(mapIntensities == 0);
mapIntensities2 = mapIntensities;
% f = find(mapIntensities > .5); mapIntensities2(f) = .5

mapIntensities2(nullVals) = 0;
figure
histogram(mapIntensities2, 500);


figure;
scatter3(lh.vertices(:,1),lh.vertices(:,2),lh.vertices(:,3),[],mapIntensities2);
axis equal tight; 
colormap(hot);
colorbar;
caxis([0.3,0.65])
hold on;
