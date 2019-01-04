img1 = imread('C:\Users\Aashima Singh\Downloads\Comp_558_assignment_4\Dataset1.jpg');
img2 = imread('C:\Users\Aashima Singh\Downloads\Comp_558_assignment_4\Dataset2.jpg');

img1 = imresize(img1,0.3);
img1 = rgb2gray(img1);
img1 = img1';

img2 = imresize(img2,0.3);
img2 = rgb2gray(img2);
img2 = img2';

img1 = single(img1) ;
img2 = single(img2) ;

[pts1, feat1] = vl_sift(img1) ;
[pts2, feat2] = vl_sift(img2) ;
pts1 = pts1';
pts2 = pts2';
feat1 = single(feat1');
feat2 = single(feat2');

indexPairs = matchFeatures(feat1,feat2) ;
 
matchedPoints1 = pts1(indexPairs(:,1),:);
matchedPoints2 = pts2(indexPairs(:,2),:);

mp = matchedPoints1(:,1:2);
mp2 = matchedPoints2(:,1:2);

figure; ax=axes;
showMatchedFeatures(img1,img2,mp,mp2,'montage','Parent',ax);
legend(ax, 'From Image1','From Image2');







