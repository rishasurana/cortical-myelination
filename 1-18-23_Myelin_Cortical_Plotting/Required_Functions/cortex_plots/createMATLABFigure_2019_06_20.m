%This function requires many FSTools. 
%Folder of Data is generally subject->fsaverage->surf
%nameOfData is the file to be analyzed. For example, lh.thickness.

%Path to atlas is the path to the .mat file containing the vertices and
%connections to render the brain image. For example, C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2015-01-05-surfaces.mat

%analysisType is the kind of document inputted. For example, thickness,
%curve, mgh. Inputs are 'thickness', 'curv', 'mgh'

%Resolution is the desired resolution of the final jpg image.
%finalJPEGName is the name of the resulting JPEG

function createMATLABFigure_2019_06_20(overlayL, overlayR, surface_file, outfile, indir, resolution, cmap, surfs2load)
%cd C:\Users\P06\Desktop\002_S_0413\fsaverage\surf
% cd(folderOfData)

% addpath(genpath('D:\circos-attempts\2012-02-16-02-circos-attempt-Gage'));
% addpath('C:\Users\P06\Desktop\surfaces\2019-06-18-meshes');
% addpath(genpath('C:\Users\P06\Desktop\surfaces\fstools'));

%load C:\Users\airimia\Documents\EEG-forward-TBI\2014-12-23-example\2015-01-05-surfaces.mat;
load(surface_file);
load([indir '\colors.mat']);
load([indir '\info.mat']);

LobeColorSchemes = LobeColorSchemes(1:165,:);
LobeColorSchemes([75 91],:) = 255;
AllCMaps        = AllCMaps{1,1};
AllFaces2Plot   = AllFaces2Plot(1,:);
AllIndices2Plot = AllIndices2Plot(1,:);
AllROIlabels    = AllROIlabels(1,:);
AllROInums      = AllROInums(1,:);
AllSurfFaces    = AllSurfFaces(1,:);

% fix AllIndices2Plot (from 1 to 163842)
AllIndices2Plot{1,1}{1,75} = find(AllROInums{1,1} == 43);
AllIndices2Plot{1,2}{1,75} = find(AllROInums{1,2} == 43);

% still must fix AllFaces2Plot (y by 3), AllSurfFaces (1 by x)
% AllSurfs{1,1}.faces is the same for all three surfaces
for h = 1:2
    clear faces indices a b todel ndx2del k1 k facess facesn;
    faces   = [];
    indices = AllIndices2Plot{1,h}{1,75};
    for k1 = 1:length(AllIndices2Plot{1,h}{1,75})
        [a,b]  = find(AllSurfs{1,h}.faces == indices(k1));
        faces  = [faces; AllSurfs{1,h}.faces(a,:)];
    end
    % exclude faces not present in indices array
    todel = setdiff(unique(faces),indices);
    ndx2del = [];
    for k = 1:length(todel)
        [a,b] = find(faces == todel(k));
        faces(a,:) = [];
    end
    % reorder starting at 1
    facess = sort(unique(faces));
    for k = 1:length(facess)
        [a,b] = find(faces == facess(k));
        for k2 = 1:length(a)
            facesn(a(k2),b(k2)) = k;
        end
    end
    AllFaces2Plot{1,h}{75} = facesn;
    AllSurfFaces{1,h}{75}  = unique(faces);
end

%save('C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2015-02-03-surfaces.mat','All*','LobeColorSchemes',...
%    'ParcMeshData','anatomy_only','measures','surfs2load');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rR = read_curv(overlayR);
% rL = read_curv(overlayL);
r  = [rL; rR];

%r = load_mgh('14a_lh_curv_s20_ico.mgh');
% if strlength(analysisType) == 9 
% rR = read_curv('rh.thickness');
% rL = read_curv('lh.thickness');
% r = [rL; rR];
% cmap.caxis = [0 1].*5;
% cmap.colormap = 'hot';
% end
% 
% if strlength(analysisType) == 4 
%     rR = read_curv('rh.curv');
%     rL = read_curv('lh.curv');
%     r = [-rL; -rR];
%     cmap.caxis = [-0.7 0.7];
%     cmap.colormap = 'jet';
% end
% 
% if strlength(analysisType) == 3
%     inputLH = input('What is the name of the lh file?');
%     inputRH = input('What is the name of the rh file?');
%     rR = load_mgh(inputLH);
%     rL = load_mgh(inputRH);
%     r = [rL; rR];
%     cmap.caxis = [0 1];
%     cmap.colormap = 'hot';
% end

%clear
%load C:\Users\P06\Desktop\surfaces\2019-06-18-meshes\mat\2015-02-03-surfaces;

% surfs2load    = {'white' 'pial' 'inflated'};
% outdir        = pwd;
% printfig      = 1;

% Q = 1:327684;

% subjname   = 'fsaverage';
% parcScheme = 2009;
% hemis      = {'lh' 'rh'};

%cmap.colormap = 'hot';
%cmap.caxis = [0 1].*5;
% outfile = [outdir '/' finalJPEGName];

makeCompleteCortexFigure_2019_06_19(outfile,AllSurfs,AllSurfFaces,AllIndices2Plot,AllFaces2Plot,r,cmap,resolution,surfs2load);
end