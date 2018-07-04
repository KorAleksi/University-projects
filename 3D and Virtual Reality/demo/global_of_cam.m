function [ X , Y , Z] = global_of_cam( fv, alpha )
%UNTITLED Summary of this function goes here
%   Compute global space coordinates of the image plane


size = [2003 2999];
[X Y] = meshgrid(1:1:2999,1:1:2003);

% Task 2: shift coordinate system
X = X-ceil(size(2)/2);
Y = Y-ceil(size(1)/2);

% Task 3: Keep every 4th coordinate 
X = X(1:4:size(1),1:4:size(2));
Y = Y(1:4:size(1),1:4:size(2));

% Task 4: 
w = 36;
fr = 36/2;
fr_pixels = 2999/2;
Z = X*0+ceil(fv/w*size(2)); 

% Task 5: 
R = roty(alpha);


for i=1:501
    for j=1:750
        p = [X(i,j) Y(i,j) Z(i,j)];
        uv=R*p';
        X(i,j) = uv(1);
        Y(i,j) = uv(2);
        Z(i,j) = uv(3);
        
    end
end



end

