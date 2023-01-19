function [] = timepointT1Analysis(subjectFolder, subject, slicerDir4102, scriptLocation, TP1)
        b = 1;
        
        gunzip([subjectFolder '/' subject '/' TP1 'fs/mri/brainmask.mgz']);
        gunzip([subjectFolder '/' subject '/' TP1 'fs/mri/orig/001.mgz']);
        gunzip([subjectFolder '/' subject '/' TP1 'fs/mri/aparc.a2009s+aseg.mgz']);

        [BrainMask,  M1, ~, ~] = fs_load_mgh([subjectFolder '/' subject '/' TP1 ... 
            'fs/mri/brainmask']);
        holder{b} = M1;
        b = b + 1;
        brainheader = fs_read_header([subjectFolder '/' subject '/' TP1 'fs/mri/brainmask']);
        cd([slicerDir4102]);
        % reslice_nii to account for non-orthogonal transforms
        reslice_nii([subjectFolder '/' subject '/' TP1 'fs/mri/orig/m001.nii'],[subjectFolder '/' subject '/' ...
            TP1 'fs/mri/orig/r001.nii']);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/ResampleScalarVolume -s 1,1,1 ' subjectFolder ...
            '/' subject '/' TP1 'fs/mri/orig/r001.nii ' subjectFolder '/' subject ... 
            '/' TP1 'fs/mri/orig/SPM001resliced.mgz']);
        %system(['./Slicer --launch lib/Slicer-4.10/cli-modules/ResampleScalarVolume -s 1,1,1 ' subjectFolder ...
        %    '/' subject '/' timepoint 'fs/mri/orig/001.mgz ' subjectFolder '/' subject ... 
        %    '/' timepoint 'fs/mri/orig/001resliced.mgz']);
        gunzip([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPM001resliced.mgz']);
        
        [BrainT1,  M2, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPM001resliced']);
        holder{b} = M2;
        b = b + 1;
        M2(1,4) = M1(1,4);
        M2(2,4) = 256 + M1(2,4);
        M2(3,4) = M1(3,4);
        if M2(1,3) == -1 
           M2(1,3) = 1; 
           M2(1,4) = -1* M2(1,4);
        end
        mNew = M1;
        if mNew(1,3) == -1
           mNew(1,3) = 1; 
           mNew(1,4) = -1* M2(1,4);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %BrainT1(find(BrainT1 < 1)) = 0;
        %BrainT1(find(BrainT1 > 1)) = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        BrainT1Nikhil = MatchVolume2Dim(BrainT1, [256 256 256]);
                holder{b} = M2;
        b = b + 1;
        save_mgh(BrainT1Nikhil, [subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMT1Padded.mgh'], M2);
        [BrainT1Aligned,  M3, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/'  ... 
            TP1 'fs/mri/orig/SPMT1Padded.mgh']);
                holder{b} = M3;
        b = b + 1;
        brainmask = logical(BrainMask);
        NoBrain = brainmask.*(controlT2Align(alignNewVolRAS(BrainT1Aligned)));

                holder{b} = M1;
        b = b + 1;
        save_mgh(NoBrain, [subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMT1NoBrain.mgh'], mNew);
        %system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
        %    '/' TP1 'fs/mri/' 'brain.mgz --movingVolume ' subjectFolder '/' subject ...
        %    '/' TP1 'fs/mri/orig/' 'SPMT1NoBrain.mgh --outputVolume ' subjectFolder '/' subject ...
        %    '/' TP1 'fs/mri/orig/'  'SPMTransformedNoBrain.mgh --transformType Rigid ' ...
        %    '--samplingPercentage 0.5']);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
            '/' TP1 'fs/mri/' 'brain.mgz --movingVolume ' subjectFolder '/' subject ...
            '/' TP1 'fs/mri/orig/' 'SPMT1NoBrain.mgh --outputVolume ' subjectFolder '/' subject ...
            '/' TP1 'fs/mri/orig/'  'SPMTransformedNoBrain.mgh --transformType Rigid ' ...
            '--samplingPercentage 0.04']);
        [BrainRegistered,  M4orig, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMTransformedNoBrain.mgh']);
                
        holder{b} = M4orig;
        b = b + 1;
        %%%%%%%%%%%%%%%%T2 Volume Time
        cd([slicerDir4102]);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/ResampleScalarVolume -s 1,1,1 ' subjectFolder '/' ... 
            subject '/' TP1 'fs/mri/mT2.prenorm.nii ' subjectFolder '/' subject '/' TP1 ... 
            'fs/mri/orig/SPMT2Resliced.mgz']);
        gunzip([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMT2Resliced.mgz']);
        [BrainT2,  T2M2, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMT2Resliced']);
                holder{b} = T2M2;
        b = b + 1;
        T2M2(1,4) = M1(1,4);
        T2M2(2,4) = 256 + M1(2,4);
        T2M2(3,4) = M1(3,4);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %BrainT2(find(BrainT2 < 1)) = 0;
        %BrainT2(find(BrainT2 > 1)) = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        BrainT2 = MatchVolume2Dim(BrainT2, [256 256 256]);
                holder{b} = T2M2;
        b = b + 1;
        save_mgh(BrainT2, [subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMT2padded.mgh'], T2M2);
        [BrainT2Aligned,  M3, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMT2padded.mgh']);
                holder{b} = M3;
        b = b + 1;
       % NoBrainT2 = brainmask.*controlT2Align(controlT2Align(BrainT2Aligned));
                NoBrainT2 = brainmask.*(BrainT2Aligned);

        %NoBrainT2 = brainmask.*(BrainT2Aligned);

                holder{b} = M1;
        b = b + 1;
        save_mgh(NoBrainT2, [subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMNoBrainT2.mgh'], M1);
        %system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
        %    '/' TP1 'fs/mri/orig/' 'SPMTransformedNoBrain.mgh --movingVolume ' subjectFolder '/' subject ...
        %    '/' TP1 'fs/mri/orig/' 'SPMNoBrainT2.mgh --outputVolume ' subjectFolder '/' subject ...
        %    '/' TP1 'fs/mri/orig/'  'SPMTransformedNoBrainT2.mgh --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline ' ...
        %    '--samplingPercentage 0.5']);
        system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
            '/' TP1 'fs/mri/orig/' 'SPMTransformedNoBrain.mgh --movingVolume ' subjectFolder '/' subject ...
            '/' TP1 'fs/mri/orig/' 'SPMNoBrainT2.mgh --outputVolume ' subjectFolder '/' subject ...
            '/' TP1 'fs/mri/orig/'  'SPMTransformedNoBrainT2.mgh --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline ' ...
            '--samplingPercentage 0.1']);
        
        [BrainRegisteredT2,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPMTransformedNoBrainT2.mgh']);
                holder{b} = M4;
        b = b + 1;
        %%%%%%%%%% Ratio Volumes Creating
        [aparc,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/aparc.a2009s+aseg']);
                holder{b} = M4;
        b = b + 1;
        notGray = find(aparc < 11000);
        aparc(notGray) = 0;
        ratioVolume = BrainRegistered./BrainRegisteredT2;
        b2 = find(ratioVolume == inf);
        ratioVolume2 = ratioVolume;
        ratioVolume2(b2) = 0;
        b2 = find(ratioVolume2 > 10);
        ratioVolume2(b2) = 10;
        b2 = isnan(ratioVolume2);
        ratioVolume2(b2) = 0;
        ratioVolume2 = ratioVolume2.*logical(aparc);
                holder{b} = M1;
        b = b + 1;
        save_mgh(ratioVolume2, [subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPM' TP1 'ratioVolume.mgh'], M1);

        save([subjectFolder '/' subject '/' TP1 'fs/mri/orig/Marrays.mat'], 'holder');

%         system(['./Slicer --launch lib/Slicer-4.10/cli-modules/BRAINSFit --fixedVolume ' subjectFolder '/' subject ...
%             '/' TP1 'fs/mri/' 'orig/SPM' TP1 'ratioVolume.mgh --movingVolume ' subjectFolder '/' subject ...
%             '/' TP2 'fs/mri/orig/' 'SPM' timepoint 'ratioVolume.mgh --outputVolume ' subjectFolder '/' subject ...
%             '/' timepoint 'fs/mri/orig/'  'SPMtransformed' timepoint 'ratioVolume.mgh --transformType Rigid,ScaleVersor3D,ScaleSkewVersor3D,Affine,BSpline ' ...
%             '--samplingPercentage 0.3']);
%      ratioVolume2after = fs_load_mgh([subjectFolder '/' subject '/' timepoint 'fs/mri/orig/'  'SPMtransformed' timepoint 'ratioVolume.mgh'])
%      TPDiff = nanmean(ratioVolume2, 'all')/nanmean(ratioVolume2after, 'all');
%      ratioVolume2 = ratioVolume2.*TPDiff;
%      save_mgh(ratioVolume2, [subjectFolder '/' subject '/' timepoint 'fs/mri/orig/SPM' timepoint 'ratioVolumetester.mgh'], M1);
end