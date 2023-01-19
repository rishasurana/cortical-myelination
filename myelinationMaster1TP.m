function [] = myelinationMaster1TP(subjectFolder, slicerDir4102, scriptLocation, TP1, TP2)
%subjectFolder is the folder contains the folders of every subject in the
%form subjectFolder/***_S_***/Modality(T1 or T2)/Timepoint(TP1 or
%TP2)/*.dcms or subjectFolder/***_S_***/TP1fs for the TP1 freesurfer. The
%subjectFolder should have 3 folders in the beginning: TP1fs, T1, and
%T2.
%SlicerDirectory is the location of the Slicer.exe process on the computing
%computer. Scriptlocation is the location of the helper bash scripts Sean
%created which include reformatter.sh, fasterNoBias5.sh
%TP1 and TP2 should be 'TP1' and 'TP2' UNLESS you are dealing with a
%subject with more than 2 timepoints. Then you can choose whatever you want
%as TP1 and TP2. These inputs assume you have used a T2Pial enhanced recon,
%as shown in Seanfsexec2.sh
slicerDir4102 = '/home/irimia/Desktop/Slicer-4.10.2-linux-amd64';
scriptLocation = '/media/sf_VMShared';
TP1 = 'TP1'; TP2 = 'TP2';

numberHolder = 0;
addpath('/media/sf_VMShared/MyelinationCode');
addpath('/media/sf_VMShared/spm12');
%subjectFolder = '/media/sf_VMShared/MyelinAllSubjects/ADSubsTSE';
subjectFolder = '/media/sf_VMShared/MyelinAllSubjects/ControlsHCP';
direr = dir(subjectFolder);

for z = 3:length(direr)
    %In order to run SPM bias correction on the volumes they must first be
    %unzipped and converted to .nii format, this for loop does that with my
    %helper bash script. 
    try
    suber = direr(z).name;
    system(['sh ' scriptLocation '/fasterNoBias5.sh ' subjectFolder '/' suber ' ' TP1]);
    %system(['sh ' scriptLocation '/fasterNoBias5.sh ' subjectFolder '/' suber ' ' TP2]);
    catch
    end
end
%Shania Code 2
disp('SPM STUFF');
%This whole block is the SPM stuff. To make this work properly the user
%must change the SPM12segmentators_job.m file to reference the right
%directory. I have set it up so that you should only have to change the
%first line in that file. 
% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/media/sf_VMShared/SPM12segmentators_job.m'};   %%%CHANGED FOR COMPILATION
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
try
spm_jobman('run', jobs, inputs{:});
catch
end

tic % for two subjects
for folderNum = 3:length(direr)
    try
        suber = direr(folderNum);
        subject = suber.name;
            
        disp(['Subject is ' subject]);
        %TP1 Start
        timepointT1Analysis(subjectFolder, subject, slicerDir4102, scriptLocation, TP1)
        
        %%%%%%% Register timepoints
        [TP1ratio,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP1 'fs/mri/orig/SPM' TP1 'ratioVolume.mgh']);
        %[TP2ratio,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP2 'fs/mri/orig/SPM' TP2 'to' TP1 'ratioVolume.mgh']);
        %[TP2before,  M4, ~ , ~ ] = fs_load_mgh([subjectFolder '/' subject '/' TP2 'fs/mri/orig/SPM' TP2 'ratioVolume.mgh']);
        
        %nanSetter = find(TP2before == 0);
        %TP2before(nanSetter) = NaN;
        nanSetter = find(TP1ratio == 0);
        TP1ratio(nanSetter) = NaN;
        
        TP1ratio = sqrt(TP1ratio);
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
            finalarrlh(2, a) = mindist;     %distance to pial point
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
        xw = find(~isnan(TP1ratio));
        
        disp('Creating map');
        TP1mapIntensitieslh = weightedIntensity(lh.vertices, finalarrlh, xw, TP1ratio, lhpial); %takes vertices, vectors, GM voxels, and T1/T2 matrix
        TP1mapIntensitiesrh = weightedIntensity(rh.vertices, finalarrrh, xw, TP1ratio, rhpial);
        
        disp('Outputting to ico7 TP1');
        cd([subjectFolder '/' subject]) %maps to ICO7 from subject space
        save(['SPM' TP1 'rhmapVals.mat'], ['TP1mapIntensitiesrh']);
        TP1reformater(subjectFolder, subject, 'rh', scriptLocation, TP1, TP1, TP2);
        cd([subjectFolder '/' subject])
        save(['SPM' TP1 'lhmapVals.mat'], ['TP1mapIntensitieslh']);
        TP1reformater(subjectFolder, subject, 'lh', scriptLocation, TP1, TP1, TP2);
        
    catch
        disp('Subject failed');
        numberHolder = numberHolder + 1;
        failed{numberHolder} = subject;
    end
    disp('done');
end

toc % for two subjects

end