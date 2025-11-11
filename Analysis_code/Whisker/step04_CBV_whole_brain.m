%% %% Correlation between doppler signal and stimulus %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

load Data\average.mat;
frame_rate=3.57;
lamda=1540/15e6;
dx=(lamda/3*1e3);
dz=(lamda/4*1e3);

Doppler = Data(:,:,:);

%% Temporal Normalization
DopplerM = mean(Doppler(:,:,1:120),3);
DopplerN = bsxfun(@minus,Doppler, DopplerM);
DopplerN = bsxfun(@rdivide,DopplerN, DopplerM);
DopplerM(find((DopplerM==0)))=NaN;


%% Calculation of the correlation map %%
Map=DopplerN;

%% Display

p=0.8; % data transparency compression
X=(-size(Map,2)/2+0.5:size(Map,2)/2-0.5)*(lamda/3*1e3);
Z=(0:size(Map,1)-1)*(lamda/4*1e3);
range=[min(X)-0.01 max(X)+0.01 min(Z)-0.01 max(Z)+0.01];
bin = 9;
step = 10;
v = VideoWriter('result\video.mp4','MPEG-4');  
v.Quality = 95;
v.FrameRate = 5;
open(v);   % 打开AVI文件

for k=1:step:size(DopplerN,3)-bin
    figure;
    Mapsum =sum(Map(:,:,k:k+bin),3)./(bin+1); 


    % Rendering background images
    DopplerFrame=sqrt(DopplerM);
    DopplerFrame=DopplerFrame-min(DopplerFrame(:));
    DopplerFrame=DopplerFrame./max(DopplerFrame(:));
    DopplerFrame(find(isnan(DopplerFrame)))=0;
    VesselsRGB=ind2rgb(1+floor(127*DopplerFrame),gray(128));

    bg=imagesc(X,Z,VesselsRGB);
    hold on
    
    fg=imagesc(X,Z,Mapsum);
    alpha(fg,abs(Mapsum).^p)
    caxis([0 0.3])
    colormap jet;
    colorbar

    if [k/frame_rate>=35 && k/frame_rate<=66]
        text(-2.5,0.2,[sprintf(' Sti')],'FontSize',14,'Color','w','FontWeight','bold');
    end

    text(-3.3,0.2,[sprintf('%5d',round(k/frame_rate)),'s'],'FontSize',14,'Color','w','FontWeight','bold');
%     colorbar('Color',[0 0 0]);
    set(gcf,'color','white');  
    set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],'Color',[1 1 1]);
    set(gca,'looseInset',[0 0 0 0])
    axis off
    axis equal tight
    axis(range);


    frame = getframe(gcf);   
    writeVideo(v, frame);   
    close(gcf)
    
end
hold off

% close AVI
close(v);
