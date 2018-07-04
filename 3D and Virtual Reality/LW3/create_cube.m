function [cube] = create_cube(side_length,floor_y, front_z)
N = 8; %number of vertices
M = 12; % number of polygons
cube.size = side_length;
cube.vertices = zeros(3,N);
cube.polygons = zeros(3,M)

right_x = side_length/2;
left_x = -right_x;
top_y= floor_y+side_length;
back_z = front_z+side_length;

% vertices 
cube.vertices(:,1) = [left_x;floor_y;front_z];
cube.vertices(:,2) = [right_x;floor_y;front_z];
cube.vertices(:,3) = [left_x;top_y;front_z];
cube.vertices(:,4) = [right_x;top_y;front_z];
cube.vertices(:,5) = [left_x;floor_y;back_z];
cube.vertices(:,6) = [right_x;floor_y;back_z];
cube.vertices(:,7) = [left_x;top_y;back_z];
cube.vertices(:,8) = [right_x;top_y;back_z];

% polygons 
cube.polygons(:,1) = [5;1;2]    % (1,2,5)
cube.polygons(:,2) = [5;2;6]   % (2,5,6)
cube.polygons(:,3) = [6;8;7]    % (6,7,8)
cube.polygons(:,4) = [6;7;5]    % (5,6,7)
cube.polygons(:,5) = [2;4;6]    % (2,4,6)
cube.polygons(:,6) = [4;8;6]    % (4,6,8)
cube.polygons(:,7) = [5;7;3]    % (3,5,7)
cube.polygons(:,8) = [3;7;4]    % (3,4,7)
cube.polygons(:,9) = [4;7;8]    % (4,7,8)
cube.polygons(:,10) = [5;3;1]   % (1,3,5)
cube.polygons(:,11) = [1;3;2]    % (1,2,3)
cube.polygons(:,12) = [2;3;4]    % (2,3,4)
end