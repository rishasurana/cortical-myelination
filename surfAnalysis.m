function results = surfAnalysis(surfStruct)

normalVectorforFace = zeros(length(surfStruct.faces), 3);
locationOfVectorforFace = zeros(length(surfStruct.faces), 3);
sizeOfFace = zeros(length(surfStruct.faces), 1);
for k = 1:length(surfStruct.faces)
    pointsOfInterest = surfStruct.faces(k,:);
    locationOfPoint1 = surfStruct.vertices(pointsOfInterest(1),:);
    locationOfPoint2 = surfStruct.vertices(pointsOfInterest(2),:);
    locationOfPoint3 = surfStruct.vertices(pointsOfInterest(3),:);
    V0V1 = locationOfPoint2 - locationOfPoint1;
    V0V2 = locationOfPoint3 - locationOfPoint1;
    normalVectorforFace(k,:) = cross(V0V1, V0V2);
    normalVectorforFace(k,:) = normalVectorforFace(k,:)/norm(normalVectorforFace(k,:));
    locationOfVectorforFace(k,1) = (locationOfPoint1(1) + locationOfPoint2(1) + locationOfPoint3(1))/3;
    locationOfVectorforFace(k,2) = (locationOfPoint1(2) + locationOfPoint2(2) + locationOfPoint3(2))/3;
    locationOfVectorforFace(k,3) = (locationOfPoint1(3) + locationOfPoint2(3) + locationOfPoint3(3))/3;
    sizeOfFace(k) = 1/2*norm(cross(locationOfPoint2-locationOfPoint1,locationOfPoint3-locationOfPoint1));
end
vectorVertices = zeros(length(surfStruct.vertices),3);
for k = 1:length(surfStruct.vertices)
    connectedFaces1 = find(surfStruct.faces(:,1)==k);
    connectedFaces2 = find(surfStruct.faces(:,2)==k);
    connectedFaces3 = find(surfStruct.faces(:,3)==k);
    connectedFaces = vertcat(connectedFaces1, connectedFaces2, connectedFaces3);
    totalSize = 0;
    for j = 1:length(connectedFaces)
       totalSize = totalSize + sizeOfFace(connectedFaces(j));
    end
    vector = [0 0 0];
    for j = 1:length(connectedFaces)
        vector = vector + (sizeOfFace(connectedFaces(j)) .* normalVectorforFace(connectedFaces(j),:)./totalSize);
    end
    vectorVertices(k,:) = vector;
end
results = zeros(length(vectorVertices),3);
for r = 1:length(vectorVertices)
   a = vectorVertices(r, 1);
   b = vectorVertices(r, 2);
   c = vectorVertices(r, 3);
   d = min([abs(a), abs(b), abs(c)]);
   factor = 10/d;
   results(r, :) = [factor*a, factor*b, factor*c];
   if isinf(factor*a)
       results(r,:) = [10, 0, 0];
   end
   if isinf(factor*b)
       results(r,:) = [0, 10, 0];
   end
   if isinf(factor*c)
       results(r,:) = [0, 0, 10];
   end
end

return
end


