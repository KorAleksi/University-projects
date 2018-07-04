% Cost Volume Aggregation with gaussian filtering
% Performs per-slice filtering of input cost volume
%
% Syntax: CostAgg = aggregate_cost_gauss(Cost, radius, simga);
% Cost - input 3D Cost Volume
% radius - radius of square window (size = radius*2 + 1)
% sigma - parameter of Gaussian filter
% CostAgg - aggregated cost

function CostAgg = aggregate_cost_gauss(Cost, radius, sigma)
w_size=radius*2+1;
cost_size=size(Cost);
h = fspecial('gaussian',w_size,sigma);
CostAgg=Cost;
for disp=1:cost_size(3)
    CostAgg(:,:,disp) = imfilter(Cost(:,:,disp),h);
end
end