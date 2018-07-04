% Your implementation should run by executing this m-file ("run LW1.m"), 
% but feel free to create additional files for your own functions
% Make sure it runs without errors or warnings after unzipping

% Fill out the information below

% Group members: Aleksi Korkee 240385
% Additional tasks completed (6, 7, 8):

images = cell(2,4);
front = imread('DSC_4105_c.jpg');
right = imread('DSC_4106_c.jpg');
back = imread('DSC_4107_c.jpg');
left = imread('DSC_4108_c.jpg');

images{1,1} = front; images{1,2} = 'Front';
images{2,1} = right; images{2,2} = 'Right';
images{3,1} = back;  images{3,2} = 'Back';
images{4,1} = left;  images{4,2} = 'Left';


gray_images = cell(2,4);
front_gray = rgb2gray(front);
right_gray = rgb2gray(right);
back_gray = rgb2gray(back);
left_gray = rgb2gray(left); 

gray_images{1,1} = front_gray; gray_images{1,2} = 'Front';
gray_images{2,1} = right_gray; gray_images{2,2} = 'Right';
gray_images{3,1} = back_gray;  gray_images{3,2} = 'Back';
gray_images{4,1} = left_gray;  gray_images{4,2} = 'Left';
%% 2. 

panorama = [front right back left];
imshow(panorama);
%% 3.
fv = 24;
angles = randi(360,1)
[X Y Z] = global_of_cam(fv,angles);
%% 4. 

[v u] = back_project(X,Y,Z);
u = round(u);
v = round(v); 
%% 5.
results = cell(4);
u = u+ceil(2003/2);
v = v+ceil(2999/2);
img = uint8(interp2(double(front_gray),v,u));
results{1} = img;
figure
subplot(1,5,1)

imshow(img);
title(gray_images{1,2});
%% 6
% resample for rest
coords = {-Z,X;-X,-Z;Z,-X};

for i=2:4
    [v u] = back_project(coords{i-1,1},Y,coords{i-1,2}); 
    u = round(u);
    v = round(v);
    u = u+ceil(2003/2);
    v = v+ceil(2999/2);
    img = uint8(interp2(double(gray_images{i}),v,u));
    results{i} = img;
    subplot(1,5,i)
    imshow(img);
    title(gray_images{i,2});
end

%% 7 
subplot(1,5,5)
imshow(results{1}+results{2}+results{3}+results{4})
title('Combined')
hold off

%% 8 With Colors
i = 1;
res= [];
disp('Rendering 360 video')
start = -180;
last = 180;
frames=(last-start)/5+1;
tic
for alpha=start:5:last      
    disp(strcat(int2str(i), '/ ',int2str(frames)))
    im = im2double(color_video(alpha));
    res(:,:,:,i) = im;
    i = i+1; 
end
toc
vid = implay(res);

