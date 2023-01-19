function mmil_write_tags(fid,tags,parms)
%function mmil_write_tags(fid,tags,parms)
%
% Purpose: Help create matlab script for batch processing
%   Writes ('key',value) pairs to open file specified by fid
%   Handles multiple data types, including vectors and cell arrays
%
% Created:  05/17/09 by Don Hagler
% Last Mod: 11/18/09 by Don Hagler
%

for t=1:length(tags)
  if isfield(parms,tags{t})
    tmp = getfield(parms,tags{t});
  else
    tmp = [];
  end;
  if isfloat(tmp)
    fprintf(fid,'  ''%s'',',tags{t});
    if length(tmp)~=1, fprintf(fid,'['); end;
    for i=1:length(tmp)
      if isinf(tmp(i))
        if sign(tmp(i))<0
          fprintf(fid,'-Inf');
        else
          fprintf(fid,'Inf');
        end;
      elseif mmil_isint(tmp(i))
        fprintf(fid,'%d ',tmp(i));
      else
        fprintf(fid,'%0.3f ',tmp(i));
      end;
    end;
    if length(tmp)~=1, fprintf(fid,']'); end;
  elseif isnumeric(tmp) | islogical(tmp)
    fprintf(fid,'  ''%s'',[%s]',tags{t},sprintf('%d ',tmp));
  elseif ischar(tmp)
    fprintf(fid,'  ''%s'',''%s''',tags{t},tmp);
  elseif ~isempty(tmp) & iscell(tmp)
      tmp2 = '{';
      for k=1:length(tmp)
        tmp2 = [tmp2 ' ''' tmp{k} ''''];
      end;
      tmp2 = [tmp2 '}'];
      fprintf(fid,'  ''%s'',%s',...
        tags{t},tmp2);
  end;
  if t<length(tags)
    fprintf(fid,',...\n');
  end;
end;
