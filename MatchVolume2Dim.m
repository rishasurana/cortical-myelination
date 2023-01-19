function [ op1 ] = MatchVolume2Dim( ip1, VolSize)
%MatchMatricesDim First argument is Volume target matrix
% [ op1 ] = MatchVolume2Dim( ip1,VolSize)

%xyzbb = BoundingBoxforMatrix(ip1);

[x1,y1,z1] = size(ip1);
x2=VolSize(1); y2=VolSize(2); z2=VolSize(3);

fprintf("Size of input volume : %d %d %d. Size of target : %d %d %d \n",x1,y1, z1, x2,y2,z2);
%% Balances equal number of 0 slices on both sides of the volume
dx = x1-x2; ndx = x2-x1;
dy = y1-y2; ndy = y2-y1;
dz= z1-z2; ndz = z2-z1;

op1 = ip1;
if ndx>=0
    op1 = padarray(ip1, [floor(ndx/2) 0 0],0,'both');
else
    op1 = ip1(ceil(dx/2) : x1-ceil(dx/2),: ,:); 
end
if ndy>=0
    op1 = padarray(op1, [0 floor(ndy/2) 0],0,'both');     
else
    op1 = op1(:,ceil(dy/2) : y1-ceil(dy/2),:);  
end
if ndz>=0
    op1 = padarray(op1, [0 0 floor(ndz/2)],0,'both');     
else
    op1 = op1(:,:,ceil(dz/2) : z1-ceil(dz/2));  
end

%% If there are odd number of slices, adds one slice to the volume
[x1,y1,z1] = size(op1);

dx = x1-x2; ndx = x2-x1;
dy = y1-y2; ndy = y2-y1;
dz= z1-z2; ndz = z2-z1;

if ndx>=0
    op1 = padarray(op1, [ndx 0 0],0,'pre');  
else
    op1 = op1(2: x1,: ,:); 
end
if ndy>=0
    op1 = padarray(op1, [0 ndy 0],0,'pre');     
else
    op1 = op1(:,2: y1,:); 
end
if ndz>=0
    op1 = padarray(op1, [0 0 ndz],0,'pre'); 
else
    op1 = op1(:,:,2: z1); 
end

end
