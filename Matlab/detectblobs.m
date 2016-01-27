clc;
close all;
clear;
rgbI = imread('oval.jpg');
%Convert to grayscale image
I = rgb2gray(rgbI);
figure();
imshow(I)
title('grayscaled image');
%Perform canny edge detection to return binary image where edges are 1s and
%0's elswhere
[~, threshold] = edge(I, 'canny');
fudgeFactor = 4;
%Threshold the image to filter out unwanted edges
BWs = edge(I,'canny', threshold * fudgeFactor);
figure(); 
fig1 = imshow(BWs);
saveas(fig1,'bingradmask.jpg');
title('binary gradient mask');
%Create a structuring element shaped like a disk with radius = 50
se = strel('disk',50);
%Perform closing to close any gaps that may not be connected in the
%outlined image
BWsdil = imclose(BWs,se);
figure();
fig2 = imshow(BWsdil);
saveas(fig2,'dilgradmask.jpg');
title('dilated gradient mask');
%Fill in the areas completely enclosed by an edge to form an actual blob
BWdfill = imfill(BWsdil, 'holes');
figure();
fig3 = imshow(BWdfill);
saveas(fig3,'filled.jpg');
title('binary image with filled holes');
%Remove any light structures that are connected to the image border 
%(i.e. remove any objects that touch the border of the image)
BWfinal = imclearborder(BWdfill, 4);
figure(); 
fig4 = imshow(BWfinal);
saveas(fig4,'cleared.jpg');
title('cleared border image');
%Apply median filter to smooth objects over
filteredImage=medfilt2(BWfinal,[25 25]);
%Boundary Label the Filtered Image
[L, num]=bwlabel(filteredImage);
STATS=regionprops(L,'all');
cc=[];
removed=0;
%Remove any noisy regions that do not have an area large enough to be considered an object
% This should be adjusted based on pixel density crap
for i=1:num
    dd=STATS(i).Area;
    if (dd < 1000)
        L(L==i)=0;
        removed = removed + 1;
        num=num-1;
    end
end
[L2, num2]=bwlabel(L);
% Trace region boundaries in a binary image and display the results.
[B,L,N,A] = bwboundaries(L2);
figure();
fig2 = imshow(L2);title('Blob Detected');
saveas(fig2,'ovaldetected.jpg');
hold on;
for k=1:length(B),
    boundaries = B{k};
    plot(boundaries(:,2),boundaries(:,1),'r','LineWidth',3);
end