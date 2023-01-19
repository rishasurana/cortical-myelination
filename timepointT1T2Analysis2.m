function [] = timepointT1T2Analysis2(subjectFolder, subject, slicerDir4102, timepoint, scriptLocation, timepointSecond, TP1, samplingP)
        
        gunzip([subjectFolder '/' subject '/' timepoint 'fs/mri/brainmask.mgz']);
        gunzip([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/001.mgz']);
        gunzip([subjectFolder '/' subject '/' timepoint 'fs/mri/aparc.a2009s+aseg.mgz']);
        
        system(['sh ' scriptLocation '/fasterNoBias5.sh ' subjectFolder '/' subject ' ' timepoint]);
        
        [BrainMask,  M1, ~, ~] = fs_load_mgh([subjectFolder '/' subject '/' timepoint ... 
            'fs/mri/brainmask']);
        brainheader = fs_read_header([subjectFolder '/' subject '/' timepoint 'fs/mri/brainmask']);
        cd([slicerDir4102]);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/ResampleScalarVolume -s 1,1,1 ' subjectFolder ...
            '/' subject '/' timepoint 'fs/mri/orig/m001.nii ' subjectFolder '/' subject ... 
            '/' timepoint 'fs/mri/orig/SPM001resliced.mgz']);
        %system(['./Slicer --launch lib/Slicer-4.10/cli-modules/ResampleScalarVolume -s 1,1,1 ' subjectFolder ...
        %    '/' subject '/' timepoint 'fs/mri/orig/001.mgz ' subjectFolder '/' subject ... 
        %    '/' timepoint 'fs/mri/orig/001resliced.mgz']);
        gunzip([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPM001resliced.mgz']);
        
        [BrainT1,  M2, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPM001resliced']);
        M2(1,4) = M1(1,4);
        M2(2,4) = 256 + M1(2,4);
        M2(3,4) = M1(3,4);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %BrainT1(find(BrainT1 < 1)) = 0;
        %BrainT1(find(BrainT1 > 1)) = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        BrainT1Nikhil = MatchVolume2Dim(BrainT1, [256 256 256]);
        save_mgh(BrainT1Nikhil, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMT1Padded.mgh'], M2);
        [BrainT1Aligned,  M3, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/'  ... 
            timepoint 'fs/mri/orig/SPMT1Padded.mgh']);
        brainmask = logical(BrainMask);
        NoBrain = brainmask.*alignNewVol(BrainT1Aligned);
        save_mgh(NoBrain, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMT1NoBrain.mgh'], M1);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
            '/' timepoint 'fs/mri/' 'brain.mgz --movingVolume /usr/local/freesurfer/subjects/fsaverage/mri/brain.mgz --outputVolume ' subjectFolder '/' subject ...
            '/' timepoint 'fs/mri/orig/'  'SPMTransformedNoBrain.mgh --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline ' ...
            '--samplingPercentage ' samplingP]);
        [BrainRegistered,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMTransformedNoBrain.mgh']);
        
        %%%%%%%%%%%%%%%%T2 Volume Time
        cd([slicerDir4102]);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/ResampleScalarVolume -s 1,1,1 ' subjectFolder '/' ... 
            subject '/' timepoint 'fs/mri/mT2.prenorm.nii ' subjectFolder '/' subject '/' timepoint ... 
            'fs/mri/orig/SPMT2Resliced.mgz']);
        gunzip([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMT2Resliced.mgz']);
        [BrainT2,  T2M2, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMT2Resliced']);
        T2M2(1,4) = M1(1,4);
        T2M2(2,4) = 256 + M1(2,4);
        T2M2(3,4) = M1(3,4);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %BrainT2(find(BrainT2 < 1)) = 0;
        %BrainT2(find(BrainT2 > 1)) = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        BrainT2 = MatchVolume2Dim(BrainT2, [256 256 256]);
        save_mgh(BrainT2, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMT2padded.mgh'], T2M2);
        [BrainT2Aligned,  M3, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMT2padded.mgh']);
        NoBrainT2 = brainmask.*(BrainT2Aligned);
        
        save_mgh(NoBrainT2, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMNoBrainT2.mgh'], M1);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
            '/' timepoint 'fs/mri/' 'brain.mgz --movingVolume /usr/local/freesurfer/subjects/fsaverage/mri/brain.mgz --outputVolume ' subjectFolder '/' subject ...
            '/' timepoint 'fs/mri/orig/'  'SPMTransformedNoBrainT2.mgh --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline ' ...
            '--samplingPercentage ' samplingP]);
        [BrainRegisteredT2,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPMTransformedNoBrainT2.mgh']);
        
        %%%%%%%%%% Ratio Volumes Creating
        [aparc,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/aparc.a2009s+aseg']);
        notGray = find(aparc < 11000);
        aparc(notGray) = 0;
        ratioVolume = BrainRegistered./BrainRegisteredT2;
        b = find(ratioVolume == inf);
        ratioVolume2 = ratioVolume;
        ratioVolume2(b) = 0;
        b = find(ratioVolume2 > 10);
        ratioVolume2(b) = 10;
        b = isnan(ratioVolume2);
        ratioVolume2(b) = 0;
        ratioVolume2 = ratioVolume2.*logical(aparc);
        save_mgh(ratioVolume2, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPM' timepoint 'ratioVolume.mgh'], M1);
%         if timepointSecond == timepoint
%             system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
%                 '/' TP1 'fs/mri/' 'orig/SPM' TP1 'ratioVolume.mgh --movingVolume ' subjectFolder '/' subject ...
%                 '/' timepoint 'fs/mri/orig/' 'SPM' timepoint 'ratioVolume.mgh --outputVolume ' subjectFolder '/' subject ...
%                 '/' timepoint 'fs/mri/orig/'  'SPMtransformed' timepoint 'ratioVolume.mgh --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline ' ...
%                 '--samplingPercentage 0.3']);
%             ratioVolume2after = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/'  'SPMtransformed' timepoint 'ratioVolume.mgh'])
%             TPDiff = nanmean(ratioVolume2, 'all')/nanmean(ratioVolume2after, 'all');
%             ratioVolume2 = ratioVolume2.*TPDiff;
%             save_mgh(ratioVolume2, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPM' timepoint 'ratioVolumetester.mgh'], M1);
%         end
end