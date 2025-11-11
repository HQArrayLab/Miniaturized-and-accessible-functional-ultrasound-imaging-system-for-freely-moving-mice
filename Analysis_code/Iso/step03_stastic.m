clear;
clc;
load Data\iso1_LOF.mat;
iso1=iso_CBV_mean;
awake1=awake_CBV_mean;

load Data\iso2_LOF.mat;
iso2=iso_CBV_mean;
awake2=awake_CBV_mean;

load Data\iso3_LOF.mat;
iso4=iso_CBV_mean;
awake4=awake_CBV_mean;

load Data\iso4_LOF.mat;
iso5=iso_CBV_mean;
awake5=awake_CBV_mean;

load Data\iso5_LOF.mat;
iso6=iso_CBV_mean;
awake6=awake_CBV_mean;

x=[1:5];
dataset=[iso1,awake1;
         iso2,awake2;
         iso4,awake4;
         iso5,awake5;
         iso6,awake6;];
% 误差矩阵
AVG = dataset/5; % 下方长度
STD = dataset/7; % 上方长度

%% 颜色定义
C1 = [0 0.45 0.74];
C2 = [0.85 0.33 0.1];

% 绘制初始柱状图
GO = bar(x,dataset,1,'EdgeColor','k');
hold on
% 添加误差棒
[M,N] = size(dataset);
xpos = zeros(M,N);
for i = 1:N
    xpos(:,i) = GO(1,i).XEndPoints'; % v2019b
end
% hE = errorbar(xpos, dataset, AVG, STD);

% 柱状图赋色
% GO(1).FaceColor = C1;
% GO(2).FaceColor = C2;

% 误差棒属性
% set(hE, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.2)

% 坐标区调整
set(gca, 'Box', 'off', ...                                         % 边框
         'XGrid', 'off', 'YGrid', 'off', ...                        % 网格
         'TickDir', 'in', 'TickLength', [.01 .01], ...            % 刻度
         'XMinorTick', 'off', 'YMinorTick', 'off', ...             % 小刻度
         'XColor', [.1 .1 .1],  'YColor', [.1 .1 .1],...           % 坐标轴颜色
         'YTick', 0:0.02:1,...                                      % 刻度位置、间隔
         'Ylim' , [0 0.11], ...                                     % 坐标轴范围
         'Xticklabel',{'mice1' 'mice2' 'mice3' 'mice4' 'mcie5'},...% X坐标轴刻度标签
         'Yticklabel',{[0:0.02:1]});                               % Y坐标轴刻度标签
         
ylabel('Average amplitude')

% Legend 设置    
hLegend = legend([GO(1),GO(2)], ...
                 'Anesthetics', 'Awake', ...
                 'Location', 'northeast','Box','off');
% Legend位置微调 
PL = hLegend.Position;
hLegend.Position = PL + [0.015 0.03 0 0];
% 字体和字号
set(gca, 'FontName', 'Helvetica')
% set([hXLabel, hYLabel], 'FontName', 'AvantGarde')
set(gca, 'FontSize', 18,'linewidth',1.2)
% set([hXLabel, hYLabel], 'FontSize', 11)
% set(hTitle, 'FontSize', 11, 'FontWeight' , 'bold')
% 背景颜色
set(gcf,'Color',[1 1 1])

%% t检验
group1 = dataset(:,1); % 第一组
group2 = dataset(:,2); % 第二组

% t检验
[~,p] = ttest2(group1, group2);

% 计算均值和标准误
mean1 = mean(group1);
mean2 = mean(group2);
sem1 = std(group1);%/sqrt(length(group1));
sem2 = std(group2);%/sqrt(length(group2));

means = [mean1, mean2];
sems = [sem1, sem2];

figure;
bar_handle = bar(means, 'FaceColor', 'flat');
bar_handle.CData(1,:) = [0 0.45 0.74]; 
bar_handle.CData(2,:) = [0.85 0.33 0.1]; 
hold on;

% 添加误差线
errorbar(1:2, means, sems, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% X轴标签
set(gca, 'XTickLabel', {'Anesthetics', 'Awake'}, 'FontSize', 12);

% Y轴标签
ylabel('Average amplitude');

% 显著性标记参数
y_max = max(means + sems);
line_y = y_max + 0.01; % 横线高度
short_line_height = 0.005; % 竖线高度
x1 = 1; x2 = 2;

if p < 0.001
    % 横线
    plot([x1 x2], [line_y line_y], 'k', 'LineWidth', 1.5);
    % 左竖线
    plot([x1 x1], [line_y line_y-short_line_height], 'k', 'LineWidth', 1.5);
    % 右竖线
    plot([x2 x2], [line_y line_y-short_line_height], 'k', 'LineWidth', 1.5);
    % 星号和p值紧贴横线居中
    txt = '***  p < 0.001';
    text(mean([x1 x2]), line_y+0.005, txt, ...
        'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end


box off;
set(gcf,'Color',[1 1 1]);
set(gca, 'FontSize', 18,'linewidth',1.2)
% title('Group Comparison');
