clear;
clc;
load Data\Data_singletrials_correct.mat ;
load Data\Data_singletrials.mat ;


color=['m','g','b','k','c','y'];
roi_num=1;
framerate=3.57;
data1=Data_cor_1;
Time=size(data1,3)/framerate;


times=0:1/framerate:(Time-1/framerate);


%% 选区绘图
Data=data1;
lamda=1540/15e6;
frame=size(Data,3);

figure;
Im_average=mean(Data(:,:,1:200),3);
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



for n=1:6
    eval(['Data = Data_cor_',num2str(n),';']);
    eval(['Data2 = Data_',num2str(n),';']);
%% 原始数据
%第一组数据
times=0:1/framerate:(Time-1/framerate);
figure('Position', [100, 100, 1600, 400]);
subplot(2,2,[3,4])
hold on
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=Data.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:))+0*(i-1);
    F0=mean(roi_average(1:35));
    roi_average=(roi_average-F0)./F0;
    plot(times,roi_average,color(i));

end

title(['After Correct-',num2str(n)])
% legend('区域1')
xlim([0 Time]);
xlabel('Time (s)')
ylabel('\Delta CBV')
set(gca,'Fontsize',18,'linewidth',1.5)
grid on
box off
% hold off

 
%% before correct 
subplot(2,2,[1,2])


% hold on
%第一组数据
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=Data2.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:))+0*(i-1);
    F0=mean(roi_average(1:35));
    roi_average=(roi_average-F0)./F0;
    plot(times,roi_average,color(i));
end
title(['Before Correct-',num2str(n)])
% legend('区域1')
xlim([0 Time]);
xlabel('Time (s)')
ylabel('\Delta CBV')
set(gca,'Fontsize',18,'linewidth',1.5)
grid on
box off
hold off


end
