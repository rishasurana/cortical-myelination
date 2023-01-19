function [ output_args ] = DisplaySlices2Figures( im1,im2,numofslices,nameoffigure )
%DisplaySlices2Figures Displays two matrices with multiple slices 
%   Detailed explanation goes here
moving_reg1 = im1;
fixed = im2;
[sz1,sz2,sz3] = size(moving_reg1);
figure('Name',nameoffigure); hold on;
%legend('Green - Labels, Red - Grey matter');
numofplots = numofslices;    
for plot = 1: numofplots
    
    subplot(3,numofplots,plot);
    imshowpair(moving_reg1(:,:,round(sz3/plot)),fixed(:,:,round(sz3/plot)));
    
    subplot(3,numofplots,plot+numofplots);
    imshowpair(imrotate(squeeze(moving_reg1(:,round(sz2/plot),:)),270),imrotate(squeeze(fixed(:,round(sz2/plot),:)),270));
    subplot(3,numofplots,plot+2*numofplots);
    imshowpair(imrotate(squeeze(moving_reg1(round(sz1/plot),:,:)),270),imrotate(squeeze(fixed(round(sz1/plot),:,:)),270));
    
end
    
end

