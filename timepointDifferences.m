addpath(genpath('D:\VMShared\1-28-2020-Recons-VanandSean'));
hemisphere = 'lh';
subjectFiles = dir('D:\VMShared\1-28-2020-Recons-VanandSean');

for subjectFilers = 3:length(subjectFiles)
    try
    subject = subjectFiles(subjectFilers);
    subject = subject.name;
    
    date1 = dicominfo(['D:\VMShared\1-28-2020-Recons-VanandSean' '/' subject '/T1/TP1/001.dcm']);
    date2 = dicominfo(['D:\VMShared\1-28-2020-Recons-VanandSean' '/' subject '/T1/TP2/001.dcm']);
    date1 = date1.AcquisitionDate;
    date2 = date2.AcquisitionDate;
    date11 = datenum(date1, 'yyyymmdd');
    date22 = datenum(date2, 'yyyymmdd');
    differenceInTime = (date22-date11)/365;
    
    [vol2, M, mr_parms, volsz] = load_mgh(['/media/sf_VMShared/myeFinal/' subject '/TP2' hemisphere '_ico7.mgh']);
    [vol1, M, mr_parms, volsz] = load_mgh(['/media/sf_VMShared/myeFinal/' subject '/TP1' hemisphere '_ico7.mgh']);
    B = find(vol2 == 0);
    vol2(B) = NaN;
    B = find(vol1 == 0);
    vol1(B) = NaN;
    C = find(~isnan(vol1) & ~isnan(vol2));
    D = find(isnan(vol1) | isnan(vol2));
    newVol = zeros(length(vol1),1);
    newVol(C) = ((vol2(C) - vol1(C))./vol1(C))./differenceInTime;
    newVol(D) = NaN;
    save_mgh(newVol, ['/media/sf_VMShared/myeFinal/' subject '/' hemisphere 'changeResults.mgh'], M);
    
    
    disp('TP1 = ');
    disp(nanmean(vol1));
    disp('TP2 = ');
    disp(nanmean(vol2));
    disp(nanmean(newVol));
    meanChange(subjectFilers) = nanmean(newVol);
    catch
        disp(['could not compute ' subject])
    end
    bb = find(meanChange > 2);
    meanChange(bb) = NaN;
    disp(nanmean(meanChange));
end
