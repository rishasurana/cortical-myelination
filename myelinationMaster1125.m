%function [] = myelinationMasterV2(subjectFolder, slicerDir4102, scriptLocation, TP1, TP2, TPCount)
%subjectFolder is the folder contains the folders of every subject in the
%form subjectFolder/***_S_***/Modality(T1 or T2)/Timepoint(TP1 or
%TP2)/*.dcms or subjectFolder/***_S_***/TP1fs for the TP1 freesurfer. The
%subjectFolder should have 4 folders in the beginning: TP1fs TP2fs T1 and
%T2.
%SlicerDirectory is the location of the Slicer.exe process on the computing
%computer. Scriptlocation is the location of the helper bash scripts I have
%created which include reformatter.sh, fasterNoBias5.sh
%TP1 and TP2 should be 'TP1' and 'TP2' UNLESS you are dealing with a
%subject with more than 2 timepoints. Then you can choose whatever you want
%as TP1 and TP2. These inputs assume you have used a T2Pial enhanced recon,
%as shown in Seanfsexec2.sh
slicerDir4102 = '/home/wk1/Downloads/Slicer/Slicer-4.11.0-2019-11-19-linux-amd64';
scriptLocation = '/home/wk1/Documents/Myelin_Project/MyelinationCode';
TP1 = 'TP1'; TP2 = 'TP2';

numberHolder = 0;
% path to myelin code
addpath('/home/wk1/Documents/Myelin_Project/MyelinationCode');
% path to SPM12
addpath('/home/wk1/Downloads/spm12');
% path to folder of subjects we're using 
%global subjectFolder;
subjectFolder = getSubFold();
direr = dir(subjectFolder);

%Section 1: Unzipping files
disp('RUNNING PART 1');


for z = 3:length(direr)
    %In order to run SPM bias correction on the volumes they must first be
    %unzipped and converted to .nii format, this for loop does that with my
    %helper bash script. 
    %Precheck if section files have already been made (t2.prenorm.nii (backtrace once) and
    %0.001.nii)
    suber = direr(z).name;
    disp(suber);
    sec1FilesPart1 = {'001.nii'};
    
    [beginSec1Part1, limit1] = timepointsCheck(subjectFolder, suber, sec1FilesPart1, 0);
    
    % To check if t2.prenorm is there, need to backtrace once directly with
    % subjectProgressCheck
    
    sec1FilesPart2 = {'T2.prenorm.nii'};
    [beginSec1Part2, limit2] = timepointsCheck(subjectFolder, suber, sec1FilesPart1, 1);

  
    if (beginSec1Part1 && limit1 == 2 && beginSec1Part2 && limit2 == 2)
        try
        system(['sh ' scriptLocation '/fasterNoBias5.sh ' subjectFolder '/' suber ' ' TP1]);
        system(['sh ' scriptLocation '/fasterNoBias5.sh ' subjectFolder '/' suber ' ' TP2]);
        catch
        end
    end
end

%Section 2: SPM

disp('SPM STUFF');
%This whole block is the SPM stuff. To make this work properly the user
%must change the SPM12segmentators_job.m file to reference the right
%directory. I have set it up so that you should only have to change the
%first line in that file. [EDIT: NO LONGER NEED TO DO THIS, see getSubFold] 
% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {[scriptLocation '/SPM12segmentators_job.m']};   %%%CHANGED FOR COMPILATION
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
try
spm_jobman('run', jobs, inputs{:});
catch
end

disp('SECTION 3');

for folderNum = 3:length(direr)
    try
        %Section 3: Timepoint Analysis
        suber = direr(folderNum);
        subject = suber.name;
        disp(['Subject is ' subject]);
        %check if timepoint section has already been done
        sec3Files = {'SPMTransformedNoBrainT2.mgh'};
        [beginSec3, limit] = timepointsCheck(subjectFolder, subject, sec3Files, 0);
        
        
        %TP1 Start
        if (beginSec3 && limit == 2)
            timepointT1T2Analysis(subjectFolder, subject, slicerDir4102, scriptLocation, TP1, TP2);
        end
        %%%%%%% Register timepoints
        [TP1ratio,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPM' TP1 'ratioVolume.mgh']);
        [TP2ratio,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP2 'fs/mri/orig/SPM' TP2 'to' TP1 'ratioVolume.mgh']);
        %[TP2before,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP2 'fs/mri/orig/SPM' TP2 'ratioVolume.mgh']);
        
        %nanSetter = find(TP2before == 0);
        %TP2before(nanSetter) = NaN;
        nanSetter = find(TP1ratio == 0);
        TP1ratio(nanSetter) = NaN;
        nanSetter = find(TP2ratio == 0);
        TP2ratio(nanSetter) = NaN;
%         TP2diff = nanmean(TP2before, 'all')/nanmean(TP2ratio,'all');
%         TP2ratio = TP2diff.*TP2ratio;
        
        TP1ratio = sqrt(TP1ratio);
        TP2ratio = sqrt(TP2ratio);
        changeRatio = (TP2ratio - TP1ratio)./TP1ratio;
        clear nanSetter;
        
        disp('Processing surfaces');
        lh = fs_read_surf([subjectFolder '/' subject '/' TP1 'fs/surf/lh.white']);
        rh = fs_read_surf([subjectFolder '/' subject '/' TP1 'fs/surf/rh.white']);
        lhpial = fs_read_surf([subjectFolder '/' subject '/' TP1 'fs/surf/lh.pial']);
        rhpial = fs_read_surf([subjectFolder '/' subject '/' TP1 'fs/surf/rh.pial']);
        
        finalarrrh = zeros(2, length(rh.vertices));
        finalarrlh = zeros(2, length(lh.vertices));

        for a=1:length(lh.vertices)
            pointw = lh.vertices(a,:);
            d = pdist2(pointw, lhpial.vertices);
            [mindist, idx] = min(d);
            finalarrlh(1, a) = idx;         %corresponding pial point
            finalarrlh(2, a) = mindist;
        end
        
        for a=1:length(rh.vertices)
            pointw = rh.vertices(a,:);
            d = pdist2(pointw, rhpial.vertices);
            [mindist, idx] = min(d);
            finalarrrh(1, a) = idx;         %corresponding pial point
            finalarrrh(2, a) = mindist;
        end
        
%         newVectorslh = surfAnalysis(lh);            %create vectors for each face and does a bunch of averaging
%         newVectorsrh = surfAnalysis(rh);
        TP1ratio = alignNewVolFinal(TP1ratio);
        TP2ratio = alignNewVolFinal(TP2ratio);
        changeRatio2 = alignNewVolFinal(changeRatio);
        xw = find(~isnan(changeRatio2));
        
        disp('Creating map');
        changemapIntensitieslh = weightedIntensity(lh.vertices, finalarrlh, xw, changeRatio2, lhpial); %takes vertices, vectors, GM voxels, and T1/T2 matrix
        changemapIntensitiesrh = weightedIntensity(rh.vertices, finalarrrh, xw, changeRatio2, rhpial);

        TP1mapIntensitieslh = weightedIntensity(lh.vertices, finalarrlh, xw, TP1ratio, lhpial); %takes vertices, vectors, GM voxels, and T1/T2 matrix
        TP1mapIntensitiesrh = weightedIntensity(rh.vertices, finalarrrh, xw, TP1ratio, rhpial);
        
        TP2mapIntensitieslh = weightedIntensity(lh.vertices, finalarrlh, xw, TP2ratio, lhpial); %takes vertices, vectors, GM voxels, and T1/T2 matrix
        TP2mapIntensitiesrh = weightedIntensity(rh.vertices, finalarrrh, xw, TP2ratio, rhpial);
        
        disp('Outputting to ico7 change');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['SPM' 'change' 'rhmapVals.mat'], ['changemapIntensitiesrh']);
        TP1reformater(subjectFolder, subject, 'rh', scriptLocation, 'change', TP1, TP2);
        cd([subjectFolder '/' subject])
        save(['SPM' 'change' 'lhmapVals.mat'], ['changemapIntensitieslh']);
        TP1reformater(subjectFolder, subject, 'lh', scriptLocation, 'change', TP1, TP2);
        
        disp('Outputting to ico7 TP1');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['SPM' TP1 'rhmapVals.mat'], ['TP1mapIntensitiesrh']);
        TP1reformater(subjectFolder, subject, 'rh', scriptLocation, TP1, TP1, TP2);
        cd([subjectFolder '/' subject])
        save(['SPM' TP1 'lhmapVals.mat'], ['TP1mapIntensitieslh']);
        TP1reformater(subjectFolder, subject, 'lh', scriptLocation, TP1, TP1, TP2);
        
        disp('Outputting to ico7 TP2');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['SPM' TP2 'rhmapVals.mat'], ['TP2mapIntensitiesrh']);
        TP1reformater(subjectFolder, subject, 'rh', scriptLocation, TP2, TP1, TP2);
        cd([subjectFolder '/' subject])
        save(['SPM' TP2 'lhmapVals.mat'], ['TP2mapIntensitieslh']);
        TP1reformater(subjectFolder, subject, 'lh', scriptLocation, TP2, TP1, TP2);
    catch
        disp('Subject failed');
        numberHolder = numberHolder + 1;
        failed{numberHolder} = subject;
    end
    disp('done');
end