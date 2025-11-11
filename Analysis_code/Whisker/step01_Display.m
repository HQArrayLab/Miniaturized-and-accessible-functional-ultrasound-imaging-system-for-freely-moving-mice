clear;
clc;
load Data\whisker_sti.mat;


fusplane.Data=PDI_Data(80:330,:,:);

lamda=1540/15e6;
figure;
k=size(fusplane.Data,3);
x_image=(lamda/3*1e3)*[1:1:size(fusplane.Data,2)];
y_image=(lamda/4*1e3)*[1:1:size(fusplane.Data,1)];

figure;
Im_average=mean(fusplane.Data,3);
Im_average2=Im_average.^0.4;
Im_average2=Im_average2./max(Im_average2(:));
imagesc(x_image,y_image,Im_average2)
axis('equal','tight');
axis off;
colormap hot;

