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

I1 = imread('Escena4\Escena4_imagen1.jpg');
I2 = imread('Escena4\Escena4_imagen2.jpg');
I3 = imread('Escena4\Escena4_imagen3.jpg');




%% Features Detection
%Image 1
grayImage1 = im2gray(I1);
points1 = detectSURFFeatures(grayImage1);
[features1, points1] = extractFeatures(grayImage1,points1);
figure; imshow(I1); hold on
plot(points1.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

%Image 2
grayImage2 = im2gray(I2);
points2 = detectSURFFeatures(grayImage2);
[features1, points1] = extractFeatures(grayImage1,points1);
figure; imshow(I1); hold on
plot(points1.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

%Image 3 
grayImage1 = im2gray(I1);
points1 = detectSURFFeatures(grayImage1);
[features1, points1] = extractFeatures(grayImage1,points1);
figure; imshow(I1); hold on
plot(points1.selectStrongest(6000), 'showOrientation', false, 'showScale', false);

%% Correspondences 


%% Compute Homography


%% Filter of outliers


%% Panoramic Construcction 



