% Your implementation should run by executing this m-file ("run LW1.m"), 
% but feel free to create additional files for your own functions
% Make sure it runs without errors or warnings after unzipping

% Fill out the information below

% Group members:
% Additional tasks completed (6, 7, 8, 9):
clear all, close all
front = imread('DSC_4105_c.jpg');
right = imread('DSC_4106_c.jpg');
back = imread('DSC_4107_c.jpg');
left = imread('DSC_4108_c.jpg');

front_gray = rgb2gray(front);
right_gray = rgb2gray(right);
back_gray = rgb2gray(back);
left_gray = rgb2gray(left); 

% 2. panorama
panorama = [front right back left];
imshow(panorama);

angles = 0;

% 3.
[X Y Z] = global_of_cam(24,angles);

% 4. 
[v u] = back_project(X,Y,Z);
u = round(u);
v = round(v); 

img = uint8(zeros(501,750));
% 5.
u = u+ceil(2003/2);
v = v+ceil(2999/2);
for i=1:501
    for j=1:750
        try
           img(i,j) =  front_gray(u(i,j),v(i,j));
        catch exception
            img(i,j) = 0;
        end
    end
end
figure
colormap gray
imshow(img);