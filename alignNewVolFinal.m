function newVolOut = alignNewVolFinal(volIn)
volIn = permute(volIn,[3 1 2]);
% LIA -> ALI
% voln = zeros(size(volIn));
% for k = 1:size(voln,2)
%     voln(:,:,end-k+1) = volIn(:,:,k);
% end
% volIn = voln; clear voln;

newVolOut = volIn;
end