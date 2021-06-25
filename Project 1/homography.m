function [H] = homography(points1, points2)
%Forma el sistema
% H12
format long
num_pun = size(points1,1);
matriz=zeros(num_pun*2,8);
vector=zeros(num_pun*2,1);

for i=1:num_pun
    matriz(2*i-1,1)=points2(i,1);
    matriz(2*i-1,2)=points2(i,2);
    matriz(2*i-1,3)=1.0;
    matriz(2*i-1,7)=-points2(i,1)*points1(i,1);
    matriz(2*i-1,8)=-points2(i,2)*points1(i,1);
    vector(2*i-1,1)=points1(i,1);

    matriz(2*i,4)=points2(i,1);
    matriz(2*i,5)=points2(i,2);
    matriz(2*i,6)=1.0;
    matriz(2*i,7)=-points2(i,1)*points1(i,2);
    matriz(2*i,8)=-points2(i,2)*points1(i,2);
    vector(2*i,1)=points1(i,2);
end

%Calcula el numero de condicion
numeroCondicion=cond(matriz);
disp(['Numero de condicion  ' num2str(numeroCondicion)]);

%Resuelve el sistema
solucion=(inv((matriz')*matriz))*(matriz')*vector;

%Construye la matriz H
H=zeros(3,3);
H(1,1)=solucion(1,1);
H(1,2)=solucion(2,1);
H(1,3)=solucion(3,1);
H(2,1)=solucion(4,1);
H(2,2)=solucion(5,1);
H(2,3)=solucion(6,1);
H(3,1)=solucion(7,1);
H(3,2)=solucion(8,1);
H(3,3)=1.0;
% disp('Homografia');
disp(H);
end