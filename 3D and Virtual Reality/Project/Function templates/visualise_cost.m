for i=1:54
    figure(7);
    imshow(uint8(CostL(:,:,i)))
    figure(8);
    imshow(uint8(CostR(:,:,i)))
    pause(0.05)
end