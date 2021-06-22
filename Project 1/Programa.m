%%%%%%%%%%
% @author: Juan José Jurado Camino (M20039)
% @version: 2.2
% @date: 25/06/2021
% @module: Image Stitching
% @purpose: This is a project for the subject "Técnicas avanzadas de visión por
% computador" in " Máster Universitario en Robótica y Automática de la 
% Universidad Politécnica de Madrid".
%%%%%%%%%
%% Load the image and constant parameters
clc, clear, close all;

I1 = imread('..\Escena4\Escena4_imagen1.jpg');
I2 = imread('..\Escena4\Escena4_imagen2.jpg');
I3 = imread('..\Escena4\Escena4_imagen3.jpg');




%% Features Detection
%Image 1
grayImage1 = im2gray(I1);
points1 = detectSURFFeatures(grayImage1);
[features1, points1] = extractFeatures(grayImage1, points1);
figure; imshow(I1); hold on
plot(points1.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

%Image 2
grayImage2 = im2gray(I2);
points2 = detectSURFFeatures(grayImage2);
[features2, points2] = extractFeatures(grayImage2, points2);
figure; imshow(I2); hold on
plot(points2.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

%Image 3 
grayImage3 = im2gray(I3);
points3 = detectSURFFeatures(grayImage3);
[features3, points3] = extractFeatures(grayImage3, points3);
figure; imshow(I3); hold on
plot(points3.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

%% Correspondences 
indexPairs21 = matchFeatures(features2, features1, 'Unique', true);
matchedPoints2a = points2(indexPairs21(:,1), :);
matchedPoints1 = points1(indexPairs21(:,2), :);    

indexPairs23 = matchFeatures(features2, features3, 'Unique', true);
matchedPoints2b = points2(indexPairs23(:,1), :);
matchedPoints3 = points3(indexPairs23(:,2), :);

%% Compute Homography

tforms1 = estimateGeometricTransform2D(matchedPoints2a, matchedPoints1,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

tforms2 = estimateGeometricTransform2D(matchedPoints2b, matchedPoints3,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

%% Filter of outliers


%% Panoramic Construcction 

% panorama = zeros([height width 3], 'like', I);
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  
% Initialize the "empty" panorama.
panorama = zeros([3000 3000 3], 'like', I2);
panoramaView = imref2d([1000 1000], [1 30000], [1 1000]);

% Transform I into the panorama.
warpedImage1 = imwarp(I1, tforms1, 'OutputView', panoramaView);
warpedImage3 = imwarp(I3, tforms2, 'OutputView', panoramaView);

% Generate a binary mask.    
mask1 = imwarp(true(size(I1,1),size(I1,2)), tforms1, 'OutputView', panoramaView);
mask3 = imwarp(true(size(I3,1),size(I3,2)), tforms2, 'OutputView', panoramaView);

% Overlay the warpedImage onto the panorama.
panorama = step(blender, panorama, warpedImage1, mask1);
panorama = step(blender, panorama, warpedImage3, mask3);
figure
imshow(panorama)

