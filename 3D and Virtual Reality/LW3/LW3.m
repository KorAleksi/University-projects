%%  Lab work 3
%   Aleksi Korkee
%   
%   Completed tasks:
%   (1,2,3,4,5,6,7)
%   
%   
clear all, close all;
%% Initialize variables
% info
floor_loc = -0.35; %m 
cube_loc = 0.3; %m
cube_size = 0.15; %m
focal_length = 0.6; %m

% display info
screen_res = [1080 1920]; %pixels
display_width = 0.52; % m
pixelsize = display_width/screen_res(2); %m
display_height = pixelsize*screen_res(1); %m

%% Task 1

% create cube
cube = create_cube(cube_size,floor_loc,cube_loc);
X = zeros(size(cube.polygons));
Y = X;
Z = X;

for i=1:12
   X(:,i)=cube.vertices(1,cube.polygons(:,i)); 
   Y(:,i)=cube.vertices(2,cube.polygons(:,i)); 
   Z(:,i)=cube.vertices(3,cube.polygons(:,i)); 
end

fill3(X,Y,Z,[1 1 1]);
xlabel('x'); ylabel('y');zlabel('z')
title('Task 1: Model creation')
%figure; scatter3(cube.vertices(1, :), cube.vertices(2, :), cube.vertices(3, :)); hold on; scatter3(0, 0, 0, 'rx'); axis equal; labelAxis

%% Task 2

%In the middle of the screen in poth dimensions

t = [0;display_height/2;focal_length];
cubeU = (t(3).*(X+t(1))./(Z+t(3)))/pixelsize;
cubeV = (t(3).*(Y+t(2))./(Z+t(3)))/pixelsize;

figure('units','normalized','outerposition',[0 0 1 1])
fill(cubeU,cubeV,[1 0 0])
axis equal
xlim([1,screen_res(2)]-screen_res(2)/2)
ylim([1,screen_res(1)]-screen_res(1)/2)
title('Task 2: Perspective projection')

%% Task 3

figure('units','normalized','outerposition',[0 0 1 1])

% viewer looking directly at camera from focal
t = [0;0;focal_length];

% Testing different t vectors
for i=0.26:-0.02:-0.26  
    pause(0.05)
    t(1)=i;
    perspective_projection(cube.vertices,cube.polygons,t,pixelsize,screen_res);
    title('Task 3: Changing viewpoint')
end
t = [0;0;focal_length];
for i=0.4:-0.02:0  
    pause(0.05)
    t(2)=+i;
    perspective_projection(cube.vertices,cube.polygons,t,pixelsize,screen_res);
    title('Task 3: Changing viewpoint')
end

%% Task 4

% Image (task4_image) was taken of 30cm ruler at distance of 60cm.
% It is saved in task4.mat 
load task4.mat
%imshow(task4_image);

% 0.3 m  meter wide ruler is at 
% 0.6 m distance from cam.
% 0.30 m is 490-61=429 pixels in image

cam_focal = 429*0.6/0.3; 

%------ image was taken with the code below
% imaqreset
% % Create the webcam object.
% if exist('cam', 'var')
%     if isvalid(cam)
%         delete(cam);
%     end
% end
% cam =  videoinput('winvideo',1);
% cam.FramesPerTrigger = 1;
% cam.TriggerRepeat = Inf;
% 
% triggerconfig(cam, 'manual');
% start(cam)
% 
% %figure out focal length of camera
% % trigger(cam);
% % task4_image = getdata(cam);
% figure(4)
% imshow(task4_image);
%---------------------------------
%% Task 6 

% multiple cubes
t = [0;0;focal_length];
cube_far = cube;
cube_far.vertices = cube_far.vertices+[0;0;0.25]

cube_near = cube;
cube_near.vertices = cube_near.vertices-[0;0;cube_loc+cube_size+0.05];

figure('units','normalized','outerposition',[0 0 1 1])
perspective_projection(cube_far.vertices,cube.polygons,t,pixelsize,screen_res);
hold on
perspective_projection(cube.vertices,cube.polygons,t,pixelsize,screen_res);
perspective_projection(cube_near.vertices,cube.polygons,t,pixelsize,screen_res);
hold off
title('Task 6')

%% Task 5
imaqreset
% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();

% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Create the webcam object.
if exist('cam', 'var')
    if isvalid(cam)
        delete(cam);
    end
end
cam =  videoinput('winvideo',1);
cam.FramesPerTrigger = 1;
cam.TriggerRepeat = Inf;

triggerconfig(cam, 'manual');
start(cam)

% Capture one frame to get its size.
trigger(cam);
videoFrame = getdata(cam);
frameSize = size(videoFrame);
loc_buffer = []

%%
figure('units','normalized','outerposition',[0 0 1 1])
while true
    %%
    
    
    % Get the next frame.
    trigger(cam);
    videoFrame = getdata(cam);
    videoFrameGray = rgb2gray(videoFrame);
    ds = 4;
    videoFrameGray = imresize(videoFrameGray, 1/ds);
    bbox = faceDetector.step(videoFrameGray);
    bbox = bbox*ds;

    
    %%
    if isempty( bbox )
        disp('Face not found')
    else  
        bboxPoints = bbox2points(bbox(1, :));
        
        % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
        % format required by insertShape.
        bboxPolygon = reshape(bboxPoints', 1, []);
        
        % Display a bounding box around the detected face.
        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
        
        eye_pos = [bbox(2)+bbox(4)/2 bbox(1)+bbox(3)/2];
        
        % shift eye
        eye_pos = eye_pos-ceil(frameSize(1:2)/2);
        
        % Extract approximate eye position from bbox and feed it
        % to your rendering function here
        
        x = eye_pos(2)*focal_length/cam_focal;
        y = eye_pos(1)*focal_length/cam_focal;
           
% Task 7----------------------------------------------- 
        max_buffer = 4;
        b_size = size(loc_buffer);
        if b_size == [0 0]
            loc_buffer = [x y];   
        elseif b_size(1) >= max_buffer
            loc_buffer = [[x y];loc_buffer(1:end-1,:)]
        else
            loc_buffer(end+1,:)=[x y];
        end
        new_loc=mean(loc_buffer,1);
        t= [new_loc(1);new_loc(2);focal_length];
        
        %subplot(1,2,1)
        %draw farthest cube 
        perspective_projection(cube_far.vertices,cube.polygons,t,pixelsize,screen_res);
        hold on
        %draw the middle cube
        perspective_projection(cube.vertices,cube.polygons,t,pixelsize,screen_res);
        %draw the closest cube 
        perspective_projection(cube_near.vertices,cube.polygons,t,pixelsize,screen_res);
        hold off
    end 
    %subplot(1,2,2)
    %imshow(videoFrame)
end
%%
% Clean up.
delete(cam);
release(faceDetector);