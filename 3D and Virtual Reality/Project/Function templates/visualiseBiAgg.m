
Im = zeros(256,256,2)
Im(:,:,1)=imnoise(imread('cameraman.tif'));
figure
subplot(1,2,1)
imshow(Im(:,:,1),[])
subplot(1,2,2)
costA = aggregate_cost_bilateral(Im,Im(:,:,1),11)
imshow(costA(:,:,1),[])