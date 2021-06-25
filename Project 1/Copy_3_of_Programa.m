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
HOMOGRAPHY = 2;
    % projective estimation of Matlab = 1
    % manually = 2
FILTER = 1;DIST = 0.5; % geometric distance minim
    % No filters = 0
    % Residual error = 1
    % Geometric distance error = 2
    % RANSAC = 3

MOSAIC = 1;
    % Manually = 1
    % Matlab = 2
    
  
format long
