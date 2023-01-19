addpath(genpath('/media/sf_VMShared/MyelinationCode/MyelinationToolbox/'));
addpath(genpath('/media/sf_VMShared/MyelinationCode/'));
direr = dir('/media/sf_VMShared/SeanControls2/ADNI');
for folderNum = 4:length(direr)
    try
        suber = direr(folderNum); 
        subject = suber.name;
        disp(['Subject is ' subject]); 
        prepareDicomsMyelinationTP1('/media/sf_VMShared/SeanControls2/ADNI',subject);

        lh = fs_read_surf(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/surf/lh.white']);
        
        newVectorslh = surfAnalysis(lh);
        
        % loading meshes
        cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/mri/'])
        try
            gunzip aparc.a2009s+aseg.mgz
        catch
        end
        try
            movefile orig orig2
        catch
        end
        try
            gunzip orig.mgz
        catch
        end
        try
        catch
            gunzip brain.mgz
        end
        
        cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii']);
        [vol,  M , mr_parms , volsz ] = fs_load_mgh(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/mri/aparc.a2009s+aseg']);
        [volb, Mb, mr_parmsb, volszb] = fs_load_mgh(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/mri/orig']);
        nii = load_nii(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T1Resliced.nii']);
        nii2 = load_nii(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T2Resliced.nii']);
        
        T1moved = alignNii(nii);
        T2moved = alignNii2(nii2);
        vole = alignVol(vol);
        voleb = alignVol(volb);
        
        newNii = make_nii(voleb, [1 1 1]);
        save_nii(newNii, 'TP1origOut.nii');
        newNii = make_nii(T2moved, [1 1 1]);
        save_nii(newNii, 'TP1T2Out.nii');
        newNii = make_nii(T1moved, [1 1 1]);
        save_nii(newNii, 'TP1T1Out.nii');
        
        
        system(['fast -t 1 -B noBiasT1.nii --nopve TP1T1Out.nii']);
        system(['fast -t 2 -B noBiasT2.nii --nopve TP1T2Out.nii']);
        try
            gunzip TP1T1Out_restore.nii.gz;
            gunzip TP1T2Out_restore.nii.gz;
        catch
        end
        cd('/home/andrei/Desktop/Slicer-4.10.2-linux-amd64');
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume /media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T1Out_restore.nii --movingVolume /media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T2Out_restore.nii --outputVolume /media/sf_VMShared/SeanControls2/ADNI/' subject '/nii/TP1T2toT1Reg.nii --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline --samplingPercentage 0.02']);
        cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/nii']);
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
        
        
        mapIntensities = weightedIntensity(lh.vertices, newVectorslh, xw, T1T2);
        mapIntensities = sqrt(mapIntensities);
        nullVals = find(mapIntensities == 0);
        mapIntensities2 = mapIntensities;
        
        mapIntensities2(nullVals) = 0;
        figure
        histogram(mapIntensities2, 500);
        
        figure;
        scatter3(lh.vertices(:,1),lh.vertices(:,2),lh.vertices(:,3),[],mapIntensities2);
        axis equal tight;
        colormap(hot);
        colorbar;
        caxis([0.3,1.2])
        hold on;
        
        cd(['/media/sf_VMShared/SeanControls2/ADNI/' subject])
        save('TP1mapVals.mat', 'mapIntensities');
        save('TP1transformVals.mat', 'M');
        TP1reformater(subject);
        
    catch
        disp('Subject failed');
    end
    disp('done');
end
