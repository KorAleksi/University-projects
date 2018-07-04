function [camera_image] = color_video(alpha)
%COLOR_VIDEO Summary of this function goes here
%   Detailed explanation goes here
images = cell(2,4);
front = imread('DSC_4105_c.jpg');
right = imread('DSC_4106_c.jpg');
back = imread('DSC_4107_c.jpg');
left = imread('DSC_4108_c.jpg');

images{1,1} = front; images{1,2} = 'Front';
images{2,1} = right; images{2,2} = 'Right';
images{3,1} = back;  images{3,2} = 'Back';
images{4,1} = left;  images{4,2} = 'Left';

fv = 24;

[X Y Z] = global_of_cam(fv,alpha);

[v u] = back_project(X,Y,Z);
u = round(u);
v = round(v); 

% figure(9)
coords = {X,Z;-Z,X;-X,-Z;Z,-X};
for i=1:4
    cur_im = images{i,1};
    red = cur_im(:,:,1);
    green = cur_im(:,:,2);
    blue = cur_im(:,:,3);
    [v u] = back_project(coords{i,1},Y,coords{i,2}); 
    u = round(u);
    v = round(v);
    u = u+ceil(2003/2);
    v = v+ceil(2999/2);
    img_r = uint8(interp2(double(red),v,u));
    img_g = uint8(interp2(double(green),v,u));
    img_b = uint8(interp2(double(blue),v,u));
    img(:,:,1) = img_r;
    img(:,:,2) = img_g;
    img(:,:,3) = img_b;
    results{i} = img;
%     subplot(1,5,i)
%     imshow(img);
%     title(images{i,2})
end


combined = results{1}+results{2}+results{3}+results{4};

% subplot(1,5,5)
% imshow(combined)
% title('Combined')
% hold off
camera_image = combined;
end

