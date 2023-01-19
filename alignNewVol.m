function newVolOut = alignNewVol(volIn)
volIn = permute(volIn,[3 2 1]);
voln = zeros(size(volIn));
for k = 1:size(voln,2)
    voln(:,:,end-k+1) = volIn(:,:,k);
end
volIn = voln; clear voln;
newVolOut = volIn;
end

