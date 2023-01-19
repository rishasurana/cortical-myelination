function makeCompleteCortexFigure(outfile,AllSurfs,AllSurfFaces,AllIndices2Plot,AllFaces2Plot,...
    quant2plot,cmap,res,surfs2load)

tic
% if ~exist('subjname')    subjname = 'fsaverage'; end
% if ~exist('printfig'),   printfig = 1; end
if ~exist('surfs2load'), surfs2load = {'white'}; end
if ~exist('res'),        res = 300; end
% custom angles
customAngles = zeros(3,3);
% get adjustments
adj   = getCanonicalAdjustments(surfs2load);
F = figure; set(gcf,'PaperPositionMode','auto');
views  = {'lat_L' 'lat_R' 'med_L' 'med_R' 'ant'  'pos' 'dor' 'ven'};
LobeColorSchemes = [255,153,153;204,0,51;255,153,51;102,0,0;255,51,102;255,204,204;255,204,153;153,51,0;255,255,51;255,255,153;255,0,0;153,102,0;255,102,0;255,102,102;204,153,0;255,204,0;255,153,0;255,0,102;204,102,0;255,102,153;255,51,0;0,255,204;102,255,255;0,255,255;51,255,204;0,153,153;0,204,204;0,102,102;204,255,255;255,255,180;255,240,191;255,153,200;255,164,200;255,224,203;255,192,201;255,175,201;255,208,202;255,204,255;204,153,255;153,51,255;102,0,102;153,0,204;255,153,255;255,102,204;153,0,153;255,0,255;204,0,153;204,51,255;204,255,204;204,255,102;204,255,153;153,255,0;153,204,0;102,153,0;51,255,51;153,255,153;204,255,0;0,255,0;204,255,51;204,204,255;153,204,255;153,153,255;102,102,255;102,153,255;102,204,255;51,51,255;51,153,255;0,102,255;51,102,255;0,153,255;0,204,244;0,51,255;0,0,255;0,0,153;255,255,255;64,64,64;96,96,96;128,128,128;159,159,159;191,191,191;223,223,223;255,64,0;207,255,48];
LobeColorSchemes = [LobeColorSchemes; flipud(LobeColorSchemes(1:82,:))];
axes   = {'x' 'y' 'z'};
coords = {'x' 'y' 'z'};
faces2plot = [AllFaces2Plot{1,1}   AllFaces2Plot{1,2}];

for k = 1:length(surfs2load)
    index2plot = [AllIndices2Plot{1,1} AllIndices2Plot{1,2}];
    for k2 = 1:length(index2plot)/2
        array = index2plot{length(index2plot)/2+k2};
        array = array + AllSurfs{k,1}.nverts;
        index2plot{length(index2plot)/2+k2} = array;
    end
    
    % make brain structure
    left  = AllSurfs{k,1}.vertices;
    right = AllSurfs{k,2}.vertices;
    
    % ori   = 0;
    % process inflated surface
    if k == find(strcmpi(surfs2load,'inflated')),
        for k2 = 1:3,
            left (:,k2) = left (:,k2).*adj.scale(k);
            right(:,k2) = right(:,k2).*adj.scale(k);
        end
        left (:,1) = left (:,1) - adj.separation;
        right(:,1) = right(:,1) + adj.separation;
    end
    brain = [left; right]';
    brain = brain./1000; % mm to m
    brain = [brain; zeros(1,length(brain))];
    % translate to center of coordinate system
    brain = brain - repmat(mean(brain,2),1,length(brain));
    % fix pitch, roll, yaw
    for k2 = 1:3
        brain = rotateBrain(brain,coords{k2},customAngles(k,k2));
        brain = brain - repmat(mean(brain,2),1,length(brain));
    end
    % create views
    for k2 = 1:length(views)
        % perform rotations
        eval(sprintf('b_%s = brain;',views{k2}));
        for r = 1:3
            eval(sprintf('b_%s = rotateBrain(b_%s,''%s'',pi.*%f);',views{k2},views{k2},axes{r},adj.rot(r,k2)));
            eval(sprintf('b_%s = b_%s - repmat(mean(b_%s,2),1,length(brain));',views{k2},views{k2},views{k2}));
        end
        % perform translations
        eval(sprintf('b_%s = b_%s + repmat([adj.trans(:,k2); 0],1,length(b_%s));',views{k2},views{k2},views{k2}));
        % perform shifts
        eval(sprintf('b_%s(3,:) = b_%s(3,:) + adj.shifts(k);',views{k2},views{k2}));
    end
    for k2 = 1:length(AllSurfFaces{1,1})+length(AllSurfFaces{1,2}) % make image for the anatomy
        if k2 <= length(AllSurfFaces{1,1}), ndx = k2; else ndx = k2 - length(AllSurfFaces{1,1}); end
        for b = 1:length(views)
            if strcmpi(views(b),'med_L') && k2 >  length(AllSurfFaces{1,1}), continue; end
            if strcmpi(views(b),'med_R') && k2 <= length(AllSurfFaces{1,1}), continue; end
            eval(['verts = b_' views{b} '(1:3,index2plot{k2});']);
            p = trimesh(faces2plot{k2},verts(1,:),verts(2,:),verts(3,:),quant2plot(index2plot{k2}),...
                'EdgeAlpha',1,'EdgeLighting','phong','FaceColor','interp','FaceAlpha',1,'FaceLighting','phong');
            if k2 == length(AllSurfFaces{1,1}) || k2 == length(AllSurfFaces{1,1})*2
                set(p,'EdgeColor',LobeColorSchemes(ndx,:)./256); % if drawing the medial wall (for any measure)
                set(p,'FaceColor',LobeColorSchemes(ndx,:)./256);
            else
                colormap(cmap.colormap);
                caxis(cmap.caxis);
            end
            hold on;
        end
    end
end
axis equal; view(0,0); box off; grid off; axis off;
light('Position',[-.1 3 -0.075]);
% save file
c            = clock;
datestr      = sprintf('%04i-%02i-%02i',c(1),c(2),c(3));
% picture_file = [outdir '\' datestr '-' subjname '.jpeg'];
print(F,'-djpeg',['-r' int2str(res)],outfile);
RemoveWhiteSpace([], 'file', outfile);
toc
return