
%% Perform Pearson's correlation on whisker_dataset 

clear;
load Data\average.mat; 
load Data\dataAtlas.mat;
slice=139;
lamda=1540/15e6;
dx=(0.05);
dz=(0.05);
scanfus.Data=Data(55:end,15:end,:);
Z=(0.05)*[0:1:size(scanfus.Data,1)-1];
X=(0.05)*[-size(scanfus.Data,2)/2+0.5:1:size(scanfus.Data,2)/2-0.5];
range=[min(X) max(X) min(Z) max(Z)];

T1= floor(20*3.57);         % Start of the stimulus.
T2= floor(40*3.57);          % End of the stimulus.
mapOriginal=mapCorrelation(scanfus, T1, T2);
mapOriginal.Data(find(mapOriginal.Data<0.23))=0;

%% Brain image
close all
figure(1);
[nz,nx,np,nt]=size(scanfus.Data); % data dimensions
temp=mean(squeeze(scanfus.Data(:,:,:)),3);
imagesc(X,Z,(temp.^0.25)./max(temp(:))); 
hold on
axis('equal','tight');
axis off;
% axis(range)
colormap hot;
colorbar
title('Brain image');
hold off

%% Correlation map
p=1.4;
figure(2)

Doppler=scanfus.Data(:,:,:);
DopplerM = mean(Doppler,3);
DopplerFrame=DopplerM.^0.16;

ax1 = axes;
VesselsRGB=DopplerFrame;
bg=imagesc(ax1,X,Z,VesselsRGB);
colormap(ax1, 'gray');
axis(ax1, 'image', 'off');


ax2 = axes;
fg=imagesc(ax2,X,Z,mapOriginal.Data(:,:,1));

colormap(ax2, 'hot');
axis(ax2, 'image', 'off');
clim(ax2, [0 1]);

% 透明叠加设置
fg.AlphaData = abs(mapOriginal.Data(:,:,1)).^p;

 % 确保 ax2 的背景透明
ax2.Color = 'none'; 

cb = colorbar(ax2);
cb.Label.String = 'Correlation Coefficient';
cb.FontSize=18;

% 同步底层图像和顶层图像的位置
drawnow;
ax1.Position = ax2.Position;
    
% 链接坐标轴
linkaxes([ax1, ax2]);
    
addLines(LinReg.Cor,slice,X,Z,0.95,-1.75,1.10,-0.00,dx,dz);
% title('Correlation map');

%% bar
hold on
x1 = -2.5; x2 = -1.5;
line_y = 5.5 ;
short_line_height = 0.3 ;

% 横线
plot([x1 x2], [line_y line_y], 'w', 'LineWidth', 2);

text(mean([x1 x2]), line_y+0.5, '1mm', ...
        'FontSize', 16, 'FontWeight','bold','Color','w','HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

grid off
hold off
set(gca,'Fontsize',18)
hold off

%% atlas
function h = addLines(LL, ip, X,Z,xk,xb,yk,yb,dx,dz)
    L = LL{ip};
    hold on;
    nb = length(L);
    h = gobjects(nb, 1);
    bian=L{2};
    SIZE=max(bian)-min(bian);
    rx=(2*SIZE(2)/3)./127
    ry=SIZE(1)./113
    for ib = 2:nb
        x = L{ib};
        xx=x(:, 2)*dx./rx+X(1);
        yy=x(:, 1)./ry*dz+Z(1);
        xx=xx.*xk+xb;
        yy=yy.*yk+yb;
       h(ib) = plot(xx,yy, 'w:','MarkerSize',30,'LineWidth',1,'LineStyle','--');   %video
    end
end






