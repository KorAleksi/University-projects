function [disp_filled] = fill_blanks(disp,outliers,Conf)
%FILL_BLANKS Summary of this function goes here
%   Detailed explanation goes here

size_maps = size(disp);


disp = disp.*~outliers;
loc = []
array_i=1;
for y=1:375
    for x=54:450
        if outliers(y,x) == 1
           loc(array_i,1:2) = [y x];
           array_i = array_i+1;
           disp(y,x) = NaN;
        end
    end
end
block_radius=2;
it = 1;
figure
subplot(1,6,1); imshow(disp,[]);
title('Original map')
while true
    disp1 = disp;
    for i=1:length(loc) 
        pos = loc(i,:);
        up=pos(1)-block_radius;
        down=pos(1)+block_radius;
        left=pos(2)-block_radius;
        right=pos(2)+block_radius;
        if up<1 || down>375 || left<1 || right>450
            continue
        end
        block = disp(up:down,left:right);
        block(block_radius+1,block_radius+1) = NaN;
        disp1(pos(1),pos(2)) = nanmedian(block(:));
    end
    if disp == disp1
        disp_filled = disp;
        return
    end
    disp=disp1;
    subplot(1,6,it+1)
    imshow(disp,[])
    title(['Iteration ',num2str(it)])
    
    if it >= 5
        disp_filled = disp;
        return 
    end
    it = it+1
end


end

