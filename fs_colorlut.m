function [roicodes, roinames, rgbv] = fs_colorlut(fname)
% [roicodes roinames rgb] = fs_colorlut(fname)
%
% Reads a freesurfer color lookup table. By default
% reads $FREESURFER_HOME/FreeSurferColorLUT.txt.
%
%
% roicodes: vector of numeric ROI codes
% roinames: cell array of ROI names
% rgbv: matrix of rgb values for each ROI
%
% Created:  03/03/10 by Don Hagler
% Last Mod: 03/03/10 by Don Hagler
%

roicodes = [];
roinames = [];
rgbv = [];

if ~exist('fname','var')
  [roicodes,tmp_roinames,rgbv] = fs_read_fscolorlut;
else
  [roicodes,tmp_roinames,rgbv] = fs_read_fscolorlut(fname);
end;

nrois = length(roicodes);
roinames = cell(nrois,1);
for i=1:nrois
  roinames{i} = deblank(tmp_roinames(i,:));
end;
