clear;
clc;
% 1. Load .mat file
load Data\Data_singletrials.mat;
for ii=1:6
eval(['fusplane.Data=Data_',num2str(ii),';']);
data1 = fusplane.Data;  
x_image = 0.05 * [1:1:size(data1, 2)];  
z_image = 0.05 * [1:1:size(data1, 1)]; 
data = data1.^0.25;  
% 2. Calculate L2 norm for each frame
frameNorms = squeeze(sqrt(sum(sum(data.^2, 1), 2)));  

% 3. 通过直方图交互式选择阈值 --------------------------------------------
hFigHist = figure('Position', [100, 100, 800, 600]);
histogram(frameNorms, 50, 'Normalization', 'probability');
xlabel('L2 Norm');
ylabel('Probability');
title('Frame Norm Distribution - Click to Set Threshold (Press Enter to Confirm)');

% 绘制初始阈值线
% initialThresh = median(frameNorms) + 3*std(frameNorms);
initialThresh = mean(frameNorms(1:35)) + 3*std(frameNorms(1:35));
hLine = xline(initialThresh, 'r', 'LineWidth', 2);
legend('Norm Distribution', 'Threshold', 'Location', 'northwest');

% 允许用户点击直方图调整阈值
disp('Click on the histogram to adjust the threshold line. Press Enter to confirm.');
[x, ~] = ginput(1);  % 等待用户点击
while ~isempty(x)
    delete(hLine);  % 删除旧阈值线
    hLine = xline(x(1), 'r', 'LineWidth', 2);  % 绘制新阈值线
    title(sprintf('Current Threshold: %.2f (Press Enter to Confirm)', x(1)));
    [x, ~] = ginput(1);  % 继续等待用户输入
end
bestThresh = hLine.Value;
close(hFigHist);

% 根据阈值标记潜在异常帧
potentialOutlierIDs = frameNorms > bestThresh;
fprintf('Selected threshold: %.2f\n', bestThresh);
fprintf('Potential outliers detected: %d frames\n', sum(potentialOutlierIDs));

% 4. Interactive outlier confirmation \y
disp('Starting interactive outlier frame confirmation...');
disp('For each frame, press "y" to confirm as outlier, "n" to reject, or "q" to quit early.');

confirmedOutlierIDs = false(size(potentialOutlierIDs)); 
outlierFrames = find(potentialOutlierIDs); 

hFig = figure('Position', [100, 100, 1200, 1000]); 

for i = 1:length(outlierFrames)
    t = outlierFrames(i);
    frame = data(:, :, t);
    
    clf(hFig); 
    Im2_norm = mat2gray(frame);
    imagesc(x_image, z_image, Im2_norm);
    caxis([0, 1]);
    colormap('hot');
    colorbar;
    title(sprintf('Potential Outlier Frame %d (Norm: %.2f)\nPress "y"=outlier, "n"=normal, "q"=quit', t, frameNorms(t)));
    
    waitforbuttonpress;
    key = get(gcf, 'CurrentCharacter');
    
    if lower(key) == 'y'
        confirmedOutlierIDs(t) = true;
        fprintf('Frame %d confirmed as outlier.\n', t);
    elseif lower(key) == 'n'
        fprintf('Frame %d marked as normal.\n', t);
    elseif lower(key) == 'q'
        fprintf('Early termination selected. %d frames remaining unconfirmed.\n', length(outlierFrames)-i);
        break;
    else
        fprintf('Invalid key pressed. Frame %d skipped.\n', t);
    end
end
close(hFig); 

% 5. Visualize and save results 
outputDir = ['Data\artifacts',num2str(ii),'\'];
if ~exist(outputDir, 'dir')
    mkdir(outputDir);  
end

for t = 1:size(data, 3)
    if confirmedOutlierIDs(t)
        frame = data(:, :, t);
        figure('Visible', 'off');  
        Im2_norm = mat2gray(frame);
        imagesc(x_image, z_image, Im2_norm);
        caxis([0, 1]);
        colormap('hot');
        colorbar;
        title(sprintf('Confirmed Outlier Frame %d (Norm: %.2f)', t, frameNorms(t)));
        saveas(gcf, fullfile(outputDir, sprintf('confirmed_outlier_frame_%01d.png', t)));
        close;
    end
end

% 6. Plot final norm histogram with confirmed outliers
figure;
histogram(frameNorms, 50);
hold on;
xline(bestThresh, 'r', 'LineWidth', 2);
plot(frameNorms(confirmedOutlierIDs), zeros(sum(confirmedOutlierIDs),1), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('L2 Norm');
ylabel('Frequency');
title(sprintf('Frame Norm Distribution (Threshold: %.2f)', bestThresh));
legend('Norm Distribution', 'Manual Threshold', 'Confirmed Outliers');
hold off;
saveas(gcf, fullfile(outputDir, 'norm_distribution_with_confirmed.fig'));

% 7. Remove outliers and interpolate (原代码不变)
goodFrames = find(~confirmedOutlierIDs);  
badFrames = find(confirmedOutlierIDs);    

cleanedData = zeros(size(data));
for x = 1:size(data1, 1)
    for y = 1:size(data1, 2)
        pixelSeries = squeeze(data1(x, y, :));
        cleanedPixelSeries = interp1(goodFrames, pixelSeries(goodFrames), 1:size(data1, 3), 'linear', 'extrap');
        cleanedData(x, y, :) = cleanedPixelSeries;
    end
end

% 8. Save cleaned data
fusplane.Data = cleanedData;  
eval(['Data_cor_',num2str(ii),'=cleanedData;']);
if ii==1
    save('Data\Data_singletrials_correct.mat', ['Data_cor_',num2str(ii)]);
else
    save('Data\Data_singletrials_correct.mat', ['Data_cor_',num2str(ii)],'-append');
end
end