% calculates percentage of bad pixels
% (pixels, with error larger than unity)
% 
% Syntax: [err] = calculate_error(Disp, GT)
% Disp - disparity map
% GT - ground truth to be compared against
% occlusions - pixels which are ignored from the error computation

% WORKS-without occlusion

function [err] = calculate_error(Disp, GT, occlusions)
    im_size = size(Disp);
    diff = abs(Disp-GT)>1;
    elements = (im_size(1)*im_size(2));
    err = sum(diff(:))/elements;
end