function intensityMap2 = weightedIntensity2(v, vn, vx, i)

adjustedWhite = v;
counter = 0;
a = 5;
tic
avgWeightedIntensity = zeros(length(v),1);
finalmatrix = inv(bob.tkrvox2ras);

for s = 1:length(v)
    pt(:,1) = rh.vertices(:,2) + 128.5;
    pt(:,2) = 128.5 - rh.vertices(:,1);
    pt(:,3) = 128.5 - rh.vertices(:,3);
    point = [0, 0, 0, 1];
    point(1) = rh.vertices(p,2);
    point(2) = rh.vertices(p,3);
    point(3) = rh.vertices(p,1);
    point = reshape(point, [4,1]);
    finalPoint(p,:) = finalmatrix*point;
    finalPoint(p,1) = 256 - finalPoint(p,1);
    pt = finalPoint;
    
    xROI = round((pt(1)-a:1:pt(1)+a));
    yROI = round((pt(2)-a:1:pt(2)+a));
    zROI = round((pt(3)-a:1:pt(3)+a));
    ROI = i(xROI, yROI, zROI);
    [xValu,yValu,zValu] = ind2sub(size(ROI),find(ROI>0));
    xValu = (xValu - (a+1)) + round(pt(1));
    yValu = (yValu - (a+1)) + round(pt(2));
    zValu = (zValu - (a+1)) + round(pt(3));
    locations = horzcat(xValu, yValu, zValu);
    if ~isnan(locations)
        distances = point_to_line_distance(locations, pt(1,:), pt(1,:)+vn(s, :));
        inRange = find((distances < sqrt(0.5)) & (distances > 0));
        inRangeVals = distances(inRange);
        inverseInRangeVals = 1./inRangeVals;
        totalWeight = sum(inverseInRangeVals);
        inRangeLocations = locations(inRange,:);
        intensities = zeros(length(inRange),1);
        for z = 1:length(inRange)
            intensities(z) = i(inRangeLocations(z,1), inRangeLocations(z,2), inRangeLocations(z,3));
        end
        weightedIntensities = intensities .* inverseInRangeVals;
        finalIntensity(s)  = sum(weightedIntensities)/totalWeight;
    end
    counter = counter + 1;
    hold on
    if counter == 100
    plot3(pt(1), pt(2), pt(3), 'o');
    counter = 0;
    end
    
end
toc

bb = finalIntensity;
f = find(isnan(finalIntensity)); bb(f) = 0;

intensityMap2 = bb;
return
end
