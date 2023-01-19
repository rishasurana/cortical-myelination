function [ op1,op2 ] = MatchMatricesDim( ip1,ip2 )
%MatchMatricesDim First image is target matrix 
%   Detailed explanation goes here
[x1,y1,z1] = size(ip1);
[x2,y2,z2] = size(ip2);


max1 = max([x1,y1,z1]);
max2 = max([x2,y2,z2]);

maxt = max([max1 max2]);

dx = maxt-x2; ndx = maxt-x1;
dy = maxt-y2; ndy = maxt-y1;
dz= maxt-z2; ndz = maxt-z1;

%str="second Matrix is smaller";
if dx<0, dx=0; end  
if dy<0, dy=0; end 
if dz<0, dz=0; end
if ndx<0, ndx=0; end  
if ndy<0, ndy=0; end 
if ndz<0, ndz=0; end
op1 = ip1;

if ndx>0 | ndy>0 | ndz>0
    D1 = padarray(ip1, [ceil(ndx/2) ceil(ndy/2) ceil(ndz/2)],0,'both');
    op1 = D1;
end
D2 = padarray(ip2,[round(dx/2) round(dy/2) round(dz/2)],0,'both');
op2 = D2;

%Balancing the last slice for ones with odd dx,dy,dz
[x1,y1,z1,k1] = size(op1);
[x2,y2,z2] = size(op2);


max1 = max([x1,y1,z1]);
max2 = max([x2,y2,z2]);
maxt = max([max1 max2]);

dx = maxt-x2; ndx = maxt-x1;
dy = maxt-y2; ndy = maxt-y1;
dz= maxt-z2; ndz = maxt-z1;
%str="second Matrix is smaller";
if dx<0, dx=0; end  
if dy<0, dy=0; end 
if dz<0, dz=0; end
if ndx<0, ndx=0; end  
if ndy<0, ndy=0; end 
if ndz<0, ndz=0; end
if ndx>0 | ndy>0 | ndz>0
    D1 = padarray(op1, [ceil(ndx/2) ceil(ndy/2) ceil(ndz/2)],0,'post');
    op1 = D1;
end
if dx>0 | dy>0 | dz>0
    D2 = padarray(op2,[ceil(dx/2) ceil(dy/2) ceil(dz/2)],0,'post');
    op2 = D2;
end
end

