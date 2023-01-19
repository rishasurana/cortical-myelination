export SUBJECTS_DIR=$1
cd $1
mri_surf2surf --srcsubject $2/$5fs --trgsubject ico --trgicoorder 7 --hemi $3 --srcsurfval $2/SPM$4$3resultMGH.mgh --trgsurfval $2/SPM$4$3new_ico7.mgh
exit


