% CS 543 Assignment 1, starter Matlab code
% Adapted from A. Efros
% (http://graphics.cs.cmu.edu/courses/15-463/2010_fall/hw/proj1/)

% name of the input file
% imname = '00125v.jpg';
% imname = '00149v.jpg';
% imname = '00153v.jpg';
% imname = '00351v.jpg';
% imname = '00398v.jpg';
% imname = '01112v.jpg';
% imname = '01047u.tif';
imname = '01657u.tif';
% imname = '01861a.tif';
begint = cputime;
% read in the image
fullim = imread(imname);

% convert to double matrix (might want to do this later on to same memory)
fullim = im2double(fullim);

% compute the height of each part (just 1/3 of total)
height = floor(size(fullim,1)/3);
% separate color channels
B = fullim(1:height,:);
G = fullim(height+1:height*2,:);
R = fullim(height*2+1:height*3,:);


% Align the images
% Functions that might be useful to you for aligning the images include: 
% "circshift", "sum", and "imresize" (for multiscale)

% [aB,xoffset1,yoffset1] = alignSSD(B,R,15);
% [aG,xoffset2,yoffset2] = alignSSD(G,R,15);

% [aG,xoffset1,yoffset1] = alignNCC(G,B);
% [aR,xoffset2,yoffset2] = alignNCC(R,B);

[aG,xoffset1,yoffset1] = alignPyramid(G,R,3);
[aB,xoffset2,yoffset2] = alignPyramid(B,R,3);

% [aB,xoffset1,yoffset1] = edgeNCC(B,G);
% [aR,xoffset2,yoffset2] = edgeNCC(R,G);

a1 = ['xoffset is : ', num2str(xoffset1)];
b1 = ['yoffset is : ', num2str(yoffset1)];
a2 = ['xoffset is : ', num2str(xoffset2)];
b2 = ['yoffset is : ', num2str(yoffset2)];
disp(a1);
disp(b1);
disp(a2);
disp(b2);

endtime = cputime - begint

% open figure
%% figure(1);
figure(1);
alignim = cat(3,R,aG,aB);
imshow(alignim);


% create a color image (3D array)
% ... use the "cat" command
% show the resulting image
% ... use the "imshow" command
% save result image
imwrite(alignim,['resultedgeNcc-' imname]);

%ssd alignment 
function [aG,shiftGxfinal,shiftGyfinal] = alignSSD(G1,B,window)
minsimilar = 999999999;
rect_O = [10 10 374 321];
G = imcrop(G1,rect_O);
B = imcrop(B,rect_O);
for shiftGx = -window:window 
    for shiftGy = -window:window
        shiftG = circshift(G,[shiftGx shiftGy]);
        gsum = sum(sum((B-shiftG).^2));
        if gsum < minsimilar 
            minsimilar = gsum;
            shiftGxfinal = shiftGx;
            shiftGyfinal = shiftGy;
            aG = circshift(G1,[shiftGx shiftGy]);
        end
    end
end
end

function [GF,shiftx,shifty] = alignNCC(O,T)
rect_O = [100 100 200 100];
% rect_O = [20 20 354 301];
sub_O = imcrop(O,rect_O);
% T = imcrop(T,rect_O);
c = normxcorr2(sub_O,T);
[ypeak,xpeak] = find(c==max(c(:)));
shiftx = ypeak - size(sub_O,1)-100;
shifty = xpeak - size(sub_O,2)-100;
% shiftx = ypeak - size(sub_O,1);
% shifty = xpeak - size(sub_O,2);
GF = circshift(O,[shiftx shifty]);
end

function [GF,shiftx,shifty] = alignPyramid(O,T,level)
O1 = O;
T1 = T;
for i = 1:level
%     O1 = impyramid(O1,'reduce');
%     T1 = impyramid(T1,'reduce');
    O1 = imresize(O1,0.5);
    T1 = imresize(T1,0.5);
end

O1 = edge(O1,'Canny');
T1 = edge(T1,'Canny');

% rect_O = [100 100 200 100];
rect_O = [50 50 294 241];

sub_O = imcrop(O1,rect_O);
T1 = imcrop(T1,rect_O);
c = normxcorr2(sub_O,T1);
[ypeak,xpeak] = find(c==max(c(:)));
shifty = ypeak - size(sub_O,1);
shiftx = xpeak - size(sub_O,2);

for i = 1:level
    shifty = shifty *2;
    shiftx = shiftx *2;
end

GF = circshift(O,[shifty shiftx]);

end

function [GF,shiftx,shifty] = edgeNCC(O1,T)
O = edge(O1,'Canny');
T = edge(T,'Canny');
% rect_O = [100 100 200 100];
rect_O = [20 20 354 301];
sub_O = imcrop(O,rect_O);
T = imcrop(T,rect_O);
c = normxcorr2(sub_O,T);
[ypeak,xpeak] = find(c==max(c(:)));
% shiftx = ypeak - size(sub_O,1)-100;
% shifty = xpeak - size(sub_O,2)-100;
shiftx = ypeak - size(sub_O,1);
shifty = xpeak - size(sub_O,2);
GF = circshift(O1,[shiftx shifty]);
end
