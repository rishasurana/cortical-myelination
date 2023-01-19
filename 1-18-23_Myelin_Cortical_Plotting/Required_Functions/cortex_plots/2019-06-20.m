clear;

addpath(genpath('C:\Users\P06\Desktop\surfaces\2019-06-19-code'));

subjname = 'fsaverage'; % '002_S_0413';
subjdir  = 'C:\Users\P06\Desktop\';
indir    = 'C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat';
outfileS = ['C:\Users\P06\Desktop\surfaces\2019-06-19-output\' subjname '-surfs.mat'];
% outfileS = ['C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2015-01-05-surfaces.mat'];
overlayL = ['C:\Users\P06\Desktop\' subjname '\surf\lh.curv'];
overlayR = ['C:\Users\P06\Desktop\' subjname '\surf\rh.curv'];
outfileF = 'C:\Users\P06\Desktop\surfaces\2019-06-19-output\2019-06-20.jpeg';

res      = 300;
cmap.caxis = [-1 1];
cmap.colormap = 'jet';
surfs2load    = {'white'};%{'white' 'pial' 'inflated'};

makeSubjectMesh_2019_06_21_v2(subjname,subjdir,indir,outfileS);
% overlayL, overlayR, outfileS, outfileF, res, cmap, surfs2load
createMATLABFigure_2019_06_20(overlayL, overlayR, outfileS, outfileF, indir, res, cmap, surfs2load);

% load('C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2015-01-05-surfaces.mat','ParcMeshInfo');
% load C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2019-06-19.mat;
% load C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2019-06-19-colors.mat;
% load C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\colors.mat;
% LobeColorSchemes = [LobeColorSchemes; flipud(LobeColorSchemes(1:end-1,:))];

for k = 1:length(surfs2load)
    for h = 1:length(hemis)
        tic
        annot_file = [subjdir '\' subjname '\label\' hemis{h} '.aparc.a' int2str(parcScheme) 's.annot'];
        % annot_file = [subjdir '\' subjname '\label\' hemis{h} '.aparc.annot'];
        face_files{k,h} = [outdir '\' subjname '-' surfs2load{k} '-faces-' hemis{h} '-' int2str(parcScheme) '.mat'];
        % load input file
        eval([hemis{h} '_surf  = fs_load_subj(subjname,''' hemis{h} ''',surfs2load{k},0,subjdir);']);
        eval(['surf      = ' hemis{h} '_surf;']);
        eval(['[roinums_' hemis{h} ',roilabels_' hemis{h} '] = fs_read_annotation(annot_file);']);
        % find mesh data
        CMaps = {}; CMapIndices = []; CC = [];
        eval(['roinums   = roinums_'   hemis{h} ';']);
        eval(['roilabels = roilabels_' hemis{h} ';']);
        eval(['surf      = ' hemis{h} '_surf;']);
        for k2 = 1:length(ParcMeshInfo)
            % find which label corresponds to a certain index
            ff = find(strcmpi(roilabels,ParcMeshInfo{k2,1}));
            fg = []; if ~isempty(ff), fg = roinums == ff; end
            ParcMeshInfo{k2,3} = int2str(LobeColorSchemes(k2,:));
            if sum(strcmpi(ParcMeshInfo{k2,3},CMaps)) == 0
                CMaps{length(CMaps)+1} = ParcMeshInfo{k2,3};
            end
            CMapIndices(fg) = find(strcmpi(CMaps,ParcMeshInfo{k2,3}));
        end
        
        % initialize arrays
        SurfFaces  = {};
        faces.F    = surf.faces;
        faces.P    = zeros(length(faces.F),1);
        for k2 = 0:length(ParcMeshInfo)
            % find good faces
            fnd = sort(find(CMapIndices == k2));
            if isempty(fnd), continue; end
            first = []; thispos = 1;
            % first, find range in faces array that we are interested in
            for b  = 1:3,
                first(b) = min(sort(find(faces.F(:,1) >= fnd(1  )))); %#ok<AGROW>
                last (b) = max(sort(find(faces.F(:,1) <= fnd(end)))); %#ok<AGROW>
            end;
            first = min(first); last = min(last);
            for b = 0:last-first
                if faces.P(first + b), continue; end
                ff = find(fnd == faces.F(first + b,1), 1);
                if ~isempty(ff),
                    SurfFaces{k2+1}(thispos) = first + b; %#ok<AGROW>
                    thispos                = thispos + 1;
                    faces.P(first + b)     = 1;
                end
            end
        end
        % process mesh data
        for k2 = 0:length(SurfFaces)-1
            plot_faces = surf.faces(cell2mat(SurfFaces(k2+1)),:);
            plot_faces = num2cell(plot_faces);
            plot_faces = sortcell(plot_faces,1);
            plot_faces = cell2mat(plot_faces);
            % find faces which do not include exclusively vertices desired
            gg     = find(CMapIndices == k2);
            bound  = setdiff(unique(plot_faces),gg);
            % exclude those faces from plot
            for b = 1:length(bound)
                for bb = 1:3, plot_faces(plot_faces(:,bb) == bound(b),:) = []; end
            end
            % now exclude unwanted verts
            hh = setdiff(unique(gg),unique(plot_faces));
            for b = 1:length(hh)
                ff = find(gg == hh(b));
                gg(ff) = []; %#ok<FNDSB>
            end
            % get data to plot
            gg     = sort(gg);
            % now arrange all faces as desired
            for b = 1:length(gg), pfaces2(plot_faces == gg(b)) = b; end
            pfaces2        = reshape(pfaces2,length(pfaces2)/3,3);
            plot_faces     = pfaces2; clear pfaces2;
            faces2plot{k2+1} = plot_faces; %#ok<AGROW>
            index2plot{k2+1} = gg;         %#ok<AGROW>
        end
        toc
        % need: AllFaces2Plot, AllIndices2Plot, AllSurfFaces, AllSurfs, LobeColorSchemes
        % save(face_files{k,h},'SurfFaces','faces2plot','index2plot','CMaps','roinums','roilabels','surf','ParcMeshInfo','LobeColorSchemes');
        AllFaces2Plot{h} = faces2plot;
        AllIndices2Plot{h} = index2plot;
        AllSurfFaces{h} = SurfFaces;
        AllSurfs{k,h} = surf;
    end
end

