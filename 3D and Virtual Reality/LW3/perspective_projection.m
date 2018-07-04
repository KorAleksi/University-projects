function perspective_projection(vertices,polygons,t,pixelsize,screen_res)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

c = t(1:2)+[0;-screen_res(1)/2]*pixelsize;

X = zeros(size(polygons));
Y = X;
Z = X;

for i=1:12
   X(:,i)=vertices(1,polygons(:,i)); 
   Y(:,i)=vertices(2,polygons(:,i)); 
   Z(:,i)=vertices(3,polygons(:,i)); 
end

cubeU = (t(3).*(X+t(1))./(Z+t(3))-c(1))/pixelsize;
cubeV = (t(3).*(Y+t(2))./(Z+t(3))-c(2))/pixelsize;

%figure('units','normalized','outerposition',[0 0 1 1])
fill(cubeU,cubeV,[1 0 0])
axis equal
xlim([0,screen_res(2)]-screen_res(2)/2)
ylim([0,screen_res(1)]-screen_res(1)/2)

end
