% In this demo: 
% - left-to-right correspondance check
% - confidence analysis
% - outlier filling 

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


% Computing costs and disparity maps in the same way as in 
% the mandatory steps for analysis
smoothingAmount = 100;
radius = 11;

[CostL, CostR] = calculate_cost(L, R, maxdisp);
guidedCostL = aggregate_cost_guided(CostL, L, radius, smoothingAmount);
guidedCostR = aggregate_cost_guided(CostR, R, radius, smoothingAmount);

[DispLeftGuided] = winner_takes_all(guidedCostL);
[DispRightGuided] = winner_takes_all(guidedCostR);

h = figure; subplot(1, 4, 1);
imshow(DispLeftGuided, [0 maxdisp]); title([ 'Raw disparity from guided filter, error: ', num2str(calculate_error(DispLeftGuided, GTL))]);  drawnow;
%% Left-to-Right correspondance check
[outliersL, outliersR] = consistency_check(DispLeftGuided, DispRightGuided, 1);
figure(h); subplot(1, 4, 2); imshow(outliersL, [0 1]); title('Left outliers'); drawnow;


%% Confidence analysis
ConfL = comp_confidence(guidedCostL);
figure(h); subplot(1, 4, 3); imshow(ConfL, [0 1]); title('Confidence map of the left view');  drawnow;
    

%% Outlier Filling
DispLeftGuided_filled = fill_blanks(DispLeftGuided, outliersL, ConfL);
figure(h); subplot(1, 4, 4); imshow(DispLeftGuided_filled, [mindisp maxdisp]); 
title([ 'Outlier compensated left disparity, error: ', num2str(calculate_error(DispLeftGuided_filled, GTL))]);  drawnow;


%% Bilateral aggregation
bilateralCostL = aggregate_cost_bilateral(CostL, L, radius);

[DispLeftBilateral] = winner_takes_all(bilateralCostL);
DispLeftBilateral = DispLeftBilateral + mindisp;

figure; imshow(DispLeftBilateral, [mindisp maxdisp]); title(['Biliteral filter aggregation - Error: ', num2str(calculate_error(DispLeftBilateral, GTL))]); drawnow;