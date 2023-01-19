% Designed to change a volume oriented in RAS to RIA
function newVolOut = alignNewVolRAS(volIn)
volIn = permute(volIn,[1 3 2]); %RSA
voln = zeros(size(volIn));
for k = 1:size(voln,2)
    voln(:,end-k+1,:) = volIn(:,k,:); %RIA
end
volIn = voln; clear voln;
newVolOut = volIn;
end

