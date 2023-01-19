function x = getCortexPlottingVars(cortex_plots)
% because this contains addpath, don't include it in compiled code!
% searches for and loads everything needed to make cortical plots

% if we can't find the stuff, return empty
if ~isfile([cortex_plots '/meshes/2015-02-03-surfaces.mat'])
    x = [];
    return
end

% addpath(genpath(cortex_plots));
load([cortex_plots '/meshes/2015-02-03-surfaces.mat'],...
    'AllSurfs','AllSurfFaces','AllIndices2Plot','AllFaces2Plot');

x.AllSurfs        = AllSurfs;
x.AllSurfFaces    = AllSurfFaces;
x.AllIndices2Plot = AllIndices2Plot;
x.AllFaces2Plot   = AllFaces2Plot;
end