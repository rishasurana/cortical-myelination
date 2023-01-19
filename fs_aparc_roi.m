function results = fs_aparc_roi(aparcname,funcname,frames,minval);
%function results = fs_aparc_roi(aparcname,funcname,[frames],[minval]);
%
% Input:
%  aparcname: full path to aparc annotation file
%    (e.g. subjdir/subj/label/lh.aparc.annot)
%  funcname: full path to functional/surface stats (must be mgh format)
%  frames: for multi-frame data, data from the specified frames will be
%    averaged together
%  minval: minimum value for inclusion in average
%    default = 10^-5
%
% created:  02/01/07 by Don Hagler
% last mod: 03/29/10 Don Hagler
%

results = [];
if (~mmil_check_nargs(nargin, 2)), return; end;

if ~exist('minval','var') | isempty(minval), minval = 10^-5; end;
if ~exist('frames','var'), frames=[]; end;

if ~exist(aparcname,'file')
  error('aparc annotation file %s not found',aparcname);
end;
if ~exist(funcname,'file')
  error('functional surface file %s not found\n',funcname);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% decide if aparc file is for lh or rh
[tpath,tstem,text] = fileparts(aparcname);
n = regexp(tstem,'(?<hemi>[lr]h)\.aparc','names');
if isempty(n)
  fprintf('%s: WARNING: aparcname %s has unexpected pattern... assuming lh\n',...
    mfilename,aparcname);
  hemi = 'lh';
else
  hemi = n.hemi;
end;

% get roi codes and names
[all_roicodes,all_roinames] = fs_colorlut;
switch hemi
  case 'lh' % lh roi codes and names
    [tmp,ind]=intersect(all_roicodes,[1000:1099]);
  case 'rh' % rh roi codes and names
    [tmp,ind]=intersect(all_roicodes,[2000:2099]);
end;
roicodes = all_roicodes(ind);
roinames = all_roinames(ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load aparc annotation
fprintf('%s: loading aparc annotation...\n',mfilename);
[roinums,roilabels] = fs_read_annotation(aparcname);

% load functional stats
fprintf('%s: loading functional surface data...\n',mfilename);
fvec = double(fs_load_mgh(funcname,[],frames));
if length(size(fvec))==4
  fvec = squeeze(mean(fvec,4));
end;

if length(fvec)~=length(roinums)
  error('number of data points in funcname (%d) does not match aparc (%d)',...
    length(fvec),length(roinums));
end;

fprintf('%s: extracting values...\n',mfilename);
for i=1:length(roilabels)
  roiname = roilabels{i};
  ind = find(~cellfun(@isempty,regexp(roinames,['ctx-[lr]h-' roiname])));
  if isempty(ind)
    roicode = NaN;
  else
    roicode = roicodes(ind);
    roiname = roinames{ind};
  end;
  results(i).roiname = roiname;
  results(i).roicode = roicode;
  roi = find(roinums==i);
  if isempty(roi)
    results(i).vals = [];
    results(i).nverts = 0;
    results(i).nvals = 0;
    results(i).avg = NaN;
    results(i).stdv = NaN;
  else
    raw_vals = fvec(roi);
    vals = raw_vals(abs(raw_vals)>minval & ~isnan(raw_vals));
    results(i).vals = vals;
    results(i).nverts = length(raw_vals);
    results(i).nvals = length(vals);
    if results(i).nvals>0
      results(i).avg = mean(vals);
    else
      results(i).avg = NaN;
    end;
    if results(i).nvals>1
      results(i).stdv = std(vals);
    else
      results(i).stdv = NaN;
    end;
  end;
end

