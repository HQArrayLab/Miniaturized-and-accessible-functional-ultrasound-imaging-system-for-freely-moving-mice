clear;
clc;
load data_temp\Data_singletrials_correct.mat;

Data=Data_cor_1;

T_start=[20];
T_end=[27.9];%
color=['m','g','b','k','c','y'];
roi_num=3;
framerate=3.57;
Time=size(Data,3)/framerate;
Inject=0;

%% 选区绘图
lamda=1540/15e6;
frame=size(Data,3);
dimension_x=0.05*size(Data,2);
dimension_z=0.05*size(Data,1);
Z=(0:size(Data,1)-1)*(lamda/4);
X=(-size(Data,2)/2+0.5:size(Data,2)/2-0.5)*(lamda/3);

figure;
Im_average=mean(Data,3);
Im_average2=Im_average.^0.4;
imagesc(Im_average2)
title('average')
axis('equal','tight');
colormap hot;
text(1,5,'Left click to get points,right click to get end point','FontSize',12,'Color','g');
%%%%%%%choose ROI%%%%%%%%%%%%%%%%%

for n=1:roi_num
    roi_mask(:,:,n)=roipoly;
    phi(:,:,n)=2*2*(0.5-roi_mask(:,:,n));


%     figure;
    imagesc(Im_average2);
    axis('equal','tight');
    colormap('hot')

    text(1,5,'Left click to get points,right click to get end point','FontSize',12,'Color','g');
    hold on
    
    for k=1:n
        [c,h]=contour(phi(:,:,k),[0 0],color(k),LineWidth=1.5);
    end
    hold off
end

%%%%%%%%%%%%%结束%%%%%%%%%%%%%%%%%

figure;

imagesc(Im_average2);    
colormap('hot')

title('Brain Image');
ylabel('Depth ');
xlabel('Width ');
axis('equal','tight');


hold on
for k=1:n
    [c,h]=contour(phi(:,:,k),[0 0],color(k),LineWidth=1.5);
end
hold off

if roi_num==1
%% PD singletrails
times=0:1/framerate:(Time-1/framerate);
figure;
hold on

Y=[0,10000*7];
for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],'r');
    set(h,'edgealpha',0,'facealpha',0.3);
end


for i=1:roi_num
  
    roi_mask_temp=roi_mask(:,:,i);
  for k=1:6
    dd=eval(['Data_cor_',num2str(k)]).*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd,1),2))./sum(roi_mask_temp(:))+10000*(k-1);

    h=plot(times,roi_average,'k','LineWidth',1.5);
  end
end

xlabel('Time(s)')
ylabel('PD')
set(gca,'Fontsize',18,'linewidth',1.5)
% axis off
grid off
hold off

%% PD singletrails CBV
times=0:1/framerate:(Time-1/framerate);
figure;
hold on

Y=[-0.5,6];
for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],'r');
    set(h,'edgealpha',0,'facealpha',0.3);
end

for i=1:roi_num
  
    roi_mask_temp=roi_mask(:,:,i);
  for k=1:6
    dd=eval(['Data_cor_',num2str(k)]).*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd,1),2))./sum(roi_mask_temp(:));
    F0_single=mean(roi_average(1:35));
    dF=(roi_average-F0_single)./F0_single+(k-1)*1;
    h=plot(times,dF,'k','LineWidth',1.5);
  end
end

xlabel('Time(s)')
ylabel('CBV')
set(gca,'Fontsize',18,'linewidth',1.5)
ylim([-0.5,6.5])
axis off


%% bar
x1 = 50; x2 = 55;
line_y = 6 ;
short_line_height = 0.3 ;

% 横线
plot([x1 x2], [line_y line_y], 'k', 'LineWidth', 1.5);
% 左竖线
plot([x1 x1], [line_y+short_line_height line_y], 'k', 'LineWidth', 1.5);

text(mean([x1 x2]), line_y-0.5, '5s', ...
        'FontSize', 14, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

text(x1-6, mean([line_y+short_line_height line_y]), '30%', ...
        'FontSize', 14);
text(mean([T_start,T_end]), 6.1, 'On pole', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
    'FontSize', 14);

grid off
hold off

end

%% 原始数据

times=0:1/framerate:(Time-1/framerate);
figure;
hold on

for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    for k=1:6
        dd1=eval(['Data_cor_',num2str(k)]).*roi_mask_temp;
        roi_average=squeeze(sum(sum(dd1,1),2))./sum(roi_mask_temp(:));
        roi_raw(:,k)=roi_average;
    end
    roi_raw_mean = mean(roi_raw,2);
    roi_raw_sd = std(roi_raw,0,2)./sqrt(6);
    roi_raw_max = roi_raw_mean + roi_raw_sd;
    roi_raw_min = roi_raw_mean - roi_raw_sd;

    patch([times,fliplr(times)],[roi_raw_min',fliplr(roi_raw_max')],color(i),'edgecolor','none','FaceAlpha',0.5);
   eval( ['h',num2str(i),'=plot(times,roi_raw_mean,color(i));']);

end


title('PD')
legend([h1],'Motor','Background')
xlabel('Time (s)')
ylabel('PD Signal')
set(gca,'Fontsize',18,'linewidth',1.5)
grid on
hold off

%% 增长率

times=0:1/framerate:(Time-1/framerate);
figure;
hold on
Y=-2:5;
for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],[0.5,0.5,0.5]);
    set(h,'edgealpha',0,'facealpha',0.2);
end

plot(times,zeros(1,length(times)),'Color','k','LineStyle','--','LineWidth',1.5);%,'Color','k','LineStyle','--',1.5)


for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    for k=1:6
        dd2=eval(['Data_cor_',num2str(k)]).*roi_mask_temp;
        roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
        roi_average = movmean(roi_average,5);
        F0= mean(roi_average(1:35,:));
        d_CBV = (roi_average - F0)./F0;
        CBV_set(:,k) = d_CBV ;
    end
    d_CBV_mean = mean (CBV_set,2);
    d_CBV_sd = std (CBV_set,0,2) ./ sqrt(6);
    d_CBV_max = d_CBV_mean + d_CBV_sd ;
    d_CBV_min = d_CBV_mean - d_CBV_sd ;

    WIDTH='LineWidth';
    patch([times,fliplr(times)],[d_CBV_min',fliplr(d_CBV_max')],color(i),'edgecolor','none','FaceAlpha',0.5);
    eval(['h',num2str(i),'=plot(times,d_CBV_mean,color(i),WIDTH,1.5);']);
    


end

h99=legend([h1,h2,h3,h],'M','S1bf','HPC','On pole','Fontsize',18);
set(h99,'Box','off');
axis([-Inject Time-Inject -0.15 0.5]);
% axis off
xlabel('Time (s)')
ylabel('\Delta CBV (%)')
set(gca,'YTick', -0.2:0.1:0.5, 'Yticklabel',{[-20:10:50]});
set(gca,'Fontsize',18,'linewidth',1.5);
grid off
box off
hold off

