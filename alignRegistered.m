function niiOut = alignRegistered(niiIn)

% this will be cleaned 
[opp1, opp2] = KENNIMatchMatricesDim3(niiIn.img,zeros(256,256,256));
T2 = opp1; %(1:end-1,1:end-1,1:end-1);

T2 = permute(T2, [1,3,2]);

voln = zeros(size(T2));
for k = 1:size(voln,2)
    voln(:,:,end-k+1) = T2(:,:,k);
end
T2 = voln; clear voln;

niiOut = T2;
end