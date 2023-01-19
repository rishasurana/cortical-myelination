function [lh_aparc_stats,rh_aparc_stats] = fs_read_aparc_stats_2009(subj,subjdir,parcScheme,FREESURFER_HOME);
%function [lh_aparc_stats,rh_aparc_stats] = fs_read_aparc_stats(subj,[subjdir],[parcScheme]);
%
% Required input:
%  subj is a string specifying the subject name
%
% Optional input:
%  subjdir - subjects directory (override SUBJECTS_DIR environment variable)
%    subjdir/subj should contain the freesurfer subject directory
%    {default = $SUBJECTS_DIR}
%  a2009_flag - [0|1] toggle read aparc.a2005s.stats files instead of aparc.stats
%    {default = 0}
%
% Output:
%   lh_aparc_stats & rh_aparc_stats are struct arrays containing:
%     roiname
%     roicode
%     grayvol
%     surfarea
%     thickavg
%     thickstd
%     meancurv
%     gausscurv
%     foldind
%     curvind
%
% created:  04/01/09 by Don Hagler
% last mod: 12/27/10 by Andrei Irimia
%

%% todo: roigroups for lobar analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lh_aparc_stats = [];
rh_aparc_stats = [];
if (~mmil_check_nargs(nargin,1)) return; end;

if ~exist('parcScheme','var') | isempty(parcScheme)
  parcScheme = 2005;
end;

if ~exist('subjdir','var') | isempty(subjdir)
  subjdir = getenv('SUBJECTS_DIR');
  if isempty(subjdir)
    error('The variable SUBJECTS_DIR is undefined.');
  end;
end;

lh_aparc_fname = sprintf('%s/%s/stats/lh.aparc.a%ss.stats',subjdir,subj,int2str(parcScheme));
if ~exist(lh_aparc_fname,'file')
  fprintf('The file %s was not found.\n',...
    lh_aparc_fname);
  return;
end;

rh_aparc_fname = sprintf('%s/%s/stats/rh.aparc.a%ss.stats',subjdir,subj,int2str(parcScheme));
if ~exist(rh_aparc_fname,'file')
  fprintf('The file %s was not found.\n',...
    rh_aparc_fname);
  return;
end;

fname = sprintf('%s/FreeSurferColorLUT.txt',FREESURFER_HOME);
[all_roicodes,all_roinames] = fs_colorlut(fname);

% get aparc lh roi codes and names
[tmp,ind_lh]=intersect(all_roicodes,[1000:1099]);
lh_roicodes = all_roicodes(ind_lh);
lh_roinames = all_roinames(ind_lh);
lh_nrois = length(ind_lh);

% get aparc rh roi codes and names
[tmp,ind_rh]=intersect(all_roicodes,[2000:2099]);
rh_roicodes = all_roicodes(ind_rh);
rh_roinames = all_roinames(ind_rh);
rh_nrois = length(ind_rh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read lh aparc file
if ~isempty(lh_aparc_fname)
  try
    fid = fopen(lh_aparc_fname);
    tmp_stats = textscan(fid,'%s %d %d %d %f %f %f %f %f %f\n',...
      'commentstyle','#');
    for i=1:length(tmp_stats{1})
      roiname = char(tmp_stats{1}{i});
      ind = find(~cellfun(@isempty,regexp(lh_roinames,['ctx-lh-' roiname])));
      if isempty(ind)
        roicode = NaN;
      else
        roicode = lh_roicodes(ind);
        roiname = lh_roinames{ind};
      end;
      lh_aparc_stats(i).roiname   = roiname;
      lh_aparc_stats(i).roicode   = roicode;
      lh_aparc_stats(i).surfarea  = double(tmp_stats{3}(i));
      lh_aparc_stats(i).grayvol   = double(tmp_stats{4}(i));
      lh_aparc_stats(i).thickavg  = double(tmp_stats{5}(i));
      lh_aparc_stats(i).thickstd  = double(tmp_stats{6}(i));
      lh_aparc_stats(i).meancurv  = double(tmp_stats{7}(i));
      lh_aparc_stats(i).gausscurv = double(tmp_stats{8}(i));
      lh_aparc_stats(i).foldind   = double(tmp_stats{9}(i));
      lh_aparc_stats(i).curvind   = double(tmp_stats{10}(i));
    end;
    % go back to beginning of file
    frewind(fid);
    % skip first 20 lines
    for t=1:21
      tmp = fgetl(fid);
    end;
    k = findstr(tmp,', ');
    if isempty(k)
      fprintf('surface areas are unavailable\n');
    else
      i = i + 1;
      lh_aparc_stats(i).roiname = 'TotalSurfaceArea';
      tmp = tmp(k(3)+2:k(4)-1);
      lh_aparc_stats(i).roicode   = NaN;
      lh_aparc_stats(i).surfarea = str2double(tmp);
      lh_aparc_stats(i).grayvol   = 0;
      lh_aparc_stats(i).thickavg  = 0;
      lh_aparc_stats(i).thickstd  = 0;
      lh_aparc_stats(i).meancurv  = 0;
      lh_aparc_stats(i).gausscurv = 0;
      lh_aparc_stats(i).foldind   = 0;
      lh_aparc_stats(i).curvind   = 0;
    end;
    fclose(fid);
  catch
    fprintf('Cannot read the stats file for the left hemisphere\n',mfilename);
  end;
end;

  % read rh aparc file
if ~isempty(rh_aparc_fname)
  try
    fid = fopen(rh_aparc_fname);
    tmp_stats = textscan(fid,'%s %d %d %d %f %f %f %f %f %f\n',...
      'commentstyle','#');
    for i=1:length(tmp_stats{1})
      roiname = char(tmp_stats{1}{i});
      ind = find(~cellfun(@isempty,regexp(rh_roinames,['ctx-rh-' roiname])));
      if isempty(ind)
        roicode = NaN;
      else
        roicode = rh_roicodes(ind);
        roiname = rh_roinames{ind};
      end;
      rh_aparc_stats(i).roiname   = roiname;
      rh_aparc_stats(i).roicode   = roicode;
      rh_aparc_stats(i).surfarea  = double(tmp_stats{3}(i));
      rh_aparc_stats(i).grayvol   = double(tmp_stats{4}(i));
      rh_aparc_stats(i).thickavg  = double(tmp_stats{5}(i));
      rh_aparc_stats(i).thickstd  = double(tmp_stats{6}(i));
      rh_aparc_stats(i).meancurv  = double(tmp_stats{7}(i));
      rh_aparc_stats(i).gausscurv = double(tmp_stats{8}(i));
      rh_aparc_stats(i).foldind   = double(tmp_stats{9}(i));
      rh_aparc_stats(i).curvind   = double(tmp_stats{10}(i));
    end;
    % go back to beginning of file
    frewind(fid);
    % skip first 20 lines
    for t=1:21
      tmp = fgetl(fid);
    end;
    k = findstr(tmp,', ');
    if isempty(k)
      fprintf('surface areas are unavailable\n');
    else
      i = i + 1;
      rh_aparc_stats(i).roiname = 'TotalSurfaceArea';
      tmp = tmp(k(3)+2:k(4)-1);
      rh_aparc_stats(i).roicode   = NaN;
      rh_aparc_stats(i).surfarea = str2double(tmp);
      rh_aparc_stats(i).grayvol   = 0;
      rh_aparc_stats(i).thickavg  = 0;
      rh_aparc_stats(i).thickstd  = 0;
      rh_aparc_stats(i).meancurv  = 0;
      rh_aparc_stats(i).gausscurv = 0;
      rh_aparc_stats(i).foldind   = 0;
      rh_aparc_stats(i).curvind   = 0;
    end;
    fclose(fid);
  catch
    fprintf('Cannot read the stats file for the right hemisphere\n',mfilename);
  end;
end;

