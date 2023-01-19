function mmil_write_csv(fname,data,varargin)
%
%function mmil_write_csv(fname,data,'key1',value1,...)
%
% Required Input:
%  fname: output file name
%  data: 2D data matrix (can be a cell array of numbers and/or strings)
%
% Optional arguments:
%   'row_labels': cell array of row labels
%     {default: []}
%   'col_labels': cell array of column labels
%     {default: []}
%   'separator': separator between columns
%     {default: ','}
%   'firstcol_label': label for first column
%
% Created:  05/23/09 by Don Hagler
% Last Mod: 05/26/10 by Cooper Roddey
%   

if (~mmil_check_nargs(nargin,2)) return; end;

parms = mmil_args2parms(varargin, { ...
   'row_labels',[],[],...
   'col_labels',[],[],...
   'separator',',',[],...
   'firstcol_label',[],[],...
});

%if ~exist('row_labels','var'), row_labels = []; end;
%if ~exist('col_labels','var'), col_labels = []; end;
%if ~exist('separator','var') | isempty(separator), separator = ','; end
%if ~exist('firstcol_label','var') | isempty(firstcol_label)
%  firstcol_label = 'SubjID';
%end

row_labels = parms.row_labels;
col_labels = parms.col_labels;
separator = parms.separator;
firstcol_label = parms.firstcol_label;

[nrows,ncols] = size(data);

if ~isempty(row_labels) & length(row_labels) ~= nrows
  error('number of row labels (%d) does not match first dim of data (%d)',...
    length(row_labels),nrows);
end;
if ~isempty(col_labels) & length(col_labels) ~= ncols
  error('number of col labels (%d) does not match first dim of data (%d)',...
    length(col_labels),ncols);
end;

data_is_cellarray = iscell(data);

fid = fopen(fname,'w');
if ~isempty(col_labels)
  if ~isempty(row_labels)
    fprintf(fid,'%s%s',firstcol_label,separator);
  end;
  for j=1:ncols
    if j>1, fprintf(fid,'%s',separator); end
    fprintf(fid,'"%s"',col_labels{j});
  end;
  fprintf(fid,'\n');
end;
for i = 1:nrows
  if ~isempty(row_labels)
    fprintf(fid,'%s%s',row_labels{i},separator);
  end;
  for j = 1:ncols
    if j>1, fprintf(fid,'%s',separator); end
    if data_is_cellarray, tvar = data{i,j};
    else  tvar = data(i,j);
    end
    if ischar(tvar)
       fprintf(fid,'"%s"',tvar);
    elseif isnumeric(tvar) & isscalar(tvar),
       fprintf(fid,'%f',tvar);
    else
       error(sprintf('Element {%d,%d} of input data matrix is invalid.',i,j));
    end
  end
  fprintf(fid,'\n');
end
fclose(fid);

