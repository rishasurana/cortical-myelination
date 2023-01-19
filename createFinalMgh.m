addpath(genpath('/media/sf_VMShared/MyelinationCode'));
subjectFiles = dir('/media/sf_VMShared/myeFinal/');
subject = subjectFiles(3);
subject = subject.name;
timepoint = 'change';
[vol, M, mr_parms, volsz] = load_mgh(['/media/sf_VMShared/myeFinal/' subject '/' timepoint hemisphere '_ico7.mgh']);
B = find(vol == 0);
vol(B) = NaN;
newVol = round(vol, 2);
A = mode(newVol);
newVol = vol -A;
B = find(isnan(newVol));
newVol(B) = 0;
S = std(newVol);
newVol = newVol./S;
counter = 1;


for subjectFilers = 4:length(subjectFiles)-3
    counter = counter + 1;
    subject = subjectFiles(subjectFilers);
    subject = subject.name;
    disp(counter);
    [vol2, M, mr_parms, volsz] = load_mgh(['/media/sf_VMShared/myeFinal/' subject '/' timepoint hemisphere '_ico7.mgh']);
    B = find(vol2 == 0);
    vol2(B) = NaN;
    newVol2 = round(vol2, 2);
    A = mode(newVol2);
    newVol2 = vol2 -A;
    B = find(isnan(newVol2));
    newVol2(B) = 0;
    S = std(newVol2);
    newVol2 = newVol2./S;

    try
        newVol = newVol2+newVol;
    catch
                disp(['Could not read ' subject ' result file']);
    end
    cd ..;
end
newVol = newVol/counter;
R = find(newVol ==0);
newVol(R) = -3;

save_mgh(newVol, ['/media/sf_VMShared/myeFinal/' timepoint hemisphere 'finalResults.mgh'], M);