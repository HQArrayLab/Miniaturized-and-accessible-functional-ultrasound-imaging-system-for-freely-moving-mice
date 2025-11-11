clear;
clc;
load Data\Data_singletrials_correct.mat;

Data_average= (Data_cor_1+Data_cor_2+Data_cor_3+Data_cor_4+Data_cor_5+Data_cor_6)./6;


fusplane.Data=Data_average(20:150,1:115,:);

lamda=1540/15e6;

k=size(fusplane.Data,3);
x_image=(0.05)*[1:1:size(fusplane.Data,2)];
y_image=(0.05)*[1:1:size(fusplane.Data,1)];


figure;
Im_average=mean(fusplane.Data,3);
Im_average2=Im_average.^0.4;
Im_average2=Im_average2./max(Im_average2(:));
imagesc(x_image,y_image,Im_average2)
axis('equal','tight');
axis off;
colormap hot;
colorbar('Ticks',[0,0.2,0.4,0.6,0.8,1], 'TickLabels',{'0','0.2','0.4','0.6','0.8','1'});
set(gca,'Fontsize',18)

