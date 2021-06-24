%%%%%%%%%%
% @author: Juan José Jurado Camino (M20039)
% @version: 2.2
% @date: 25/06/2021
% @module: Image Stitching
% @purpose: This is a project for the subject "Técnicas avanzadas de visión por
% computador" in " Máster Universitario en Robótica y Automática de la 
% Universidad Politécnica de Madrid".
%%%%%%%%%
%% LOOK AT ALL THE DIFFERENTE PARAMETERS YOU WANT TO CHOOSE
clc, clear, close all;
%Choose the algorithm for detection
ALGORITHM = 1;
    % SIFT = 1
    % SURF = 2
    % KAZE = 3
    % HARRIS = 4 
    % BRISK = 5
    % ORB = 6
%Choose the way to compute the homography
HOMOGRAPHY = 1;
    % projective estimation of Matlab = 1
    % manually = 2
format long

%% Load the image and constant parameters
I1 = imread('..\Escena4\Escena4_imagen1.jpg');
I2 = imread('..\Escena4\Escena4_imagen2.jpg');
I3 = imread('..\Escena4\Escena4_imagen3.jpg');

nombre_I1 = '..\Escena4\Escena4_imagen1.pgm';
nombre_I2 = '..\Escena4\Escena4_imagen2.pgm';
nombre_I3 = '..\Escena4\Escena4_imagen3.pgm';

% I1_pgm = imread(nombre_I1);
% I2_pgm = imread(nombre_I2);
% I3_pgm = imread(nombre_I3);
%% Features Detection and Correspondencies

if ALGORITHM == 1
%%  SIFT
    %Parameters
    MatchThresholdSIFT=0.4;
    MatchThreshold=0.4;
    MatchThresholdHamming=10.0;
    MaxRatioSIFT=0.25;
    MaxRatio=0.2;
    MaxRatioHamming=0.4;

    [Im1, des1, loc1] = sift('..\Escena4\Escena4_imagen1.pgm');
    numSIFT_1=size(loc1,1);

    [Im2, des2, loc2] = sift('..\Escena4\Escena4_imagen2.pgm');
    numSIFT_2=size(loc2,1);

    [Im3, des3, loc3] = sift('..\Escena4\Escena4_imagen3.pgm');
    numSIFT_3=size(loc3,1);

    %Correspondence 1 - 2
    [puntosMatchSIFT] = casarPuntosSIFT(MatchThresholdSIFT, ...
                                        MaxRatioSIFT, ...
                                        des1,loc1,des2,loc2);
    %Number of points 1 - 2
    numSIFT_Casados=size(puntosMatchSIFT,1);
    fprintf('Puntos SIFT casados %d\n',numSIFT_Casados);
    %Dibuja los puntos casados correctamente y su disparidad
    DibujaCasamiento(puntosMatchSIFT,I1,I2,'SIFT. Puntos casados');
    DibujaDisparidad(puntosMatchSIFT,I1,I2,1,'SIFT. Disparidad Puntos casados');
    
    %Correspondence 3 - 2
    [puntosMatchSIFT2] = casarPuntosSIFT(MatchThresholdSIFT, ...
                                        MaxRatioSIFT, ...
                                        des2,loc2,des3,loc3);
    %Number of points 3 - 2
    numSIFT_Casados2=size(puntosMatchSIFT2,1);
    fprintf('Puntos SIFT casados %d\n',numSIFT_Casados2);
    %Dibuja los puntos casados correctamente y su disparidad
    DibujaCasamiento(puntosMatchSIFT2,I2,I3,'SIFT. Puntos casados');
    DibujaDisparidad(puntosMatchSIFT2,I2,I3,1,'SIFT. Disparidad Puntos casados');
    
    matchedPoints1 = puntosMatchSIFT(:,1:2);
    matchedPoints2a = puntosMatchSIFT(:,3:4);
    matchedPoints2b = puntosMatchSIFT2(:,1:2);
    matchedPoints3 = puntosMatchSIFT2(:,3:4);
    
elseif ALGORITHM == 2     
%%  SURF
    %Image 1
    grayImage1 = im2gray(I1);
    points1 = detectSURFFeatures(grayImage1, 'MetricThreshold', 1000, ...
        'NumOctaves', 3, ...
        'NumScaleLevels', 4, ...
        'ROI', [1 1 size(I1,2) size(I1,1)]);

    [features1, points1] = extractFeatures(grayImage1, points1);
    figure; imshow(I1); hold on
    plot(points1.selectStrongest(100), 'showOrientation', false, 'showScale', false);

    %Image 2
    grayImage2 = im2gray(I2);
    points2 = detectSURFFeatures(grayImage2, 'MetricThreshold', 1000, ...
        'NumOctaves', 3, ...
        'NumScaleLevels', 4, ...
        'ROI', [1 1 size(I1,2) size(I1,1)]);
    [features2, points2] = extractFeatures(grayImage2, points2);
    figure; imshow(I2); hold on
    plot(points2.selectStrongest(100), 'showOrientation', false, 'showScale', false);

    %Image 3 
    grayImage3 = im2gray(I3);
    points3 = detectSURFFeatures(grayImage3);
    [features3, points3] = extractFeatures(grayImage3, points3);
    figure; imshow(I3); hold on
    plot(points3.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

    %Correspondences 
    indexPairs21 = matchFeatures(features1, features2, 'Unique', true, ...
        'Method', 'Exhaustive', ...
        'MatchThreshold', 10, ...
        'MaxRatio', 0.6, ...
        'Metric', 'SSD');
    matchedPoints1 = points1(indexPairs21(1:20,1), :);
    matchedPoints2a = points2(indexPairs21(1:20,2), :);  
    % I2 = [I1, I2];
    figure; ax = axes;
    showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2a, 'montage', 'Parent', ax)
    legend(ax, 'Matched points Image 1', 'Matched points Image 2');

    indexPairs23 = matchFeatures(features2, features3, 'Unique', true);
    matchedPoints2b = points2(indexPairs23(1:20,1), :);
    matchedPoints3 = points3(indexPairs23(1:20,2), :);
    figure; ax = axes;
    showMatchedFeatures(I2, I3, matchedPoints2b, matchedPoints3, 'montage', 'Parent', ax)
    legend(ax, 'Matched points Image 2', 'Matched points Image 3');

elseif ALGORITHM == 3 
%%  KAZE
%     imwrite(I1, '..\Escena4\Escena4_imagen1.tiff');
%     imwrite(I2, '..\Escena4\Escena4_imagen2.tiff');
%     imwrite(I3, '..\Escena4\Escena4_imagen3.tiff');
%     I1 = imread('..\Escena4\Escena4_imagen1.tiff');
%     I2 = imread('..\Escena4\Escena4_imagen2.tiff');
%     I3 = imread('..\Escena4\Escena4_imagen3.tiff');
%     
%     %Image 1
%     points1 = KAZEPoints(I1);
%     figure; imshow(I1); hold on
%     plot(points1.selectStrongest(100), 'showOrientation', false, 'showScale', false);
% 
%     %Image 2
%     points2 = KAZEPoints(I2, 'Scale', 1.6, ...
%         'Metric', 0.0, ...
%         'Orientation', 0.0);
%     figure; imshow(I2); hold on
%     plot(points2.selectStrongest(100), 'showOrientation', false, 'showScale', false);
% 
%     %Image 3 
%     points3 = KAZEPoints(I3, 'Scale', 1.6, ...
%         'Metric', 0.0, ...
%         'Orientation', 0.0);
%     figure; imshow(I3); hold on
%     plot(points3.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

    %Correspondences 
%     indexPairs21 = matchFeatures(features1, features2, 'Unique', true, ...
%         'Method', 'Exhaustive', ...
%         'MatchThreshold', 10, ...
%         'MaxRatio', 0.6, ...
%         'Metric', 'SSD');
%     matchedPoints1 = points1(indexPairs21(1:20,1), :);
%     matchedPoints2a = points2(indexPairs21(1:20,2), :);  
%     % I2 = [I1, I2];
%     figure; ax = axes;
%     showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2a, 'montage', 'Parent', ax)
%     legend(ax, 'Matched points Image 1', 'Matched points Image 2');
% 
%     indexPairs23 = matchFeatures(features2, features3, 'Unique', true);
%     matchedPoints2b = points2(indexPairs23(1:20,1), :);
%     matchedPoints3 = points3(indexPairs23(1:20,2), :);
%     figure; ax = axes;
%     showMatchedFeatures(I2, I3, matchedPoints2b, matchedPoints3, 'montage', 'Parent', ax)
%     legend(ax, 'Matched points Image 2', 'Matched points Image 3');
elseif ALGORITHM == 4
%% HARRIS = 4 
elseif ALGORITHM == 5
%% BRISK = 5
elseif ALGORITHM == 5
%% ORB = 6
end
%% Compute Homography
NUM_PUN1 = size(matchedPoints1,1);
NUM_PUN2 = size(matchedPoints3,1);
if HOMOGRAPHY == 1
    [tforms1, inlierIdx1] = estimateGeometricTransform2D(matchedPoints1, matchedPoints2a,...
            'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, ...
            'MaxDistance', 1);
    H12 = tforms1.T';
    [tforms2, inlierIdx2] = estimateGeometricTransform2D(matchedPoints2a, matchedPoints2a,...
            'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, ...
            'MaxDistance', 1);
    H22 = tforms2.T';
    [tforms3, inlierIdx3] = estimateGeometricTransform2D(matchedPoints3, matchedPoints2b, ...
            'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, ...
            'MaxDistance', 1);   
    H32 = tforms3.T';
elseif HOMOGRAPHY == 2
    tform = projective2d; tforms1 = tform; tforms2 = tform; tforms3 = tform;
    H12 = homography(NUM_PUN1, matchedPoints2a.Location, matchedPoints1.Location);
    tforms1.T = H12';  
    H22 = eye(3,3);
    tforms2.T = H22'; 
    H32 = homography(NUM_PUN2, matchedPoints2b.Location, matchedPoints3.Location);
    tforms3.T = H32'; 
end

%Calcula los nuevos puntos con la homografia (en la imagen)
proyected_points=zeros(NUM_PUN1,3);
if ALGORITHM == 1
    Points1_xyz = [matchedPoints1(:,:), ones(NUM_PUN1,1)];
    Points2a_xyz = [matchedPoints2a(:,:), ones(NUM_PUN1,1)];
elseif ALGORITHM == 2
    Points1_xyz = [matchedPoints1.Location(:,:), ones(NUM_PUN1,1)];
    Points2a_xyz = [matchedPoints2a.Location(:,:), ones(NUM_PUN1,1)];
end
for i=1:NUM_PUN1
    PuntoCalculado=H12*(Points1_xyz(i,:)');
    %Tercera componente a 1
    PuntoCalculado=PuntoCalculado/PuntoCalculado(3,1);
    %Almacena el puntos
    proyected_points(i,:)= PuntoCalculado';
end
%Calcula el error para cada punto
correct_points = [];
errorTotal=0;
for i=1:NUM_PUN1
    error=norm(proyected_points(i,:) - Points2a_xyz(i,:));
    errorTotal=errorTotal+error;
    disp(['Punto ' num2str(i) '  Error pixeles ' num2str(error)]);
%         if error < 0.5
%             correct_points(i, :) =  Points2a_xyz(i,:);
%         end
end
disp(['Media del Error ' num2str(errorTotal/NUM_PUN1)]);


%Calcula los nuevos puntos con la homografia (en la imagen)
proyected_points=zeros(NUM_PUN2,3);
if ALGORITHM == 1
    Points2b_xyz = [matchedPoints2b(:,:), ones(NUM_PUN2,1)];
    Points3_xyz = [matchedPoints3(:,:), ones(NUM_PUN2,1)];
elseif ALGORITHM == 2
    Points2b_xyz = [matchedPoints2b.Location(:,:), ones(NUM_PUN2,1)];
    Points3_xyz = [matchedPoints3.Location(:,:), ones(NUM_PUN2,1)];
end

for i=1:NUM_PUN2
    PuntoCalculado=H32*(Points3_xyz(i,:)');
    %Tercera componente a 1
    PuntoCalculado=PuntoCalculado/PuntoCalculado(3,1);
    %Almacena el puntos
    proyected_points(i,:)= PuntoCalculado';
end

%Calcula el error para cada punto
correct_points = [];
errorTotal=0;
for i=1:NUM_PUN2
    error=norm(proyected_points(i,:) - Points2b_xyz(i,:));
    errorTotal=errorTotal+error;
    disp(['Punto ' num2str(i) '  Error pixeles ' num2str(error)]);
%         if error < 0.5
%             correct_points(i, :) =  Points2a_xyz(i,:);
%         end
end
disp(['Media del Error ' num2str(errorTotal/NUM_PUN2)]);

%% Filter of outliers


%% Panoramic Construcction 
% calculate the limits of the images transformed
[xlim(1,:), ylim(1,:)] = outputLimits(tforms1, [1 size(I1,2)], [1 size(I1,1)]);
[xlim(2,:), ylim(2,:)] = outputLimits(tforms2, [1 size(I2,2)], [1 size(I2,1)]);
[xlim(3,:), ylim(3,:)] = outputLimits(tforms3, [1 size(I3,2)], [1 size(I3,1)]);

% Find the minimum and maximum output limits. 

xMin = min([1; xlim(:)]);
xMax = max([size(I1,2); xlim(:)]);
xLimits = [xMin xMax];

yMin = min([1; ylim(:)]);
yMax = max([size(I1,1); ylim(:)]);
yLimits = [yMin yMax];

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', I1);
imshow(panorama)
panoramaView = imref2d([height width], xLimits, yLimits);


%% 
% Apply the transformation  
I1_transform = imwarp(I1, tforms1, 'OutputView', panoramaView);
mask1 = imwarp(true(size(I1,1),size(I1,2)), tforms1, 'OutputView', panoramaView);
figure
imshow(I1_transform)

I2_transform = imwarp(I2, tforms2, 'OutputView', panoramaView);
mask2 = imwarp(true(size(I2,1),size(I2,2)), tforms2, 'OutputView', panoramaView);
figure
imshow(I2_transform)

I3_transform = imwarp(I3, tforms3, 'OutputView', panoramaView);
mask3 = imwarp(true(size(I3,1),size(I3,2)), tforms3, 'OutputView', panoramaView);
figure
imshow(I3_transform)

%% 
% panorama = zeros([height width 3], 'like', I);
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Overlay the warpedImage onto the panorama.
panorama = step(blender, panorama, I1_transform, mask1);
panorama = step(blender, panorama, I2_transform, mask2);
panorama = step(blender, panorama, I3_transform, mask3);
figure
imshow(panorama)
% panorama = step(blender, panorama, warpedImage3, mask3);
% figure
% imshow(panorama)

