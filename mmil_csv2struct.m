function info = mmil_csv2struct(fname)
%function info = mmil_csv2struct(fname)
%
% Created:  02/02/09 by Don Hagler
% Last Mod: 05/24/10 by Cooper Roddey
%

if ~mmil_check_nargs(nargin,1), return; end;
if ~exist(fname,'file'), error('file %s not found',fname); end;

% load comma separated value text file
raw_info = mmil_readtext(fname);

% convert cell array to struct array
fieldnames = regexprep(raw_info(1,:),' ','_');
fieldnames = regexprep(fieldnames,'-','_');
info = cell2struct(raw_info(2:end,:),fieldnames,2);

