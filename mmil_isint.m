function res=mmil_isint(v)
%function res=mmil_isint(v)
%
% Created:  04/01/09 by Don Hagler
% Last Mod: 04/01/09 by Don Hagler
%
%  copied from Ziad Saad's isint
%

fv = fix(v);
df = v - fv;
if (~df)
  res = 1;
else
  res = 0;
end;

