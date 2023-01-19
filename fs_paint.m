function fnames_out = fs_paint(subj,funcname,varargin);
%function fnames_out = fs_paint(subj,funcname,[options]);
%
% Purpose:
%   a wrapper around freesurfer binaries for sampling
%   volume data to surface, sampling to sphere, and smoothing
%
% Usage:
%  fs_paint(subj,funcname,'key1', value1,...);
%
% Required parameters:
%  subj is a string specifying the subject name
%  funcname is a string specifying the full or relative path
%    of the functional volume (must be mgh format)
%    (can be empty if 'meas' is supplied -- see below)
%
% Optional parameters:
%  'hemi' - should be either 'lh' for left hemisphere or 'rh' for right hemi
%    {default = both}
%  'meas' - surface measure such as 'thickness', or 'icoarea'
%     Note: for 'icoarea', must be an "ico" subject
%    {default = []}
%  'outstem'  - output file stem (omit extension, hemi)
%    {default = funcname or meas}
%  'infix'  - add extra suffix to outstem before hemi and extension
%    {default = []}
%  'outtype' - output file type ('w', 'mgh', or 'mgz')
%    {default: 'mgh'}
%  'intype' - input file type (e.g. 'mgh', 'analyze', 'bfloat')
%    {default: 'mgh'}
%  'regfile' - register.dat file containing 4x4 registration matrix
%    {default: []}
%  'regmat' - 4x4 registration matrix (ignored if 'regfile' is specified)
%    {default: identity matrix}
%  'inplane' - inplane resolution (mm) (ignored if 'regfile' is specified)
%    {default: 1}
%  'slicethick' - slice thickness (mm) (ignored if 'regfile' is specified)
%    {default: 1}
%  'sphere_flag' - [0|1] whether to sample to icosohedral sphere
%    {default: 0}
%  'projfrac_flag' - [0|1] whether to use projdist (0) or projfract (1)
%    {default: 0}
%  'projdist' - distance (mm) to project along surface vertex normal
%    {default: 1}
%  'projfrac' - fractional distance to project along surface vertex normal
%    relative to cortical thickness
%    {default: 0.5}
%  'projfrac_avg' - vector of [min max del] for averaging multiple samples
%     with mri_surf2surf projfract-avg option
%    If empty, use projfrac instead if projfrac_flag=1
%    {default: []}
%  'projdist_avg' - vector of [min max del] for averaging multiple samples
%     with mri_surf2surf projdist-avg option
%    If empty, use projdist instead
%    {default: []}
%  'smoothsteps' - smoothing steps on surface after painting
%    {default: 0}
%  'sphsmoothsteps' - smoothing steps on spherical surface
%    {default: 0}
%  'subjdir' - subjects directory (override SUBJECTS_DIR environment variable)
%    subjdir/subj should contain the freesurfer subject directory
%    {default = $SUBJECTS_DIR}
%  'surfname' - surface to paint onto
%    {default: white}
%  'mask_midbrain_flag' - [0|1] toggle mask out thalamus, corpus collosum
%    {default: 0}
%  'overwrite_flag' - [0|1] toggle overwrite existing output files
%    {default: 0}
%
% Output:
%   fnames_out: cell array of output file names (e.g. left and right)
%     with multiple steps (e.g. sphere, smoothing, mask), only the final
%     output files are included in fnames_out
%
% created:  10/19/06 by Don Hagler
% last mod: 05/13/10 by Don Hagler
%

%% todo: surf data as input for resampling to sphere, smoothing only
%% todo: optionally resample to T1 before painting

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parse input parameters

fnames_out = [];
if (~mmil_check_nargs(nargin,1)) return; end;
parms = mmil_args2parms(varargin, { ...
  'hemi',[],{'lh','rh'},...
  'hemilist',{'lh','rh'},{'lh','rh'},...
  'outstem',[],[],...
  'outtype','mgh',{'w','mgh','mgz'},...
  'regmat',eye(4),[],...
  'regfile',[],[],...
  'inplane',[],[],...
  'slicethick',[],[],...
  'sphere_flag',false,[false true],...
  'subjdir',[],[],...
  'surfname','white',[],...
  'projdist',1,[-10,10],...
  'projfrac',0.5,[-2,2],...
  'projfrac_flag',false,[false true],...
  'projdist_avg',[],[],...
  'projfrac_avg',[],[],...
  'intype','mgh',{'mgh','bfloat' 'analyze'},...
  'forceflag',false,[false true],...
  'overwrite_flag',false,[false true],...
  'infix',[],[],...
  'smoothsteps',[],[],...
  'sphsmoothsteps',[],[],...
  'meas',[],{'thickness','icoarea'},...
  'mask_midbrain_flag',false,[false true],...
...
  'mask_roinums',[1,5],[],... % 'unknown' and 'corpuscallosum'
});

if parms.overwrite_flag, parms.forceflag = true; end;
if ~isempty(parms.hemi), parms.hemilist = {parms.hemi}; end;

if isempty(parms.subjdir)
  parms.subjdir = getenv('SUBJECTS_DIR');
  if isempty(parms.subjdir)
    error('SUBJECTS_DIR not defined as an environment variable');
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for h=1:length(parms.hemilist)
  hemi = parms.hemilist{h};
  surffile = sprintf('%s/%s/surf/%s.%s',parms.subjdir,subj,hemi,parms.surfname);
  if ~exist(surffile,'file')
    error('surface file %s not found',surffile);
  end
end;
setenv('SUBJECTS_DIR',parms.subjdir);

if ~isempty(parms.regfile) & ~exist(parms.regfile,'file')
  error('regfile %s not found',parms.regfile);
elseif any(size(parms.regmat)~=[4 4])
  error('regmat is wrong size');
end;

if isempty(parms.outstem)
  if isempty(parms.meas)
    [tmp_path,tmp_fstem,tmp_ext,tmp_ver] = fileparts(funcname);
    parms.outstem = [tmp_path,'/',tmp_fstem];
  else
    parms.outstem = sprintf('%s/%s/stats/%s',...
      parms.subjdir,subj,parms.meas);
  end;
end;
if ~strcmp(parms.outstem(1),'/')
  parms.outstem = sprintf('./%s',parms.outstem);
end;
[outdir,tmp_fstem] = fileparts(parms.outstem);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(parms.meas) % i.e. painting from volume to surface
%% todo: and not surf file
  if ~isempty(parms.regfile)
   [parms.regmat,tmp_subj,parms.inplane,parms.slicethick] = fs_read_regdat(parms.regfile);
  end;

  % create tmp register.dat file (in case parms.regfile not specified or subj is different)
  tmp_regfile = sprintf('%s/%s-tmpreg.dat',outdir,hemi);

  fs_write_regdat(tmp_regfile,...
    'M',parms.regmat,...
    'subj',subj,...
    'inplane',parms.inplane,...
    'slicethick',parms.slicethick,...
    'forceflag',1);
end;

for h=1:length(parms.hemilist)
  hemi = parms.hemilist{h};

  % sample from volume to surface
  if isempty(parms.infix)
    prefix_out = parms.outstem;
  else
    prefix_out = sprintf('%s%s',parms.outstem,parms.infix);
  end;
  outfile = sprintf('%s-%s.%s',prefix_out,hemi,parms.outtype);
  fnames_out{h} = outfile;
  if ~exist(outfile,'file') | parms.forceflag
    % create mri_vol2surf cmd string
    if ~isempty(parms.meas)
      fprintf('%s: painting cortical %s\n',mfilename,parms.meas);
      cmd = sprintf('setenv SUBJECTS_DIR %s; mri_surf2surf --srcsubject %s --hemi %s',...
        parms.subjdir,subj,hemi);
      switch parms.meas
        case 'thickness'
          cmd = sprintf('%s --srcsurfval thickness --src_type curv',cmd);
        case 'icoarea'
          cmd = sprintf('%s --sval %s/%s/surf/%s.white.avg.area.mgh',...
            cmd,parms.subjdir,subj,hemi);
      end;
      cmd = sprintf('%s --tval %s --trgsubject %s',cmd,outfile,subj);
    else
      fprintf('%s: painting func volume from %s for hemi %s\n',mfilename,funcname,hemi);
      cmd = sprintf('setenv SUBJECTS_DIR %s; mri_vol2surf --src %s --src_type %s --srcreg %s --hemi %s',...
        parms.subjdir,funcname,parms.intype,tmp_regfile,hemi);
      cmd = sprintf('%s --surf %s --out %s --out_type %s --trgsubject %s',...
        cmd,parms.surfname,outfile,parms.outtype,subj);
      if ~parms.projfrac_flag
        if ~isempty(parms.projdist_avg)
          cmd = sprintf('%s --projdist-avg %s',...
            cmd,sprintf('%0.3f ',parms.projdist_avg));
        else
          cmd = sprintf('%s --projdist %0.3f',...
            cmd,parms.projdist);
        end;
      else
        if ~isempty(parms.projfrac_avg)
          cmd = sprintf('%s --projfrac-avg %s',...
            cmd,sprintf('%0.3f ',parms.projfrac_avg));
        else
          cmd = sprintf('%s --projfrac %0.3f',...
            cmd,parms.projfrac);
        end;
      end;
    end;
    cmd = sprintf('%s --noreshape',cmd);

    % run cmd
    [status,result]=unix(cmd);
    if status
      error('cmd %s failed:\n%s',cmd,result);
    end;
  end;

  % mask out midbrain
  if parms.mask_midbrain_flag
    prefix_in = prefix_out;
    prefix_out = sprintf('%s-mbmask',prefix_in);
    infile = sprintf('%s-%s.%s',prefix_in,hemi,parms.outtype);
    outfile = sprintf('%s-%s.%s',prefix_out,hemi,parms.outtype);
    fnames_out{h} = outfile;
%% todo: if parms.outtype is w, then need to load file and mask surfstats
    fs_mask_surfmgh_with_aparc(subj,hemi,infile,outfile,parms.subjdir,mask_roinums);
  end;

  % smooth on surface
  if parms.smoothsteps
    prefix_in = prefix_out;
    prefix_out = sprintf('%s-sm%d',prefix_in,parms.smoothsteps);
    infile = sprintf('%s-%s.%s',prefix_in,hemi,parms.outtype);
    outfile = sprintf('%s-%s.%s',prefix_out,hemi,parms.outtype);
    fnames_out{h} = outfile;
    if ~exist(outfile,'file') | parms.forceflag
      cmd = sprintf('setenv SUBJECTS_DIR %s; mri_surf2surf --s %s --hemi %s',...
        parms.subjdir,subj,hemi);
      cmd = sprintf('%s --sval %s --tval %s',...
        cmd,infile,outfile);
      cmd = sprintf('%s --sfmt %s --nsmooth-out %d',...
        cmd,parms.outtype,parms.smoothsteps);
      cmd = sprintf('%s --noreshape',cmd);
      % run cmd
      [status,result]=unix(cmd);
      if status
        error('cmd %s failed:\n%s',cmd,result);
      end;
    end;
  end;

  % sample to sphere
  if parms.sphere_flag
    prefix_in = prefix_out;
    if parms.sphsmoothsteps
      prefix_out = sprintf('%s-sphere-sm%d',prefix_in,parms.sphsmoothsteps);
    else
      prefix_out = sprintf('%s-sphere',prefix_in);
    end;    
    infile = sprintf('%s-%s.%s',prefix_in,hemi,parms.outtype);
    outfile = sprintf('%s-%s.%s',prefix_out,hemi,parms.outtype);
    fnames_out{h} = outfile;
    if ~exist(outfile,'file') | parms.forceflag
      cmd = sprintf('setenv SUBJECTS_DIR %s; mri_surf2surf --srcsubject %s --trgsubject ico --hemi %s',...
        parms.subjdir,subj,hemi);
      cmd = sprintf('%s  --trgicoorder 7 --sval %s --tval %s',...
        cmd,infile,outfile);
      cmd = sprintf('%s --sfmt %s --nsmooth-out %d',...
        cmd,parms.outtype,parms.sphsmoothsteps);
      cmd = sprintf('%s --noreshape',cmd);
      % run cmd
      [status,result]=unix(cmd);
      if status
        error('cmd %s failed:\n%s',cmd,result);
      end;
    end;
  end;
end;

if exist('tmp_regfile','var') & exist(tmp_regfile,'file')
  delete(tmp_regfile);
end;
