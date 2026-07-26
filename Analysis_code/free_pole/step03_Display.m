clear;
clc;
load Data\Data_singletrials_correct.mat;
load Data\dataAtlas.mat;
slice = 136;
dx=0.05;
dz=0.05;
Data_average= (Data_cor_1+Data_cor_2+Data_cor_3+Data_cor_4+Data_cor_5+Data_cor_6)./6;
fusplane.Data=Data_average(27:150,1:115,:);
lamda=1540/15e6;

x_image=(0.05)*[-size(fusplane.Data,2)/2+0.5:1:size(fusplane.Data,2)/2-0.5];
y_image=(0.05)*[0:1:size(fusplane.Data,1)-1];
range=[min(x_image) max(x_image) min(y_image) max(y_image)];


figure;
dB = 30;
Im_average=mean(fusplane.Data,3);
Im_average2 = 10*log10(Im_average./max(Im_average(:))+eps);
imagesc(x_image,y_image,Im_average2)
caxis([-30 0]);
axis('equal','tight');
axis(range);
axis off;
h= colorbar;
h.Label.String = 'dB';
colormap gray;
addLines(LinReg.Cor,slice,x_image,y_image,0.95,-2.0,0.93,0.25,dx,dz);
set(gca,'Fontsize',18)

%% bar
hold on
x1 = -2.7; x2 = -1.7;
line_y = 5.7 ;
short_line_height = 0.3 ;

% 横线
plot([x1 x2], [line_y line_y], 'w', 'LineWidth', 2.5);

text(mean([x1 x2]), line_y+0.5, '1mm', ...
        'FontSize', 18, 'Color','w','HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

grid off
hold off

%% atlas
function h = addLines(LL, ip, X,Z,xk,xb,yk,yb,dx,dz)
    L = LL{ip};
    hold on;
    nb = length(L);
    h = gobjects(nb, 1);
    bian=L{2};
    SIZE=max(bian)-min(bian);
    rx=(2*SIZE(2)/3)./115;
    ry=SIZE(1)./124;
    for ib = 2:nb
        x = L{ib};
        xx=x(:, 2)*dx./rx+X(1);
        yy=x(:, 1)./ry*dz+Z(1);
        xx=xx.*xk+xb;
        yy=yy.*yk+yb;
       h(ib) = plot(xx,yy, 'w:','MarkerSize',30,'LineWidth',0.5,'LineStyle','--');   %video
    end
end
