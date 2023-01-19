function [] = myelinationMastersqrt(subjectFolder)
direr = dir(subjectFolder);
for folderNum = 3:length(direr)
    try
        tic
        suber = direr(folderNum);
        subject = suber.name;
        disp(['Subject is ' subject]);
        [TP1ratio,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/TP1fs/mri/orig/TP1ratioVolume.mgh']);
        [TP2ratio,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/TP2fs/mri/orig/transformedTP2ratioVolume.mgh']);
        nanSetter = find(TP1ratio == 0);
        TP1ratio(nanSetter) = NaN;
        nanSetter = find(TP2ratio == 0);
        TP2ratio(nanSetter) = NaN;
        TP1ratio = sqrt(TP1ratio);
        TP2ratio = sqrt(TP2ratio);
        changeRatio = (TP2ratio - TP1ratio)./TP1ratio;
        
        disp('Processing surfaces');
        lh = fs_read_surf([subjectFolder '/' subject '/TP1fs/surf/lh.white']);
        rh = fs_read_surf([subjectFolder '/' subject '/TP1fs/surf/rh.white']);
        newVectorslh = surfAnalysis(lh);            %create vectors for each face and does a bunch of averaging
        newVectorsrh = surfAnalysis(rh);
        changeRatio2 = alignNewVolFinal(changeRatio);
        xw = find(~isnan(changeRatio2));
        
        disp('Creating map');
        TP1mapIntensitieslh = weightedIntensity(lh.vertices, newVectorslh, xw, changeRatio2); %takes vertices, vectors, GM voxels, and T1/T2 matrix
        TP1mapIntensitiesrh = weightedIntensity(rh.vertices, newVectorsrh, xw, changeRatio2);
        
        disp('Outputting to ico7 TP1');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['TP1rhmapVals.mat'], 'TP1mapIntensitiesrh');
        cd([subjectFolder '/' subject])
        save(['TP1lhmapVals.mat'], 'TP1mapIntensitieslh');
    catch
        disp('Subject failed');
    end
    toc
    disp('done');
end
end
