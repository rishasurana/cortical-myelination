function [adjustedniiT1, adjustedniiT2, adjustedgm, adjustedorig] = alignImages(niiT1, niiT2, gm, orig)
vol = gm;
volb = orig;
vol  = permute(vol ,[3 1 2]); % convert to RAS coordinate system
volb = permute(volb,[3 1 2]);
nii = niiT1;
nii2 = niiT2;

% this will be cleaned 
[op1,op2] = KENNIMatchMatricesDim3(nii.img,zeros(256,256,256));
[opp1, opp2] = KENNIMatchMatricesDim3(nii2.img,zeros(256,256,256));
T1 = op1; %(1:end-1,1:end-1,1:end-1);
T2 = opp1; %(1:end-1,1:end-1,1:end-1);

T1  = permute(T1 ,[3 1 2]); % convert to RAS coordinate system
T2 = permute(T2,[3 1 2]);
T1  = permute(T1 ,[3 1 2]); % convert to RAS coordinate system
T2 = permute(T2,[3 1 2]);

% change chirality for T2 volume
voln = zeros(size(T2));
for k = 1:size(voln,2)
    voln(:,end-k+1,:) = T2(:,k,:);
end
T2 = voln; clear voln;

voln = zeros(size(T1));
for k = 1:size(voln,2)
    voln(:,end-k+1,:) = T1(:,k,:);
end
T1 = voln; clear voln;

% rotate around z axis by 180 degrees
voln = zeros(size(T2));
for k = 1:size(voln,3)
    voln(:,:,k) = rot90(rot90(T2(:,:,k)));
end
T2 = voln; clear voln;

voln = zeros(size(T1));
for k = 1:size(voln,3)
    voln(:,:,k) = rot90(rot90(T1(:,:,k)));
end
T1 = voln; clear voln;

% [optimizer, metric] = imregconfig('multimodal');
% metric.NumberOfHistogramBins = 300;
% optimizer.MaximumIterations = 1200;
% optimizer.Epsilon = 0.5e-08;
% [T2moved,Rreg] = imregister(T2, volb, 'affine', optimizer, metric);
% [T1moved,Rreg] = imregister(T1, volb, 'affine', optimizer, metric);
T2moved = T2;
T1moved = T1;
adjustedniiT1 = T1moved;
adjustedniiT2 = T2moved;
adjustedgm = vol; 
adjustedorig = volb;
end


