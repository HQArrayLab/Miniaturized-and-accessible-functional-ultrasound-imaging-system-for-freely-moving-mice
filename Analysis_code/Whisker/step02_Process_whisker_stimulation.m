clear;
clc;
load Data\whisker_sti.mat;
data1=PDI_Image(:,:,:);

color=['m','g','b','k','c','y'];
roi_num=1;
framerate=3.6;

%% 选区绘图
Data=data1;
lamda=1540/15e6;
frame=size(Data,3);
Z=(0:size(Data,1)-1)*(0.05);
X=(-size(Data,2)/2+0.5:size(Data,2)/2-0.5)*(0.05);

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
T_start=[50,110,170,230,290];
T_end=[70,130,190,250,310];

Time=size(data1,3)/framerate;
times=0:1/framerate:(Time-1/framerate);
figure;
hold on
for i=1:roi_num
    roi_mask_temp=roi_mask(:,:,i);
    dd2=Data.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    
    F0 = mean(roi_average(1:floor(45*3.57)));
    roi_average = (roi_average-F0)./F0;
    roi_average=medfilt1(roi_average,10);
    h1=plot(times,roi_average,color(i),'LineWidth',1.2);  
end

Y=[-0.3,0.4];
for i=1:5
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],[0.5,0.5,0.5]);
    set(h,'edgealpha',0,'facealpha',0.3);
end

h99=legend([h1,h],'S1bf','Stimulation');
set(h99,'Box','off');
ylim([-0.25 0.55])
yticks(-0.2:0.2:0.4)
yticklabels({'-20','0','20','40'});
xlabel('Time(s)')
ylabel('\DeltaCBV(%)')
% axis off
grid off
hold off
set(gca,'Fontsize',18,'linewidth',1.5)
set(gcf,'color','white');  
set(gca,'looseInset',[0 0 0 0])	

%% average

Data_1= data1(:,:,floor(30*framerate):floor(90*framerate));  %106
Brain_Data(:,:,:,1)=Data_1;
Data_2= data1(:,:,floor(90*framerate):floor(150*framerate)); %204
Brain_Data(:,:,:,2)=Data_2;
Data_3= data1(:,:,floor(150*framerate):floor(210*framerate));  %305
Brain_Data(:,:,:,3)=Data_3;
Data_4= data1(:,:,floor(210*framerate):floor(270*framerate));  %305
Brain_Data(:,:,:,4)=Data_4;
Data_5= data1(:,:,floor(270*framerate):floor(330*framerate));  %403
Brain_Data(:,:,:,5)=Data_5;


Data=(Data_1+Data_2+Data_3+Data_4+Data_5)/5;


save Data\average.mat Data;



%% CBV(%)
Time=size(Data,3)/framerate;
times=0:1/framerate:(Time-1/framerate);
figure;
hold on
y0=zeros(1,length(times));
plot(times,y0,'Color','k',LineStyle='--',LineWidth=1.2);

T_start=[20];
T_end=[40];
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
    for k=1:5
        dd2=Brain_Data(:,:,:,k).*roi_mask_temp;
        roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
        roi_average=medfilt1(roi_average,5);
        roi_average_temp(:,k)=roi_average;
    end
    CBV_S1=roi_average_temp;
    F0=mean(roi_average_temp(1:50,:),1);
    dF=((roi_average_temp-F0)./F0);
    dF_mean=mean(dF,2);
    dF_std=std(dF,0,2);
    dF_std=dF_std/sqrt(5);
    dF_max=dF_mean+dF_std;
    dF_min=dF_mean-dF_std;

    patch([times,fliplr(times)],[dF_min',fliplr(dF_max')],color(i),'edgecolor','none','FaceAlpha',0.5);
    eval(['h',num2str(i),'=plot(times,dF_mean,color(i),linewidth=1.2);']); 
end


h99=legend([h1,h],'S1bf','Stimulation');
set(h99,'Box','off');
axis([0 Time -0.1 0.5]);
yticklabels({'-10','0','10','20','30','40','50'});
xlabel('Time(s)')
ylabel('\DeltaCBV(%)')

box off
grid off
hold off
set(gca,'Fontsize',18,'linewidth',1.5)
set(gcf,'color','white');  
set(gca,'looseInset',[0 0 0 0])	