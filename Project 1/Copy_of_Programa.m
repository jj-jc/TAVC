%%%%%%%%%%
% @author: Juan José Jurado Camino (M20039)
% @version: 2.2
% @date: 25/06/2021
% @module: Image Stitching
% @purpose: This is a project for the subject "Técnicas avanzadas de visión por
% computador" in " Máster Universitario en Robótica y Automática de la 
% Universidad Politécnica de Madrid".
%%%%%%%%%
clc, clear, close all;
I1 = imread('..\Escena4\Escena4_imagen1.jpg');
I2 = imread('..\Escena4\Escena4_imagen2.jpg');
I3 = imread('..\Escena4\Escena4_imagen3.jpg');

%% Features Detection SIFT
%Parametro casamiento
MatchThresholdSIFT=0.4;
MatchThreshold=0.4;
MatchThresholdHamming=10.0;
MaxRatioSIFT=0.25;
MaxRatio=0.2;
MaxRatioHamming=0.4;

%ALGORITMO SIFT
[Im1, des1, loc1] = sift('..\Escena4\Escena4_imagen1.pgm');
numSIFT_1=size(loc1,1);

[Im2, des2, loc2] = sift('..\Escena4\Escena4_imagen2.pgm');
numSIFT_2=size(loc2,1);

[Im3, des3, loc3] = sift('..\Escena4\Escena4_imagen3.pgm');
numSIFT_3=size(loc3,1);

%Casa los puntos
[puntosMatchSIFT] = casarPuntosSIFT(MatchThresholdSIFT, ...
                                    MaxRatioSIFT, ...
                                    des1,loc1,des2,loc2);
                
%Numero de puntos
numSIFT_Casados=size(puntosMatchSIFT,1);
fprintf('Puntos SIFT casados %d\n',numSIFT_Casados);

%Dibuja los puntos casados correctamente y su disparidad
DibujaCasamiento(puntosMatchSIFT,I1,I2,'SIFT. Puntos casados');
DibujaDisparidad(puntosMatchSIFT,I1,I2,1,'SIFT. Disparidad Puntos casados');

%Casa los puntos
[puntosMatchSIFT2] = casarPuntosSIFT(MatchThresholdSIFT, ...
                                    MaxRatioSIFT, ...
                                    des2,loc2,des3,loc3);
                
%Numero de puntos
numSIFT_Casados2=size(puntosMatchSIFT2,1);
fprintf('Puntos SIFT casados %d\n',numSIFT_Casados2);

%Dibuja los puntos casados correctamente y su disparidad
DibujaCasamiento(puntosMatchSIFT2,I2,I3,'SIFT. Puntos casados');
DibujaDisparidad(puntosMatchSIFT2,I2,I3,1,'SIFT. Disparidad Puntos casados');

%% Compute Homography
matchedPoints1 = puntosMatchSIFT(:,1:2);
matchedPoints2a = puntosMatchSIFT(:,3:4);
matchedPoints2b = puntosMatchSIFT2(:,1:2);
matchedPoints3 = puntosMatchSIFT2(:,3:4);

[tforms1, inlierIdx1] = estimateGeometricTransform2D(matchedPoints1, matchedPoints2a,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, ...
        'MaxDistance', 1);
    
[tforms2, inlierIdx2] = estimateGeometricTransform2D(matchedPoints2a, matchedPoints2a,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, ...
        'MaxDistance', 1);

[tforms3, inlierIdx3] = estimateGeometricTransform2D(matchedPoints3, matchedPoints2b, ...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, ...
        'MaxDistance', 1);

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

