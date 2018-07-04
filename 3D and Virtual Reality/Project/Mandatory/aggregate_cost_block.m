% Cost Volume Aggregation with block averaging
% Performs per-slice averaging of input cost volume
%
% Syntax: CostAgg = aggregate_cost_block(Cost, radius);
% Cost - input 3D Cost Volume
% radius - radius of square window (size = radius*2 + 1)
% CostAgg - aggregated cost

function CostAgg = aggregate_cost_block(Cost, radius)

cost_size = size(Cost);
w_size = radius*2+1;
CostAgg=Cost;
for disp=1:cost_size(3)
    h=ones(w_size,w_size)/(w_size^2);
    CostAgg(:,:,disp)=imfilter(Cost(:,:,disp),h);
end
end