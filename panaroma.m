% Load images.
clear all;
close all;
dir = fullfile('C:','Users','Aashima Singh','Downloads','Comp_558_assignment_4','Dataset2');
images = imageDatastore(dir);

%%
% Read the first image from the image set.
I = imrotate(readimage(images, 1),-90);   

% Initialize features for I(1)
I = imresize(I,0.3);
greyimg = rgb2gray(I);
greyimgs = single(greyimg);
[pts, feat] = vl_sift(greyimgs);
pts = pts';
feat = single(feat');

numImages = numel(images.Files);
%initializing the image transforms
tforms(numImages) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:numImages

    % Store points and features for I(n-1).
    ptsPrev = pts;
    featsPrev = feat;

    % Read I(n) and rotate it.
    I = imrotate(readimage(images, n),-90);
    I = imresize(I,0.3);
    gimg = rgb2gray(I);
    gimgs = single(gimg);
    %compute sift features
    [pts, feat] = vl_sift(gimgs);
    pts = pts';
    feat = single(feat');
    
    % Match features between I(n) and I(n-1).
    indexPairs = matchFeatures(feat, featsPrev, 'Unique', true); %swap features and featuresprevious

    matchedPoints = pts(indexPairs(:,1), :);
    matchedPointsPrev = ptsPrev(indexPairs(:,2), :);
    [~, tforms(n)] = do_ransac(matchedPoints(:,1:2),matchedPointsPrev(:,1:2));
    
    tforms(n).T = tforms(n).T*tforms(n-1).T;
end
imageSize = size(I);
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = canvas_size(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end
%%
avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);
%%

Tinv = invert(tforms(centerImageIdx));

for i = 1:numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T;
end

%%
%Initialize the panorama

for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = canvas_size(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I);

%%
% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];

% Create the panorama.
for i = 1:numImages

    I = imrotate(readimage(images, i),-90);
    I = imresize(I, 0.3);

    panorama = imagemultiply(xMin,yMin,panorama,I,tforms(i).T);

end
figure
imshow(panorama)














    
