% calculates cost volume out of two images
% Syntax: [CostL, CostR] = calculate_cost(L, R, maxdisp);
%
% Where:
% CostL - Cost volume assocuiated with Left image
% CostR - Cost volume assocuiated with Right image
% L, R - Left and Right input images
% mindisp, maxdisp - parameters, limiting disparity 
%
% Algorithm hints:
% for disp from 0 to maxdisp
%   CostL(y,x,disp) = |L(y,x,:)-R(y,x-disp,:)| 
%   CostR(y,x,disp) = |R(y,x,:)-L(y,x+disp,:)| 


function [CostL, CostR] = calculate_cost(L, R, maxdisp)

L=double(L);
R=double(R);
im_size = size(L);
CostL = Inf(im_size(1),im_size(2),maxdisp+1);
CostR = CostL;
for disp = 0:maxdisp
    for y = 1:im_size(1)
        for x = 1:im_size(2)
            if x-disp>=1
                CostL(y,x,disp+1)=sum(abs(L(y,x,:)-R(y,x-disp,:)));
                if CostL(y,x,disp+1) >150
                    CostL(y,x,disp+1) = 150;
                end
            end
            if x+disp<=im_size(2) 
                CostR(y,x,disp+1)=sum(abs(R(y,x,:)-L(y,x+disp,:)));
                if CostR(y,x,disp+1) >150
                    CostR(y,x,disp+1) = 150;
                end
            end
        end
            
    end
end
end






