val = 130;
val2 = 100;
viewer = changeRatio2(:,:,130);

T = changeRatio2;
T21 = T(val2,:,:);
T21 = reshape(T21, [256,256]);
T22 = T(:,val2,:);
T22 = reshape(T22, [256,256]);
T23 = T(:,:,val2);

other = TP1BrainRegistered;
other3 = other(:,:,val);
other1 = other(val,:,:);
other1 = reshape(other1, [256,256]);
other2 = other(:,val,:);
other2 = reshape(other2, [256,256]);

others = TP1BrainRegisteredT2;
others3 = others(:,:,val);
others1 = others(val,:,:);
others1 = reshape(others1, [256,256]);
others2 = others(:,val,:);
others2 = reshape(others2, [256,256]);

figure
subplot(3,3,1)
imagesc(T21); xlabel('y'); ylabel('z');
subplot(3,3,2)
imagesc(T22); xlabel('x'); ylabel('z');
subplot(3,3,3)
imagesc(T23); xlabel('x'); ylabel('y');
subplot(3,3,4)
imagesc(other1);
subplot(3,3,5)
imagesc(other2);
subplot(3,3,6)
imagesc(other3);

subplot(3,3,7)
imagesc(others1);
subplot(3,3,8)
imagesc(others2);
subplot(3,3,9)
imagesc(others3);

[vol,  M , mr_parms , volsz ] = fs_load_mgh(['/media/sf_VMShared/Reconer/reconFinished/' subject '/TP2/fs/mri/aparc.a2009s+aseg']);
vole = alignVol(vol);

GMlb = vole;
GMlb(GMlb <  11000) = 0;
GMlb(GMlb >= 11000) = 1;
GMlb = logical(GMlb);
xw = find(GMlb > 0);
%[x,y,z] = meshgrid(127.5:-1:-127.5,-127.5:127.5,127.5:-1:-127.5);
[x,y,z] = meshgrid(256:-1:1,1:256,256:-1:1);



rh = fs_read_surf(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/surf/rh.white']);
bob = MRIread(['/media/sf_VMShared/SeanControls2/ADNI/' subject '/fs/mri/aparc.a2009s+aseg.mgz']);


finalmatrix = inv(bob.tkrvox2ras);
finalPoint = zeros(length(lh.vertices), 4);
finalPoint2 = zeros(length(lh.vertices), 3);
for p = 1:length(lh.vertices)
    pts(:,1) = lh.vertices(:,2) + 128.5;
    pts(:,2) = 128.5 - lh.vertices(:,1);
    pts(:,3) = 128.5 - lh.vertices(:,3);
    point = [0, 0, 0, 1];
    point(1) = lh.vertices(p,2);
    point(2) = lh.vertices(p,3);
    point(3) = lh.vertices(p,1);
    point = reshape(point, [4,1]);
    finalPoint(p,:) = finalmatrix*point;
    finalPoint(p,1) = 256 - finalPoint(p,1);
%     finalPoint2(p,1) =  finalPoint(p,2);
%     finalPoint2(p,2) =  finalPoint(p,1);
%     finalPoint2(p,3) =  finalPoint(p,3);
end
[xValu,yValu,zValu] = ind2sub(size(vole), xw);

figure
hold on
f = 50;
plot3(xValu(1:f:end),yValu(1:f:end),zValu(1:f:end),'.r');     %Gray Matter

%plot3(pt(1:f:end,1),pt(1:f:end,2),pt(1:f:end,3),'.k');  %White Matter
plot3(finalPoint(1:f:end,1),finalPoint(1:f:end,2),finalPoint(1:f:end,3),'.k');  %White Matter
%plot3(rh.vertices(1:f:end,1)-8.863,rh.vertices(1:f:end,2)+22.409,rh.vertices(1:f:end,3)+15.398,'.k');  %White Matter
%plot3(rh.vertices(1:f:end,1),rh.vertices(1:f:end,2),rh.vertices(1:f:end,3),'.k');  %White Matter

xlabel('x');
ylabel('y');












        f = 10;
        figure; hold on;
        pt(:,1) = lh.vertices(:,2) + 128.5;
        pt(:,2) = 128.5 - lh.vertices(:,1);
        pt(:,3) = 128.5 - lh.vertices(:,3);
        
        pt2(:,1) = rh.vertices(:,2) +128.5;
        pt2(:,2) = 128.5 - rh.vertices(:,1);
        pt2(:,3) = 128.5 - rh.vertices(:,3);
        figure; hold on;
        plot3(pt(1:f:end,1),pt(1:f:end,2),pt(1:f:end,3),'.r');   %White Matter
        plot3(pt2(1:f:end,1),pt2(1:f:end,2),pt2(1:f:end,3),'.r');  %White Matter
        xlabel('x');
        ylabel('y');
        zlabel('z');
        
        [xValu,yValu,zValu] = ind2sub(size(TP1aparc),find(~isnan(changeRatio2)));
        plot3(xValu(1:f:end),yValu(1:f:end),zValu(1:f:end),'.k');   %White Matter
        






