% v  is N x 3 and contains the WM mesh vertex coordinates
% vn is N x 3 and contains the normal vectors wrt the former
% vx is N x 3 and contains the GM voxel indices in a 256^3 array
% i  is 256^3 and contains the T1/T2 ratio
% v = lh.vertices;
% vn = newVectors;
% vx = xw; % find(GMlb > 0); GMlb = vol;  GMlb(GMlb <  11000) = 0;  GMlb(GMlb >= 11000) = 1;  GMlb = logical(GMlb);
% i = GMT1;

function intensityMap = weightedIntensity(v, vn, vx, i, pial)

adjustedWhite = v;
counter = 0;
finalIntensity = zeros(length(v),1);
thr = 10;%sqrt(0.5) * 2;
pialSurf = pial.vertices;

pialSurfPoints(:,1) = pialSurf(:,2) + 128.5;
pialSurfPoints(:,2) = 128.5 - pialSurf(:,1);
pialSurfPoints(:,3) = 128.5 - pialSurf(:,3);

for s = 1:length(v)
    pt2 = adjustedWhite(s, :);
    pt(:,1) = pt2(:,2) + 128.5;
    pt(:,2) = 128.5 - pt2(:,1);
    pt(:,3) = 128.5 - pt2(:,3);
    a = ceil(vn(2, s));
    pialPoint = pialSurfPoints(vn(1,s), :);
    
    xROI = round((pt(1)-a:1:pt(1)+a));
    yROI = round((pt(2)-a:1:pt(2)+a));
    zROI = round((pt(3)-a:1:pt(3)+a));
    ROI = i(xROI, yROI, zROI);
    [xValu,yValu,zValu] = ind2sub(size(ROI),find(~isnan(ROI)));
    xValu = (xValu - (a+1)) + round(pt(1));
    yValu = (yValu - (a+1)) + round(pt(2));
    zValu = (zValu - (a+1)) + round(pt(3));
    locations = horzcat(xValu, yValu, zValu);
    
    
    if ~isnan(locations)
        distances = point_to_line_distance(locations, pt(1,:), pialPoint);
        inRange = find((distances < thr) & (distances > 0));
        %inRangeVals = distances(inRange);
        %inverseInRangeVals = 1./inRangeVals;
        %totalWeight = sum(inverseInRangeVals);
        inRangeLocations = locations(inRange,:);
        intensities = zeros(length(inRange),1);
        for z = 1:length(inRange)
            intensities(z) = i(inRangeLocations(z,1), inRangeLocations(z,2), inRangeLocations(z,3));
        end
        %weightedIntensities = intensities .* inverseInRangeVals;
        finalIntensity(s)  = sum(intensities)/length(intensities);
%         weightedIntensities = sum(intensities)/length(intensities);
%         finalIntensity(s)  = weightedIntensities;
    end
    counter = counter + 1;
    hold on
end


bb = finalIntensity;
f = find(isnan(finalIntensity)); bb(f) = 0;


intensityMap = bb;
return
end
