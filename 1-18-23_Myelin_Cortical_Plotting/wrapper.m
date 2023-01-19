% Wrapper to create cortical plot from salience .mat data files
clear
clc

% adding paths to find necessary functions 
fpath = matlab.desktop.editor.getActiveFilename;
local = fpath(1:end - 10);
addpath(genpath([local '/Required_Functions']));
% Load all variables needed to make cortical plots
ctxp  = getCortexPlottingVars([local '/Required_Functions/cortex_plots']);

%%% VARIABLES THAT NEED TO BE SET
% set path to folder containing all subjects
subjdir = getSubFold();
% set name of subject you want to plot
subj    =  'TBIAD241FAN';
% set to 1 to use the same peak value for all cortical plots, or 0 to use
% a subject-specific value
sameCAxis = 0;

% combine paths to get to individual subject's folder
safp = fullfile(subjdir, subj);

% load in atlas-registered myelin
lh = load_mgh([safp '/SPMTP1lhnew_ico7.mgh']);
rh = load_mgh([safp '/SPMTP1rhnew_ico7.mgh']);

% combine left and right hemisphere myelin 
Q = [lh ; rh];

% make cortical plot
if sameCAxis
    % we want the same color axis peak for each subject
    m = 1.4;
    n = 0.9;
else
    % each plot will use the 90th percentile myelin value as the peak
    m = quantile(Q,0.90);
    % and the 10th percentile myelin value as the nadir
    n = quantile(Q,0.1);
end
res = 300;    % resolution
surfs2load = {'white'}; %can be white, pial or inflated
outfile = [local '/Outputs/' subj '.jpeg']; % cortical plot file name
cmap.caxis = [n m]; %colormap axis
cmap.colormap = mycolortable();
makeCompleteCortexFigure_colorbar(outfile,ctxp.AllSurfs,ctxp.AllSurfFaces,...
    ctxp.AllIndices2Plot,ctxp.AllFaces2Plot,Q,cmap,res,surfs2load);