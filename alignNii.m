function niiOut = alignNii(niiIn)

% this will be cleaned 
[opp1, opp2] = KENNIMatchMatricesDim3(niiIn.img,zeros(256,256,256));
T2 = opp1; %(1:end-1,1:end-1,1:end-1);
T2 = permute(T2,[3 1 2]);
T2 = permute(T2,[3 1 2]);

% change chirality for T2 volume
voln = zeros(size(T2));
for k = 1:size(voln,2)
    voln(:,end-k+1,:) = T2(:,k,:);
end
T2 = voln; clear voln;

% rotate around z axis by 180 degrees
voln = zeros(size(T2));
for k = 1:size(voln,3)
    voln(:,:,k) = rot90(rot90(T2(:,:,k)));
end
T2 = voln; clear voln;

niiOut = T2;
end

