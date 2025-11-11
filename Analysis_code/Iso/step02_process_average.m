clear;
clc;
N=1:5;
framerate = 3.57 ;
T_start=[100];  %strat iso (s）
T_end=[220];   %end iso  (s)
Y=[-1,4];
single=0;
for n=1:length(N)
    load(['Data\iso',num2str(N(n)),'.mat']);
    load(['Data\roi_mask_',num2str(N(n)),'.mat']);
    Time = size(Data,3) ./ framerate;
    times = 0 : 1/framerate : Time-1/framerate;
    roi_mask_temp = roi_mask;
    dd2=Data.*roi_mask_temp;
    roi_average=squeeze(sum(sum(dd2,1),2))./sum(roi_mask_temp(:));
    roi_average = movmean(roi_average,5);
    F0=mean(roi_average(50:350));
    d_CBV= (roi_average - F0) ./ F0;
    
    CBV_dataset(:,n)=d_CBV;

    if single==1
    figure;
    %% shade
    for i=1
        x_start=T_start(i)*ones(1,length(Y));
        x_end=T_end(i)*ones(1,length(Y));
        h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],'r');
        set(h,'edgealpha',0,'facealpha',0.3);
    end
    hold on
    %% CBV
    plot(times,d_CBV,'m');

    axis([0 Time -0.2 3]);
    xlabel('Time (s)')
    ylabel('\Delta CBV')
    set(gca,'Fontsize',20,'linewidth',1.5)
    hold off
    box off
    end
end

mean_CBV = mean(CBV_dataset,2);
sd_CBV = std(CBV_dataset,0,2) ./ sqrt(length(N));
sem1 = mean_CBV + sd_CBV;
sem2 = mean_CBV - sd_CBV;

figure;
Time = length(mean_CBV) ./ framerate;
times = 0 : 1/framerate : Time-1/framerate;

for i=1
    x_start=T_start(i)*ones(1,length(Y));
    x_end=T_end(i)*ones(1,length(Y));
    h=fill([x_start,fliplr(x_end)],[Y,fliplr(Y)],[0.5,0.5,0.5]);
    set(h,'edgealpha',0,'facealpha',0.2);
end
hold on

patch([times,fliplr(times)],[sem2',fliplr(sem1')],'m','edgecolor','none','FaceAlpha',0.4,'HandleVisibility','off');
h1=plot( times, mean_CBV','m','linewidth',1.8);
plot([0,max(times)],[0,0],'k--','linewidth',1.2,'HandleVisibility','off');
axis([0 Time -0.3 2.3]);
h99=legend([h,h1],'ISO duration','Motor');
set(h99,'Box','off');
xlabel('Time (s)')
ylabel('\Delta CBV (%)')
yticklabels({'0','50','100','150','200'});
set(gca,'Fontsize',18)
hold off
box off