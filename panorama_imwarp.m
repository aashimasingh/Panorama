% Load images.
dir = fullfile('C:','Users','Aashima Singh','Downloads','Comp_558_assignment_4','Dataset2');
images = imageDatastore(dir);

%%
% Read the first image from the image set.
I = imrotate(readimage(images, 1),-90);   
I = imresize(I,0.3);
greyimg = rgb2gray(I);
greyimgs = single(greyimg);
[pts, feat] = vl_sift(greyimgs);
pts = pts';
feat = single(feat');

%the first image transform initialized as identity matrix
numImages = numel(images.Files);
tforms(numImages) = projective2d(eye(3));

% Iterate over remaining image pairs
for n = 2:numImages

    % Store points and features for I(n-1).
    pointsPrevious = pts;
    featuresPrevious = feat;

    % Read I(n).
    I = imrotate(readimage(images, n),-90);
    I = imresize(I,0.3);
    gimg = rgb2gray(I);
    gimgs = single(gimg);
    [pts, feat] = vl_sift(gimgs);
    pts = pts';
    feat = single(feat');
    
    % Matching features between I(n) and I(n-1).
    indexPairs = matchFeatures(feat, featuresPrevious, 'Unique', true); %swap features and featuresprevious

    matchedPoints = pts(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    [ptsset tforms(n)] = do_ransac(matchedPoints(:,1:2),matchedPointsPrev(:,1:2));

    tforms(n).T = tforms(n).T';
    tforms(n).T = tforms(n).T*tforms(n-1).T;
end
imageSize = size(I);
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
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
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(2)], [1 imageSize(1)]);
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
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.
for i = 1:numImages

    I = imrotate(readimage(images, i),-90);
    I = imresize(I, 0.3);

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
 
    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end
%panorama = panorama';
figure
imshow(panorama)














    
