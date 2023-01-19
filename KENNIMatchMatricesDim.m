function [ op1,op2 ] = KENNIMatchMatricesDim( d,fip1,fip2 )
%KENNIMatchMatricesDim Compares the dimensions of the input files and 
%sends to MatchMatricesDim accordingly.
%   input is file path (fip1 and fip2) for nii files, and d is directory for the filesand output is also nii file.
cd(d);
d = dir(fip1);
ip1= load_nii(d.name);

d = dir(fip2);
 ip2 = load_nii(d.name);

 ip1 = ip1.img;
 ip2 = ip2.img;
[x1,y1,z1] = size(ip1);
[x2,y2,z2] = size(ip2);


size(ip1)
size(ip2)

dx = x1-x2;
dy = y1-y2;
dz= z1-z2;

if dx<0, [op1,op2] = MatchMatricesDim(ip2,ip1);
else
    [op1,op2] = MatchMatricesDim(ip1,ip2);
end
size(op1)
size(op2)
%saving the output matrices as nii files.
save_nii(make_nii(op1),'op1.nii');
save_nii(make_nii(op2),'op2.nii');

end

