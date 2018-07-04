% Cost Volume Aggregation with bilateral  filtering
% Performs per-slice filtering of input cost volume
% Cost - input 3D Cost Volume


% CostAgg - aggregated cost

function CostAgg = aggregate_cost_bilateral(cost,guideImage, radius)
cost = padarray(cost,[radius radius]);
guideImage = padarray(guideImage,[radius radius]);
w_size = radius*2+1;
cost_size = size(cost);
delta_g = zeros(w_size,w_size);
middle_uv = radius+1;
gamma = 10;
for u=1:w_size
    for v=1:w_size
        delta_g(u,v) = sqrt((u-middle_uv)^2+(v-middle_uv)^2); 
    end
end

weightB = exp(-(delta_g).^2/gamma);

for y=1+radius:cost_size(1)-radius
    for x=1+radius:cost_size(2)-radius
        up = y-radius;
        down = y+radius;
        left = x-radius;
        right = x+radius;
        guide_block = guideImage(up:down,left:right,:);
        weightA = exp(-(guide_block-guideImage(y,x,:)).^2/gamma);
        weights = weightA.*weightB;
        for d=1:cost_size(3)    
            cost_block = cost(up:down,left:right,d);     
            CostAggre(y,x,d) = sum(weights(:).*cost_block(:));
%              if CostAggre(y,x,d) > 150 
%                 CostAggre(y,x,d) = 150; 
%              end
        end
    end
end


CostAgg = CostAggre(1+radius:cost_size(1)-radius,1+radius:cost_size(2)-radius,:);
end