function [labels, TICV] = getParcellations(subjdir,subj,areaParc,lh_aparc_stats,rh_aparc_stats,normalize)

% read parcellation files
LobeCodes  = {'F' 'I' 'L' 'T' 'P' 'O' 'N' 'C' 'S'};
parcScheme = 2009;
nNC        = 9;
isatlas    = 0;
cnt        = 0;
offset     = 6;

orig_labels = {'F','FMarG/S','G_and_S_frontomargin';'O','InfOcG/S','G_and_S_occipital_inf';'P','PaCL/S','G_and_S_paracentral';'F','SbCG/S','G_and_S_subcentral';'F','TrFPoG/S','G_and_S_transv_frontopol';'L','ACgG/S','G_and_S_cingul-Ant';'L','MACgG/S','G_and_S_cingul-Mid-Ant';'L','MPosCgG/S','G_and_S_cingul-Mid-Post';'L','PosDCgG','G_cingul-Post-dorsal';'L','PosVCgG','G_cingul-Post-ventral';'O','Cun','G_cuneus';'F','InfFGOpp','G_front_inf-Opercular';'F','InfFGOrp','G_front_inf-Orbital';'F','InfFGTrip','G_front_inf-Triangul';'F','MFG','G_front_middle';'F','SupFG','G_front_sup';'I','LoInG/CInS','G_Ins_lg_and_S_cent_ins';'I','ShoInG','G_insular_short';'O','MOcG','G_occipital_middle';'O','SupOcG','G_occipital_sup';'O','FuG','G_oc-temp_lat-fusifor';'O','LinG','G_oc-temp_med-Lingual';'O','PaHipG','G_oc-temp_med-Parahip';'F','OrG','G_orbital';'P','AngG','G_pariet_inf-Angular';'P','SuMarG','G_pariet_inf-Supramar';'P','SupPL','G_parietal_sup';'P','PosCG','G_postcentral';'F','PrCG','G_precentral';'P','PrCun','G_precuneus';'F','RG','G_rectus';'L','SbCaG','G_subcallosal';'T','HG','G_temp_sup-G_T_transv';'T','SupTGLp','G_temp_sup-Lateral';'T','PoPl','G_temp_sup-Plan_polar';'T','TPl','G_temp_sup-Plan_tempo';'T','InfTG','G_temporal_inf';'T','MTG','G_temporal_middle';'I','ALSHorp','Lat_Fis-ant-Horizont';'I','ALSVerp','Lat_Fis-ant-Vertical';'I','PosLS','Lat_Fis-post';'O','OcPo','Pole_occipital';'T','TPo','Pole_temporal';'O','CcS','S_calcarine';'F','CS','S_central';'L','CgSMarp','S_cingul-Marginalis';'I','ACirInS','S_circular_insula_ant';'I','InfCirInS','S_circular_insula_inf';'I','SupCirInS','S_circular_insula_sup';'T','ATrCoS','S_collat_transv_ant';'O','PosTrCoS','S_collat_transv_post';'F','InfFS','S_front_inf';'F','MFS','S_front_middle';'F','SupFS','S_front_sup';'P','JS','S_interm_prim-Jensen';'P','IntPS/TrPS','S_intrapariet_and_P_trans';'O','MOcS/LuS','S_oc_middle_and_Lunatus';'O','SupOcS/TrOcS','S_oc_sup_and_transversal';'O','AOcS','S_occipital_ant';'O','LOcTS','S_oc-temp_lat';'O','CoS/LinS','S_oc-temp_med_and_Lingual';'F','LOrS','S_orbital_lateral';'F','MedOrS','S_orbital_med-olfact';'F','OrS','S_orbital-H_Shaped';'P','POcS','S_parieto_occipital';'L','PerCaS','S_pericallosal';'P','PosCS','S_postcentral';'F','InfPrCS','S_precentral-inf-part';'F','SupPrCS','S_precentral-sup-part';'F','SbOrS','S_suborbital';'P','SbPS','S_subparietal';'T','InfTS','S_temporal_inf';'T','SupTS','S_temporal_sup';'T','TrTS','S_temporal_transverse';'N','Pu','Putamen';'N','Pal','Pallidum';'N','CaN','Caudate';'N','NAcc','Accumbens-area';'N','Amg','Amygdala';'N','Tha','Thalamus-Proper';'N','Hip','Hippocampus';'C','CeB','Cerebellum-Cortex';'S','BStem','Brain-Stem';};
labels      = {'F','TrFPoG/S',[],255,153,153;'F','FMarG/S',[],204,0,51;'F','MFS',[],255,153,51;'F','LOrS',[],102,0,0;'F','SbOrS',[],255,51,102;'F','OrS',[],255,204,204;'F','RG',[],255,204,153;'F','InfFGOrp',[],153,51,0;'F','MFG',[],255,255,51;'F','OrG',[],255,255,153;'F','InfFGTrip',[],255,0,0;'F','InfFS',[],153,102,0;'F','MedOrS',[],255,102,0;'F','SupFG',[],255,102,102;'F','SupFS',[],204,153,0;'F','InfFGOpp',[],255,204,0;'F','InfPrCS',[],255,153,0;'F','SupPrCS',[],255,0,102;'F','PrCG',[],204,102,0;'F','SbCG/S',[],255,102,153;'F','CS',[],255,51,0;'I','ALSHorp',[],0,255,204;'I','ACirInS',[],102,255,255;'I','ALSVerp',[],0,255,255;'I','ShoInG',[],51,255,204;'I','SupCirInS',[],0,153,153;'I','LoInG/CInS',[],0,204,204;'I','InfCirInS',[],0,102,102;'I','PosLS',[],204,255,255;'L','ACgG/S',[],255,255,180;'L','MACgG/S',[],255,240,191;'L','SbCaG',[],255,153,200;'L','PerCaS',[],255,164,200;'L','MPosCgG/S',[],255,224,203;'L','CgSMarp',[],255,192,201;'L','PosDCgG',[],255,175,201;'L','PosVCgG',[],255,208,202;'T','TPo',[],255,204,255;'T','PoPl',[],204,153,255;'T','SupTGLp',[],153,51,255;'T','HG',[],102,0,102;'T','ATrCoS',[],153,0,204;'T','TrTS',[],255,153,255;'T','MTG',[],255,102,204;'T','TPl',[],153,0,153;'T','InfTG',[],255,0,255;'T','InfTS',[],204,0,153;'T','SupTS',[],204,51,255;'P','PosCG',[],204,255,204;'P','SuMarG',[],204,255,102;'P','PaCL/S',[],204,255,153;'P','PosCS',[],153,255,0;'P','JS',[],153,204,0;'P','SbPS',[],102,153,0;'P','IntPS/TrPS',[],51,255,51;'P','SupPL',[],153,255,153;'P','PrCun',[],204,255,0;'P','AngG',[],0,255,0;'P','POcS',[],204,255,51;'O','PaHipG',[],204,204,255;'O','CoS/LinS',[],153,204,255;'O','LOcTS',[],153,153,255;'O','FuG',[],102,102,255;'O','CcS',[],102,153,255;'O','LinG',[],102,204,255;'O','AOcS',[],51,51,255;'O','InfOcG/S',[],51,153,255;'O','SupOcS/TrOcS',[],0,102,255;'O','PosTrCoS',[],51,102,255;'O','Cun',[],0,153,255;'O','MOcG',[],0,204,244;'O','MOcS/LuS',[],0,51,255;'O','SupOcG',[],0,0,255;'O','OcPo',[],0,0,153;'N','Pu',[],32,32,32;'N','Pal',[],64,64,64;'N','CaN',[],96,96,96;'N','NAcc',[],128,128,128;'N','Amg',[],159,159,159;'N','Tha',[],191,191,191;'N','Hip',[],223,223,223;'CeB','CeB',[],255,64,0;'S','BStem',[],207,255,48;};

for k1 = 1:length(labels)
    for k2 = 1:length(orig_labels)
        if strcmpi(labels{k1,2},orig_labels{k2,2})
            labels{k1,3} = orig_labels{k2,3};
            break;
        end
    end
end

nL          = length(labels);
orig_labels = orig_labels(:,1:3);

% load area data
area = sum(areaParc{1})+sum(areaParc{2});
% I am starting with the right hemi, hence index below is 2
for k = 1:nL, labels(k,offset+1) = {areaParc{2}(k)}; end

% create correspondence map
for k = 1:nL, ndx(k,1) = find(strcmp(orig_labels(:,2),labels(k,2))); end

% get left hemisphere
for k = 1:nL-nNC
    labels(k,offset+1) = {areaParc{2}(ndx(k))};
end
labels2flip = labels(1:length(labels)-1,:);
labels = [labels2flip; labels(length(labels),:); flipud(labels2flip)]; % gets labels and abbreviations ONLY
for k = 1:nL-nNC
    labels(nL*2-k,offset+1) = {areaParc{1}(ndx(k))};
end

% include curvature, etc.
% create correspondence map for the lh_aparc structure
try
    for k = 1:length(lh_aparc_stats), aparc_labels(k,1) = {lh_aparc_stats(k).roiname}; end
    for k = 1:nL-nNC, ndx_aparc(k,1) = find(strcmp(aparc_labels,labels(k,3))); end

    for k = 1:nL-nNC
        labels(k,offset+2) = { rh_aparc_stats(ndx_aparc(k)).thickavg};
        labels(k,offset+3) = {-rh_aparc_stats(ndx_aparc(k)).meancurv};
        labels(k,offset+4) = { rh_aparc_stats(ndx_aparc(k)).grayvol };
    end
    
    % left hemisphere
    for k = 1:nL-nNC
        labels(nL*2-k,offset+2) = { lh_aparc_stats(ndx_aparc(k)).thickavg};
        labels(nL*2-k,offset+3) = {-lh_aparc_stats(ndx_aparc(k)).meancurv};
        labels(nL*2-k,offset+4) = { lh_aparc_stats(ndx_aparc(k)).grayvol };
    end
end

% load and assign volumes of non-cortical regions
aseg_stats = fs_read_aseg_stats_2014(subj,subjdir);
% left non-cortical
for k = 1:nNC-1
    thisLabel = ['Left-' cell2mat(labels(nL-nNC+k,3))];
    for k2 = 1:length(aseg_stats)
        if strcmpi(thisLabel,aseg_stats(k2).roiname)
            labels(nL-nNC+k,offset+4) = {aseg_stats(k2).volume}; break;
        end
    end
end
% brain stem
thisLabel = 'Brain-Stem';
for k2 = 1:length(aseg_stats)
    if strcmpi(thisLabel,aseg_stats(k2).roiname)
        labels(nL,offset+4) = {aseg_stats(k2).volume}; break;
    end
end
% right non-cortical
for k = nL+1:nL+nNC-1
    thisLabel = ['Right-' cell2mat(labels(k,3))];
    for k2 = 1:length(aseg_stats)
        if strcmpi(thisLabel,aseg_stats(k2).roiname)
            labels(k,offset+4) = {aseg_stats(k2).volume}; break;
        end
    end
end
% normalize by total intracranial volume
TICV = aseg_stats(48).volume;
if normalize,
    for k = 1:size(labels,1)
        labels{k,offset+1} = labels{k,offset+1}.*(1000/(TICV.^0.67)); % area
        labels{k,offset+2} = labels{k,offset+2}.*(1000/(TICV.^0.33)); % thickness
        labels{k,offset+4} = labels{k,offset+4}.*(1000/TICV);         % volume
    end
end

% assign zeros to null values
for k1 = 1:length(labels)
    for k2 = 1:4
        if isempty(cell2mat(labels(k1,offset+k2))), labels(k1,offset+k2) = {0}; end
    end
end
return
