% Finds disparity map from Cost Volume
% Syntax: [Disp] = winner_takes_all(Cost)
% Hints:
% for each (y,x) find the z (the layer) with the lowest cost value
% (note that matlab coordinates starts from 1, hence we need substract that unity)

function [Disp] = winner_takes_all(Cost)
im_size=size(Cost);
Disp=zeros(im_size(1),im_size(2));
for y=1:im_size(1)
    for x=1:im_size(2)
        [v I] = min(Cost(y,x,:));
        Disp(y,x) = I-1;
    end
end
end
