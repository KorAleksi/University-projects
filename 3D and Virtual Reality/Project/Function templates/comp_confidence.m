% Cost Volume Aggregation with block averaging
% Performs per-slice averaging of input cost volume
%
% Syntax: confidenceMap = comp_confidence(cost)
% Cost - input 3D Cost Volume
% confidenceMap - 2D map of confidence values for the disparity estimates

function confidenceMap = comp_confidence(cost)

size_c = size(cost);
confidenceMap = zeros(size_c(1),size_c(2));
h = waitbar(0,'Computing confidence');
steps = size_c(1);
step = 0;
for y=1:size_c(1)
    step = step+1;
    % computations take place here
    waitbar(step / steps);
    for x=1:size_c(2)
        dcosts = cost(y,x,:);
        peaks = -findpeaks(-dcosts(:),'SortStr','descend');
        l_peaks = length(peaks);
        if l_peaks >= 2
            if peaks(2) == 0
                confidenceMap(y,x) = 0;
            else
                confidenceMap(y,x) = abs(peaks(1)-peaks(2))/peaks(2);
            end
        elseif length(peaks) == 1
            confidenceMap(y,x) = 1;
        else
            confidenceMap(y,x) = 0;
        end 
    end
end
close(h) 
end

