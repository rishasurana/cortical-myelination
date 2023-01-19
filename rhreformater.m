function rhreformater(subject)
    load(['/media/sf_VMShared/Reconer/reconFinished/' subject '/TP2/rhmapVals.mat']);
    load(['/media/sf_VMShared/Reconer/reconFinished/' subject '/TP2/rhtransformVals.mat']);
    newArray = reshape(mapIntensities, [length(mapIntensities),1]);
    save_mgh(newArray, ['/media/sf_VMShared/Reconer/reconFinished/' subject '/TP2/rhresultMGH.mgh'], M);

    system(['sh /home/andrei/rhreformatter.sh ' subject]);
end