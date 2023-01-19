% A Irimia
% 2019 07 19
function dicom2nii(indir,outfile)

dr = dir(indir);
for k = length(dr):-1:3
    name = dr(k).name;
    if length(name) < 5, continue; end
    f = strfind(name,'.');
    ext  = name(f+1:end);
    if strcmp(ext,'dcm')
        dr2(k-2) = dr(k);
    end
end
dr = dr2; clear dr2;
for k = 1:length(dr)
    info = dicominfo([indir '/' dr(k).name]);
    loc(k) = info.SliceLocation;
    vol(:,:,k) = dicomread([indir '/' dr(k).name]);
end
loci = sort(loc,'ascend');
vol2 = zeros(size(vol));
for k = 1:length(dr)
    f = find(loc == loci(k));
    vol2(:,:,k) = vol(:,:,f);
end
vol = vol2; clear vol2;
nii = make_nii(vol, [info.PixelSpacing' info.SliceThickness]);
save_nii(nii,outfile);

return