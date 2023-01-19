function newVolOut = controlT2Align(volIn)
% Intended to change RIA to LIA
voln = zeros(size(volIn));
for k = 1:size(voln,2)
    voln(end-k+1,:,:) = volIn(k,:,:); %LIA
end
volIn = voln; clear voln;

newVolOut = volIn;
end

