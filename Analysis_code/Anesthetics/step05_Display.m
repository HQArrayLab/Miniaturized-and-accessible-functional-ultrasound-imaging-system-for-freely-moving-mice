clear;
clc;
load Data\iso4.mat;

fusplane.Data=Data(58:end,:,:);

lamda=1540/15e6;

x_image=(0.05)*[-size(fusplane.Data,2)/2+0.5:1:size(fusplane.Data,2)/2-0.5];
y_image=(0.05)*[0:1:size(fusplane.Data,1)-1];


figure;
dB = 30;
Im_average=mean(fusplane.Data,3);
Im_average2 = 10*log10(Im_average./max(Im_average(:))+eps);
imagesc(x_image,y_image,Im_average2)
caxis([-30 0]);
axis('equal','tight');
axis off;
colormap gray;
h= colorbar;
h.Label.String = 'dB';
set(gca,'Fontsize',18)


%% bar
hold on
x1 = -3; x2 = -2;
line_y = 5.5 ;
short_line_height = 0.3 ;

% 横线
plot([x1 x2], [line_y line_y], 'w', 'LineWidth', 1.5);

text(mean([x1 x2]), line_y+0.5, '1mm', ...
        'FontSize', 14, 'Color','w','HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

grid off
hold off
