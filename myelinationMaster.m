function [] = myelinationMaster(subjectFolder, slicerDir4102)
% addpath(genpath('/media/sf_VMShared/MyelinationCode/MyelinationToolbox/'));
% addpath(genpath('/media/sf_VMShared/MyelinationCode/'));
direr = dir(subjectFolder);
for folderNum = 3:length(direr)
    try
        suber = direr(folderNum);       
        subject = suber.name;
        disp(['Subject is ' subject]);
        prepareDicomsMyelinationTP1(subjectFolder, subject, 'TP1');      %takes dicoms from folder and returns the .nii
        prepareDicomsMyelinationTP1(subjectFolder, subject, 'TP2');
        
        disp('Dicoms done. Unzipping freesurfers');
        % loading meshes
        cd([subjectFolder '/' subject '/freesurfer/' 'TP2' '/fs/' 'mri/'])
        try                             %unzip necessary files
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

        disp('Loading niis and volumes');
        
        cd([subjectFolder '/' subject '/nii']);
                            %assign necessary volumes
        [vol,  ~, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/freesurfer/TP2'  '/fs/'  'mri/aparc.a2009s+aseg']);
        TP1nii = load_nii([subjectFolder '/' subject '/nii/' 'TP1T1Resliced.nii']);
        TP1nii2 = load_nii([subjectFolder '/' subject '/nii/' 'TP1T2Resliced.nii']);
        
        TP2nii = load_nii([subjectFolder '/' subject '/nii/' 'TP2T1Resliced.nii']);
        TP2nii2 = load_nii([subjectFolder '/' subject '/nii/' 'TP2T2Resliced.nii']);
        
        %align volumes --- subject to change depending on the acquisition
        %details
        disp('Aligning volumes');
        TP1T1moved = alignNii(TP1nii);
        TP1T2moved = alignNii(TP1nii2);
        
        TP2T1moved = alignNii(TP2nii);
        TP2T2moved = alignNii(TP2nii2);
        vole = alignVol(vol);
        
        %saves output for later registration or visualization
        disp('Saving outputs');
        newNii = make_nii(TP1T2moved, [1 1 1]);
        save_nii(newNii, ['TP1T2Out.nii']);
        newNii = make_nii(TP1T1moved, [1 1 1]);
        save_nii(newNii, ['TP1T1Out.nii']);
        
        newNii = make_nii(TP2T2moved, [1 1 1]);
        save_nii(newNii, ['TP2T2Out.nii']);
        newNii = make_nii(TP2T1moved, [1 1 1]);
        save_nii(newNii, ['TP2T1Out.nii']);
        
        %manually creating FSFAST variables to enable bias field correction
        disp('Setting variables for FAST');
        setenv('FSFAST_HOME',  '/usr/local/freesurfer/fsfast');
        setenv('FREESURFER_HOME',  '/usr/local/freesurfer');
        setenv('FSF_OUTPUT_FORMAT',  'nii.gz');
        setenv('SUBJECTS_DIR',  '/usr/local/freesurfer/subjects');
        setenv('MNI_DIR',  '/usr/local/freesurfer/mni');
        setenv('FSL_DIR',  '/usr/share/fsl/5.0');
        setenv('LD_LIBRARY_PATH', '/usr/lib/fsl/5.0');
        cd('/usr/lib/fsl/5.0');
        %script for bias field correction, exports subject directory, could
        %only get this to work through a shell script
        disp(['sh /home/ubuntu/fasterNoBias.sh ' subjectFolder '/' subject '/nii']);
        system(['sh /home/ubuntu/fasterNoBias.sh ' subjectFolder '/' subject '/nii']);
        cd([subjectFolder '/' subject '/nii']);

        disp('unzip restored');
        try
            gunzip(['TP1' 'T1Out_restore.nii.gz']);
            gunzip(['TP1' 'T2Out_restore.nii.gz']);       %unzipping outputs
            gunzip(['TP2' 'T1Out_restore.nii.gz']);
            gunzip(['TP2' 'T2Out_restore.nii.gz']);       %unzipping outputs
        catch
        end
        disp('Slicer alignments');          %calling slicer's registration from commandline
        cd([slicerDir4102]);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject '/nii/' 'TP2T1Out_restore.nii --movingVolume ' subjectFolder '/' subject '/nii/' 'TP2T2Out_restore.nii --outputVolume ' subjectFolder '/' subject '/nii/'  'TP2T2toT1Reg.nii --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline --samplingPercentage 0.02']);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject '/nii/' 'TP2T1Out_restore.nii --movingVolume ' subjectFolder '/' subject '/nii/' 'TP1T2Out_restore.nii --outputVolume ' subjectFolder '/' subject '/nii/'  'TP1T2toT1Reg.nii --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline --samplingPercentage 0.02']);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject '/nii/' 'TP2T1Out_restore.nii --movingVolume ' subjectFolder '/' subject '/nii/' 'TP1T1Out_restore.nii --outputVolume ' subjectFolder '/' subject '/nii/'  'TP1T1toT1Reg.nii --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline --samplingPercentage 0.02']);
        
        disp('Loading final niis');
        cd([subjectFolder '/' subject '/nii']);             %loading registered T2
        TP2T2movednii = load_nii([subjectFolder '/' subject '/nii/'  'TP2T2toT1Reg.nii']);
        TP2T2moved = TP2T2movednii.img;
        TP1T2movednii = load_nii([subjectFolder '/' subject '/nii/' 'TP1T2toT1Reg.nii']);
        TP1T2moved = TP1T2movednii.img;
        TP1T1movednii = load_nii([subjectFolder '/' subject '/nii/' 'TP1T1toT1Reg.nii']);
        TP1T1moved = TP1T1movednii.img;
        lenghtera = length(TP2T2moved);
        
        if (lenghtera > 256)            %ensuring T2 is the same length as T1
            TP2T2moved = TP2T2moved(1:end-1,1:end-1,1:end-1);
        end
        
        lenghtera = length(TP2T1moved);
        if (lenghtera > 256)
            TP2T1moved = TP2T1moved(1:end-1,1:end-1,1:end-1);
        end
        
        lenghtera = length(TP1T1moved);
        if (lenghtera > 256)            %ensuring T2 is the same length as T1
            TP1T1moved = TP1T1moved(1:end-1,1:end-1,1:end-1);
        end
        
        lenghtera = length(TP1T2moved);
        if (lenghtera > 256)
            TP1T2moved = TP1T2moved(1:end-1,1:end-1,1:end-1);
        end
        
        disp('Finding gray matter t1/t2');
        GMlb = vole;
        GMlb(GMlb <  11000) = 0;
        GMlb(GMlb >= 11000) = 1;
        GMlb = logical(GMlb);
        xw = find(GMlb > 0);            %creating gray matter matrix also does T1/T2
        TP1GMT1 = TP1T1moved.*GMlb;
        TP1GMT2 = TP1T2moved.*GMlb;
        TP1T1T2 = TP1GMT1./TP1GMT2;
        f = find(isnan(TP1T1T2)); TP1T1T2(f) = 0;
        f = find(isinf(TP1T1T2)); TP1T1T2(f) = 0;
        
        TP2GMT1 = TP2T1moved.*GMlb;
        TP2GMT2 = TP2T2moved.*GMlb;
        TP2T1T2 = TP2GMT1./TP2GMT2;
        f = find(isnan(TP2T1T2)); TP2T1T2(f) = 0;
        f = find(isinf(TP2T1T2)); TP2T1T2(f) = 0;
        
        change = (TP2T1T2 - TP1T1T2)./(TP1T1T2); 
        
        disp('Processing surfaces');
        lh = fs_read_surf([subjectFolder '/' subject '/freesurfer/TP2/fs/surf/lh.white']);
        rh = fs_read_surf([subjectFolder '/' subject '/freesurfer/TP2/fs/surf/rh.white']);
        newVectorslh = surfAnalysis(lh);            %create vectors for each face and does a bunch of averaging
        newVectorsrh = surfAnalysis(rh);
        
        disp('Creating map');
        TP1mapIntensitieslh = weightedIntensity(lh.vertices, newVectorslh, xw, TP1T1T2); %takes vertices, vectors, GM voxels, and T1/T2 matrix
       
        TP1mapIntensitiesrh = weightedIntensity(rh.vertices, newVectorsrh, xw, TP1T1T2);
        
        TP2mapIntensitieslh = weightedIntensity(lh.vertices, newVectorslh, xw, TP2T1T2); %takes vertices, vectors, GM voxels, and T1/T2 matrix
       
        TP2mapIntensitiesrh = weightedIntensity(rh.vertices, newVectorsrh, xw, TP2T1T2);
        
        changemapIntensitieslh = weightedIntensity(lh.vertices, newVectorslh, xw, change); %takes vertices, vectors, GM voxels, and T1/T2 matrix

        changemapIntensitiesrh = weightedIntensity(rh.vertices, newVectorsrh, xw, change);

        disp('Outputting to ico7 TP1');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['TP1rhmapVals.mat'], 'TP1mapIntensitiesrh');
        TP1reformater(subjectFolder, subject, 'TP1', 'rh');
        cd([subjectFolder '/' subject])
        save(['TP1lhmapVals.mat'], 'TP1mapIntensitieslh');
        TP1reformater(subjectFolder, subject, 'TP1', 'lh');
        
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        disp('TP2');
        save(['TP2rhmapVals.mat'], 'TP2mapIntensitiesrh');
        TP1reformater(subjectFolder, subject, 'TP2', 'rh');
        cd([subjectFolder '/' subject])
        save(['TP2lhmapVals.mat'], 'TP2mapIntensitieslh');
        TP1reformater(subjectFolder, subject, 'TP2', 'lh');
        
        disp('change');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['changerhmapVals.mat'], 'changemapIntensitiesrh');
        TP1reformater(subjectFolder, subject, 'change', 'rh');
        cd([subjectFolder '/' subject])
        save(['changelhmapVals.mat'], 'changemapIntensitieslh');
        TP1reformater(subjectFolder, subject, 'change', 'lh');
        
        try
            disp('Deleting trash');
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Out_mixeltype.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Out_pve_0.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Out_pve_1.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Out_pve_2.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Out_pveseg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Out_seg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T1Resliced.nii']);
        
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Out_mixeltype.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Out_pve_0.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Out_pve_1.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Out_pve_2.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Out_pveseg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Out_seg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP1T2Resliced.nii']);            
            
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Out_mixeltype.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Out_pve_0.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Out_pve_1.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Out_pve_2.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Out_pveseg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Out_seg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T1Resliced.nii']);
        
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Out_mixeltype.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Out_pve_0.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Out_pve_1.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Out_pve_2.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Out_pveseg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Out_seg.nii.gz']);
            system(['rm ' subjectFolder '/' subject '/nii/TP2T2Resliced.nii']); 
            
        catch
        end
    catch
        disp('Subject failed');
    end
    disp('done');
end
end