addpath(genpath('C:\Users\P06\Desktop\BrainConnectivityMatrix\fstools'));
addpath(genpath('D:\Di\dcm2niix_11-Apr-2019_win'));
addpath(genpath('C:\Users\P06\Desktop\BrainConnectivityMatrix\Kenny'));
addpath(genpath('C:\Users\P06\Desktop\Myelination'));
addpath(genpath('C:\Users\P06\Desktop\Myelination\nonrigid_version23'));
addpath(genpath('C:\Users\P06\Desktop\AWSBOIZZZZ'));

AWSdownloadSubject('023_S_0058', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\023_S_0058\', 0);
AWSdownloadSubject('023_S_0081', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\023_S_0081\', 0);

AWSdownloadSubject('023_S_0926', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\023_S_0926\', 0);
AWSdownloadSubject('023_S_0963', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\023_S_0963\', 0);

AWSdownloadSubject('032_S_0479', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\032_S_0479\', 0);
AWSdownloadSubject('032_S_0677', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\032_S_0677\', 0);

AWSdownloadSubject('032_S_1169', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\032_S_1169\', 0);
AWSdownloadSubject('035_S_0156', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\035_S_0156\', 0);

AWSdownloadSubject('036_S_0672', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\036_S_0672\', 0);
AWSdownloadSubject('036_S_0813', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\036_S_0813\', 0);

AWSdownloadSubject('057_S_0643', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\057_S_0643\', 0);
AWSdownloadSubject('057_S_0818', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\057_S_0818\', 0);

AWSdownloadSubject('057_S_0934', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\057_S_0934\', 0);
AWSdownloadSubject('067_S_0056', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\067_S_0056\', 0);



AWSdownloadSubject('067_S_0059', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\067_S_0059\', 0);
AWSdownloadSubject('073_S_0089', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\073_S_0089\', 0);

AWSdownloadSubject('073_S_0386', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\073_S_0386\', 0);
AWSdownloadSubject('082_S_0304', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\082_S_0304\', 0);

AWSdownloadSubject('082_S_1256', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\082_S_1256\', 0);
AWSdownloadSubject('099_S_0040', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\099_S_0040\', 0);

AWSdownloadSubject('099_S_0090', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\099_S_0090\', 0);
AWSdownloadSubject('099_S_0534', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\099_S_0534\', 0);

AWSdownloadSubject('114_S_0166', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\114_S_0166\', 0);
AWSdownloadSubject('114_S_0173', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\114_S_0173\', 0);
AWSdownloadSubject('114_S_0416', 'freesurfer_output/', 'D:\SeanMyelinationControls\ADNI\114_S_0416\', 0);



prepareDicomsMyelination('C:\Users\P06\Desktop\AWSBOIZZZZ\T1\001\20150106', 'C:\Users\P06\Desktop\AWSBOIZZZZ\nii', 'T1');
prepareDicomsMyelination('C:\Users\P06\Desktop\AWSBOIZZZZ\T2\001\20150106', 'C:\Users\P06\Desktop\AWSBOIZZZZ\nii', 'T2');