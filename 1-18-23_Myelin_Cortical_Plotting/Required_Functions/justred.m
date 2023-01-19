function c = justred(m)
%JUSTRED    Shades of red color map
%   JUSTRED(M), is an M-by-3 matrix that defines a colormap.
%   The colors begin with WHITE, then range through shades of RED
%   JUSTRED, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(JUSTRED)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.
if nargin < 1, m = size(get(gcf,'colormap'),1); close; end
% From [1 1 1] to [1 0 0];
m1 = m;
r = (0:m1-1)'/max(m1-1,1);
g = flipud(r);
b = flipud(r);
r = ones(m,1);

c = [r g b];
