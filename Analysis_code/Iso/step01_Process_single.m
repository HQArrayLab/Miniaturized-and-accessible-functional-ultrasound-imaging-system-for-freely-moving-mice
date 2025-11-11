clear;
clc;
load Data\iso6.mat;

data1=Data;
%% Drug
T_start=[100];
T_end=[220];
Y=-5:5;
%%
color=['m','g','b','k','c','y'];
roi_num=1; %number of rois
framerate=3.57;
Time=size(data1,3)/framerate;
lamda=1540/15e6;

%% choose roi

Data=data1;
frame=size(Data,3);

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
    colormap('hot')
    axis('equal','tight');
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
ylabel('Depth (mm)');
xlabel('Width (mm)');
axis('equal','tight');


hold on
for k=1:n
    [c,h]=contour(phi(:,:,k),[0 0],color(k),LineWidth=1.5);
end
hold off
%% save roi position (open if want)
% save roi_mask.mat roi_mask;

%% PD signal

times=0:1/framerate:Time-1/framerate;
figure;
hold on

for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],'r');
    set(h,'edgealpha',0,'facealpha',0.3);
end

%% PD signal
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=Data.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    eval(['h',num2str(i),'=plot(times,roi_average,color(i));']);  
end


title('PD signal')
h98=legend([h1,h],'Motor','Anesthetics');
set(h98,'Box','off');
axis([0 Time 0 inf]);
xlabel('Time(s)')
ylabel('PD')
grid off
box off
hold off


%% CBV (%)

times=0:1/framerate:Time-1/framerate;
figure;
hold on

for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],'r');
    set(h,'edgealpha',0,'facealpha',0.3);
end



for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=Data.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    F0=mean(roi_average(50:350));
    roi_average2=(roi_average-F0)./F0+0*(i-1);
    eval(['h',num2str(i),'=plot(times,roi_average2,color(i)); ']) 
end

h99=legend([h1,h],'Cortex','Anesthetics');
set(h99,'Box','off');
axis([0 Time -0.3 3]);
xlabel('Time (s)')
ylabel('\Delta CBV')
set(gca,'Fontsize',20,'linewidth',1.5)
grid off
hold off
box off
