function [status,result]=mmil_unix(cmd)
%function [status,result]=mmil_unix(cmd)
%
% Purpose: execute a unix command
%   moves MATLAB paths to bottom of LD_LIBRARY_PATH stack, to simulate
%   better non-MATLAB shell environment.
%
% Required Input:
%   cmd : UNIX command-line to execute.
%
% Output:
%   status: true/false value indicating if error occurred
%   result: stdout/stderr output from running cmd
%
% See also: unix
%
% Created:  08/01/07 by Ben Cipollini
% Last Mod: 08/19/09 by Don Hagler
%

varargout={};
if ~exist('outtype','var'), outtype = []; end;
if ~exist('verbose','var') | isempty(verbose), verbose = 0; end;

% push MATLAB to the back of the path stack.
path = getenv('LD_LIBRARY_PATH');
paths = mmil_splitstr(path,':');
mat_paths = find(~mmil_isempty2(regexp(paths,'matlab'),true));
non_mat_paths = setdiff(1:length(paths),mat_paths);

newpaths = { paths{non_mat_paths} };
if (isempty(newpaths))
  newpath  = '';
else
  newpath  = [sprintf('%s:',newpaths{1:end-1}) newpaths{end}];
end;

% run command with modified LD_LIBRARY_PATH
setenv('LD_LIBRARY_PATH',newpath);
[status,result] = unix(cmd);
if verbose, disp(result); end;
setenv('LD_LIBRARY_PATH',path);

% return the appropriate type
if isempty(outtype)
  varargout{end+1}=status;
  varargout{end+1}=result;
elseif strcmp(outtype, 'status')
  varargout{end+1}=status;
else
  varargout{end+1}=result;
end;
