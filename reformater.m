function reformater(subject)
    load('mapVals.mat');
    load('transformVals.mat');
    newArray = reshape(mapIntensities, [length(mapIntensities),1]);
    save_mgh(newArray, 'resultMGH.mgh', M);

    %system(['mri_surf2vol --o myMap.mgz --ribbon /home/andrei/Desktop/SeanMyelinationControls/ADNI/' subject '/freesurfer/TP2/fs/mri/ribbon.mgz --so /home/andrei/Desktop/SeanMyelinationControls/ADNI/' subject '/freesurfer/TP2/fs/surf/lh.white resultMGH.mgh']) 
    
    system(['sh /home/andrei/reformatter.sh ' subject]);
    %[status, msg]=system(['export SUBJECTS_DIR=/home/andrei/Desktop/SeanMyelinationControls/ADNI/' subject '/freesurfer/TP2']);
    %system(['mri_surf2surf --srcsubject fs --trgsubject ico --trgicoorder 7 --hemi lh --srcsurfval myMap.mgz --trgsurfval lh_ico7.mgh'])


end