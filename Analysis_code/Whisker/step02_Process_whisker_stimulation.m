clear;
clc;
load Data\whisker_sti.mat;

data1=PDI_Data(80:330,:,:);

color=['m','g','b','k','c','y'];
roi_num=1;
framerate=3.57;

%% 选区绘图
Data=data1;
lamda=1540/15e6;
frame=size(Data,3);
dimension_x=lamda/3*1e3*size(Data,2);
dimension_z=lamda/4*1e3*size(Data,1);
Z=(0:size(Data,1)-1)*(lamda/4);
X=(-size(Data,2)/2+0.5:size(Data,2)/2-0.5)*(lamda/3);

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


%% single trials
%sti time
T_start=[105,205,305,405,505,605,705];
T_end=[136,236,336,436,536,636,736];

Time=size(data1,3)/framerate;
times=0:1/framerate:(Time-1/framerate);
figure;
hold on
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=Data.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    roi_average=medfilt1(roi_average,5);
    h1=plot(times,roi_average,color(i),'LineWidth',1.2);  
end


Y=0:0.1:0.7;
for i=1:7
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],[0.5,0.5,0.5]);
    set(h,'edgealpha',0,'facealpha',0.3);
end

h99=legend([h1,h],'S1','Stimulation')
set(h99,'Box','off');
yticks(linspace(0.2, 0.8, 4));  
axis([0 Time 0.3 0.8]);
xlabel('Time(s)')
ylabel('PD')
% axis off
grid off
hold off
set(gca,'Fontsize',18,'linewidth',1.5)
set(gcf,'color','white');  
set(gca,'looseInset',[0 0 0 0])	

%% average

Data_1= data1(:,:,floor(70*framerate):floor(170*framerate));  %106
Brain_Data(:,:,:,1)=Data_1;
Data_2= data1(:,:,floor(170*framerate):floor(270*framerate)); %204
Brain_Data(:,:,:,2)=Data_2;
Data_3= data1(:,:,floor(270*framerate):floor(370*framerate));  %305
Brain_Data(:,:,:,3)=Data_3;
Data_4= data1(:,:,floor(370*framerate):floor(470*framerate));  %305
Brain_Data(:,:,:,4)=Data_4;
Data_5= data1(:,:,floor(470*framerate):floor(570*framerate));  %403
Brain_Data(:,:,:,5)=Data_5;
Data_6= data1(:,:,floor(570*framerate):floor(670*framerate));   %506
Brain_Data(:,:,:,6)=Data_6;
Data_7= data1(:,:,floor(670*framerate):floor(770*framerate));   %506
Brain_Data(:,:,:,7)=Data_7;
Data=(Data_1+Data_2+Data_3+Data_4+Data_5+Data_6+Data_7)/7;


save Data\average.mat Data;



%% CBV(%)
Time=size(Data,3)/framerate;
times=0:1/framerate:(Time-1/framerate);
figure;
hold on
y0=zeros(1,length(times));
plot(times,y0,'Color','k',LineStyle='--',LineWidth=1.2);

T_start=[35];
T_end=[66];
Y=-2:2;
for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],[0.5,0.5,0.5]);
    set(h,'edgealpha',0,'facealpha',0.2);
end


%第一组数据
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    for k=1:7
        dd2=Brain_Data(:,:,:,k).*roi_mask_temp;
        roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
        roi_average=medfilt1(roi_average,5);
        roi_average_temp(:,k)=roi_average;
    end
    CBV_S1=roi_average_temp;
    F0=mean(roi_average_temp(1:120,:),1);
    dF=((roi_average_temp-F0)./F0);
    dF_mean=mean(dF,2);
    dF_std=std(dF,0,2);
    dF_std=dF_std/sqrt(7);
    dF_max=dF_mean+dF_std;
    dF_min=dF_mean-dF_std;

    patch([times,fliplr(times)],[dF_min',fliplr(dF_max')],color(i),'edgecolor','none','FaceAlpha',0.5);
    eval(['h',num2str(i),'=plot(times,dF_mean,color(i),linewidth=1.2);']); 
end


h99=legend([h1,h],'S1','Stimulation');
set(h99,'Box','off');
axis([0 Time -0.1 0.5]);
yticklabels({'-10','0','10','20','30','40','50'});
xlabel('Time(s)')
ylabel('\DeltaCBV(%)')

box off
grid off
hold off
set(gca,'linewidth',1.2)
set(gcf,'color','white');  
set(gca,'looseInset',[0 0 0 0])	


