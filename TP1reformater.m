function TP1reformater(subjectFolder, subject, hemisphere, scriptLocation, timepoint, TP1, TP2)

intensities = load(['SPM' timepoint hemisphere 'mapVals.mat']);
%%%loads values and determines which hemisphere
if length(timepoint) < 4
    if hemisphere == 'rh'
        %if timepoint == 'TP1'
        %     if timepoint == 'change'
        %         newArray = reshape(intensities.changemapIntensitiesrh, [length(intensities.changemapIntensitiesrh),1]);
        %     end
        if timepoint == TP1
            newArray = reshape(intensities.TP1mapIntensitiesrh, [length(intensities.TP1mapIntensitiesrh),1]);
        end
        if timepoint == TP2
            newArray = reshape(intensities.TP2mapIntensitiesrh, [length(intensities.TP2mapIntensitiesrh),1]);
        end
        disp('TP1rh');
        %end
        %if timepoint == 'TP2'
        %    newArray = reshape(intensities.TP2mapIntensitiesrh, [length(intensities.TP2mapIntensitiesrh),1]);
        %    disp('TP2rh');
        %end
    end
    
    if hemisphere == 'lh'
        %if timepoint == 'TP1'
        %     if timepoint == 'change'
        %         newArray = reshape(intensities.changemapIntensitieslh, [length(intensities.changemapIntensitieslh),1]);
        %     end
        if timepoint == TP1
            newArray = reshape(intensities.TP1mapIntensitieslh, [length(intensities.TP1mapIntensitieslh),1]);
        end
        if timepoint == TP2
            newArray = reshape(intensities.TP2mapIntensitieslh, [length(intensities.TP2mapIntensitieslh),1]);
        end
        %end
        %if timepoint == 'TP2'
        %    newArray = reshape(intensities.TP2mapIntensitieslh, [length(intensities.TP2mapIntensitieslh),1]);
        %    disp('TP2lh');
        %end
    end
end

if length(timepoint) > 4
    if hemisphere == 'lh'
        newArray = reshape(intensities.changemapIntensitieslh, [length(intensities.changemapIntensitieslh),1]);
        disp('changelh');
    end
    if hemisphere == 'rh'
        newArray = reshape(intensities.changemapIntensitiesrh, [length(intensities.changemapIntensitiesrh),1]);
        disp('changerh');
    end
end

save_mgh(newArray, ['SPM' timepoint hemisphere 'resultMGH.mgh'], eye(4));

cd('/usr/local/freesurfer/bin');
%maps to ico7
system(['sh ' scriptLocation '/reformatter.sh ' subjectFolder ' ' subject ' ' hemisphere ' ' timepoint ' ' TP1]);

end
