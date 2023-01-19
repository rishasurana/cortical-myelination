% read surface data
function [areaParc,lh_aparc_stats,rh_aparc_stats] = getStats (subjdir,subj,FREESURFER_HOME)

outfile         = [subj '-stats.mat'];
surfname        = 'white';
nverts_only     = 0;
nNC             = 9;
parcScheme      = 2009;
Parc2OmitLabels = {'Unknown' 'Medial_wall'};
areaParc        = []; 
CMParc          = [];
for h = 1:2
    if h == 1, hemi = 'lh'; else hemi = 'rh'; end
    [surf] = fs_load_subj   (subj,hemi,surfname,nverts_only,subjdir);
    [surf] = fs_calc_triarea(surf);
    % read locations of each vertex
    try
        [roinums,roilabels] = fs_read_annotation([subjdir '/' subj '/label/' hemi '.aparc.a' int2str(parcScheme) 's.annot']);
    catch %#ok<CTCH>
        if parcScheme == 2009
            [roinums,roilabels] = fs_read_annotation([subjdir '/' subj '/label/' hemi '.aparc.a2009s.annot']);
        else
            [roinums,roilabels] = fs_read_annotation([subjdir '/' subj '/label/' hemi '.aparc.a2005s.annot']);
        end
    end

    % [roinums,roilabels] = fs_read_annotation([subjdir '/' subj '/label/' hemi '.aparc.a2005s.annot']);
    
    % find area associated with each region
    for k = 1:length(roilabels)
        ff = find(roinums == k);
        areaParc{h}(k) = sum(surf.vertex_area(ff));   % in cm^2
        CMParc{h}(k,:) = mean(surf.vertices(ff,:),1); % in mm
    end

    elem = 1; Parc2Omit = [];
    for k = 1:length(Parc2OmitLabels)
        fnd = find(strcmpi(roilabels,Parc2OmitLabels{k}));
        if ~isempty(fnd), Parc2Omit(elem) = fnd; elem = elem + 1; end
    end

    % ROI's not to be included
    withROI     = setdiff (1:length(roilabels), Parc2Omit);
    areaParc{h} = areaParc{h}(withROI);
    CMParc{h}   = CMParc{h}  (withROI,:);
    roilabels   = roilabels  (withROI);

    % assign 1's for non-cortical
    areaParc{h} = round([areaParc{h}'; ones(nNC,1)]);
    CMParc{h}   = round([CMParc{h};   ones(nNC,3)]);
end

[lh_aparc_stats,rh_aparc_stats] = fs_read_aparc_stats_2009(subj,subjdir,parcScheme,FREESURFER_HOME);

if ~isempty(lh_aparc_stats)
    Parc2Omit = []; elem = 1;
    for k = 1:length(Parc2OmitLabels)
        fnd = find(strcmpi({lh_aparc_stats.roiname},Parc2OmitLabels{k}));
        if ~isempty(fnd),
            Parc2Omit(elem) = fnd; elem = elem + 1;
        end
    end
    lh_aparc_stats(Parc2Omit) = [];
    rh_aparc_stats(Parc2Omit) = [];
end

return