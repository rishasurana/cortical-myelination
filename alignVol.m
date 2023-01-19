function [volOut] = alignVol(volIn)
vol = volIn;
volOut  = permute(vol ,[3 1 2]); % convert to RAS coordinate system
end

