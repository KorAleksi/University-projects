function [ u,v ] = back_project( X, Y, Z )
%BACK_PROJECT Summary of this function goes here
%   Detailed explanation goes here

z_r = 2999/2;
for i=1:501
    for j=1:750
        s =z_r/Z(i,j);
        if s < 0
            u(i,j) = NaN;
            v(i,j) = NaN;
            continue
        end
        u(i,j) = s*X(i,j);
        v(i,j) = s*Y(i,j);  
    end
end
    
    

end

