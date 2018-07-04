% Consistency check between two disparity maps (left & right)
% Performs per-slice filtering of input cost volume
%
% Syntax:  = consistency_check(dispL, dispR)
% dispL / dispR - input disparity map from left and right perspectives
% invalidPixelsL / invalidPixelsR - binary mask with inconsistent pixels marked with ones

function [ invalidPixelsL, invalidPixelsR] = consistency_check(dispL, dispR, threshold)

d_size=size(dispL);


for y=1:d_size(1)
    for x=1:d_size(2)
        % left disp
        d_l=dispL(y,x);
        v_l=x-d_l;
        d_r = dispR(y,v_l); 
        invalidPixelsL(y,x) = abs(d_r-d_l) > 1;
        
        % right disp
        d_r=dispR(y,x);
        v_r=x+d_r;
        d_l = dispL(y,v_r); 
        invalidPixelsR(y,x) = abs(d_r-d_l) > 1;     
    end
end
end
    
    
