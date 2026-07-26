%% %% Correlation between doppler signal and stimulus %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

load Data\average.mat;
load Data\roi_mask_video.mat;
load Data\dataAtlas.mat;
slice=139;
frame_rate=3.57;
lamda=1540/15e6;
dx=0.05;
dz=0.05;

Doppler = Data(55:end,15:end,:).*roi_mask;

%% Temporal Normalization
DopplerM = mean(Doppler(:,:,1:50),3);
DopplerM(find((DopplerM==0)))=NaN;
DopplerN = bsxfun(@minus,Doppler, DopplerM);
DopplerN = bsxfun(@rdivide,DopplerN, DopplerM);



%% Calculation of the correlation map %%
Map=DopplerN;

%% Display

p=0.8; % data transparency compression
X=(-size(Map,2)/2+0.5:size(Map,2)/2-0.5)*(0.05);
Z=(0:size(Map,1)-1)*(0.05);
range=[min(X)-0.01 max(X)+0.01 min(Z)-0.01 max(Z)+0.01];
bin = 3;
step = 6;
v = VideoWriter('result\video.mp4','MPEG-4');  
v.Quality = 95;
v.FrameRate = 2;
open(v);   % 打开AVI文件

for k=1+bin:step:size(DopplerN,3)-bin
    figure;
    Mapsum =mean(Map(:,:,k-bin:k+bin),3);
    Mapsum = medfilt2(Mapsum);

    DopplerM_temp = DopplerM.^0.16;
    VesselsRGB = DopplerM_temp./max(DopplerM_temp(:));
    
    ax1 = axes;
    bg=imagesc(ax1,X,Z,VesselsRGB);
    colormap(ax1, 'gray');
    axis(ax1, 'image', 'off');

    ax2 = axes;
    fg=imagesc(ax2,X,Z,Mapsum);
    colormap(ax2, 'jet');
    axis(ax2, 'image', 'off');
    clim(ax2, [0 0.5]);

    % 透明叠加设置
    alpha_mask = zeros(size(Mapsum));
    valid_pixels = (Mapsum>0.15)&roi_mask;
    alpha_mask(valid_pixels) = 0.5;
    fg.AlphaData = alpha_mask;

    % 确保 ax2 的背景透明
    ax2.Color = 'none'; 

    cb = colorbar(ax2);
    cb.Label.String = '\Delta CBV (%)';
    cb.FontSize=18;
    cb.Ticks = 0:0.1:0.5;
    cb.TickLabels = 0:10:50;

    % 同步底层图像和顶层图像的位置
    drawnow;
    ax1.Position = ax2.Position;
    
    % 链接坐标轴
    linkaxes([ax1, ax2]);
    
    addLines(LinReg.Cor,slice,X,Z,0.95,-1.75,1.10,-0.00,dx,dz);

    if [k/frame_rate>=20 && k/frame_rate<=40]
        text(-2.2,0.2,[sprintf('  Sti')],'FontSize',14,'Color','w','FontWeight','bold');
    end

    text(-3,0.2,[sprintf('%5d',round(k/frame_rate)),'s'],'FontSize',14,'Color','w','FontWeight','bold');
    set(gcf,'color','white');  
    set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],'Color',[1 1 1]);
    axis off
    axis equal tight
    axis(range);


    %% bar
    hold on
    x1 = -2.5; x2 = -1.5;
    line_y = 5.5 ;
     short_line_height = 0.3 ;

    % 横线
    plot([x1 x2], [line_y line_y], 'w', 'LineWidth', 2);

    text(mean([x1 x2]), line_y+0.5, '1mm', ...
        'FontSize', 14, 'FontWeight','bold','Color','w','HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

    hold off

    frame = getframe(gcf);   
    writeVideo(v, frame);   
    
    close(gcf)
end


% close AVI
close(v);

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