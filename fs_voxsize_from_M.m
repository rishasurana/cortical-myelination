function voxsize = fs_voxsize_from_M(M)
%function voxsize = fs_voxsize_from_M(M)
%
% Created:  05/05/10 by Don Hagler
% Last Mod: 05/05/10 by Don Hagler
%

voxsize=[];

if (~mmil_check_nargs(nargin, 1)), return; end;

if any(size(M)~=[4,4])
  error('M matrix must be 4x4');
end;

voxsize = sqrt(sum(M(1:3,1:3).^2,1));

