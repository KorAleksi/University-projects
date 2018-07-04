% In this demo: 
% - cost volumes calculation
% - aggregation (with different filters)
% - disparity aqcuisition (winner-takes-all)
% - left-to-right correspondance check
% - occlusion filling


clear all;
close all;
clc;

dataset = 'teddy'; factor = 4;

L = imread([dataset,'\view1.png']);
R = imread([dataset,'\view5.png']);
GTL = round(single(imread([dataset,'\disp1.png']))./factor);
GTR = round(single(imread([dataset,'\disp5.png']))./factor);

mindisp = 0;
maxdisp = ceil(max(GTL(:)));

figure;
subplot(221); imshow(L); title('Left image');
subplot(222); imshow(R); title('Right image');

subplot(223); imshow(GTL, [mindisp maxdisp]); title('Left ground truth disparity');
subplot(224); imshow(GTR, [mindisp maxdisp]); title('Right ground truth disparity');



%figure; imshow(L); 
%figure; 
%figure; 

%% cost calculation
[CostL, CostR] = calculate_cost(L, R, maxdisp);
radius = 9;

figure;

% no aggregation + winner-takes-all
[DispL] = winner_takes_all(CostL);
subplot(221); imshow(DispL, [mindisp maxdisp]); title(['Without aggregation - Error: ', num2str(calculate_error(DispL, GTL))]); drawnow;

% block aggregation + winner-takes-all
cost = aggregate_cost_block(CostL, radius);
[DispLeftBlock] = winner_takes_all(cost);

subplot(222);  imshow(DispLeftBlock, [mindisp maxdisp]); title(['Block-aggregation  - Error: ' num2str(calculate_error(DispLeftBlock, GTL))]); drawnow;

% gaussian aggregation + winner-takes-all
cost = aggregate_cost_gauss(CostL, radius, 10);
[DispLeftGauss] = winner_takes_all(cost);
DispLeftGauss = DispLeftGauss + mindisp;

subplot(223);  imshow(DispLeftGauss, [mindisp maxdisp]); title(['Gaussian aggregation - Error: ', num2str(calculate_error(DispLeftGauss, GTL))]); drawnow;
 
% guided filter aggregation + winner-takes-all
cost = aggregate_cost_guided(CostL, L, radius, 100);
[DispLeftGuided] = winner_takes_all(cost);
DispLeftGuided = DispLeftGuided + mindisp;

subplot(224);  imshow(DispLeftGuided, [mindisp maxdisp]); title(['Guided filter aggregation - Error: ', num2str(calculate_error(DispLeftGuided, GTL))]); drawnow;
 
%%
% Graphs about effect of radius
radii = 1:12;
names = {'Block aggregation', 'Gaussian aggregation', 'Guided filtering'};
h = figure;



ERRORS = ones(numel(radii), 3)*NaN;

for radius = radii
    % Block aggregation
    cost = aggregate_cost_block(CostL, radius);
    [disptmp] = winner_takes_all(cost);
    ERRORS(radius, 1) = calculate_error(disptmp, GTL);

    % Gaussian aggregation
    cost = aggregate_cost_gauss(CostL, radius, radius/2);
    [disptmp] = winner_takes_all(cost);
    ERRORS(radius, 2) = calculate_error(disptmp, GTL);
    
    % Guided filter aggregation
    cost = aggregate_cost_guided(CostL, L, radius, 1000);
    [disptmp] = winner_takes_all(cost);
    ERRORS(radius, 3) = calculate_error(disptmp, GTL);
       
    % Stop computation if the result window is closed
    if ~ishandle(h)
        break;
    end
  
    
    % Plot the results
    figure(h); 
    plot(radii, ERRORS, 'LineWidth', 2); 
    title('Aggregation performance'); 
    legend(names); 
    xlabel('Window radius');
    ylabel('BAD pixels (%)');
    xlim([radii(1), radii(end)])
    drawnow;
    
    
end
clear disptmp;


