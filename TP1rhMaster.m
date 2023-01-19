addpath(genpath('/media/sf_VMShared/MyelinationCode/MyelinationToolbox/'));
addpath(genpath('/media/sf_VMShared/MyelinationCode/'));
direr = dir('/media/sf_VMShared/SeanControls2/ADNI');
for folderNum = 3:length(direr)
    try
        suber = direr(folderNum); 
        subject = suber.name;
        disp(['Subject is ' subject]); 
        rh = fs_read_surf(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/surf/rh.white']);
        newVectorsrh = surfAnalysis(rh);
        
        cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii']);
        [vol,  M , mr_parms , volsz ] = fs_load_mgh(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/mri/aparc.a2009s+aseg']);
        [volb, Mb, mr_parmsb, volszb] = fs_load_mgh(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/mri/orig']);
        nii = load_nii(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T1Resliced.nii']);
        nii2 = load_nii(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T2Resliced.nii']);
        
        T1moved = alignNii(nii);
        T2moved = alignNii2(nii2);
        vole = alignVol(vol);
        voleb = alignVol(volb);
    
        T2movednii = load_nii(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T2toT1Reg.nii']);
        T2moved = T2movednii.img;
        lenghtera = length(T2moved);
        if (lenghtera > 256)
           T2moved = T2moved(1:end-1,1:end-1,1:end-1);
        end
        
        lenghtera = length(T1moved);
        if (lenghtera > 256)
           T1moved = T1moved(1:end-1,1:end-1,1:end-1);
        end
        
        
        GMlb = vole;
        GMlb(GMlb <  11000) = 0;
        GMlb(GMlb >= 11000) = 1;
        GMlb = logical(GMlb);
        xw = find(GMlb > 0);
        GMT1 = T1moved.*GMlb;
        GMT2 = T2moved.*GMlb;
        T1T2 = GMT1./GMT2;
        f = find(isnan(T1T2)); T1T2(f) = 0;
        f = find(isinf(T1T2)); T1T2(f) = 0;
        
        
        mapIntensities = weightedIntensity(rh.vertices, newVectorsrh, xw, T1T2);
        mapIntensities = sqrt(mapIntensities);
        nullVals = find(mapIntensities == 0);
        
        mapIntensities2 = mapIntensities;
        mapIntensities2(nullVals) = 0;
        figure
        histogram(mapIntensities2, 500);
        
        cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject])
        save('rhTP1mapVals.mat', 'mapIntensities');
        save('rhTP1transformVals.mat', 'M');
        rhTP1reformater(subject);
        
    catch
        disp('Subject failed');
    end
    disp('done');
end