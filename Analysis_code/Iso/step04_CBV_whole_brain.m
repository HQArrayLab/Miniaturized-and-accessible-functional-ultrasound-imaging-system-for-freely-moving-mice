%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear all
load Data\iso2.mat;
frame_rate=3.57;
fusplane.Data=Data;
lamda=1540/15e6;
dx=(0.05);
dz=(0.05);

Doppler = fusplane.Data(:,:,:);

%% Temporal Normalization
DopplerM = mean(Doppler(:,:,50:350),3);
DopplerN = bsxfun(@minus,Doppler, DopplerM);
DopplerN = bsxfun(@rdivide,DopplerN, DopplerM);
DopplerM(find((DopplerM==0)))=NaN;

Map=DopplerN;


p=0.8; % data transparency compression
X=(-size(Map,2)/2+0.5:size(Map,2)/2-0.5)*(0.05);
Z=(0:size(Map,1)-1)*(0.05);
range=[min(X)-0.01 max(X)+0.01 min(Z)-0.01 max(Z)+0.01];
bin = 9;
step = 10;
v = VideoWriter('result\video.mp4','MPEG-4');   
v.Quality = 95;
v.FrameRate = 5;
open(v);   % open AVI
i=0;
for k=1+bin:step:size(DopplerN,3)
    figure
    Mapsum =sum(Map(:,:,k-bin:k),3)./(bin+1); 

    DopplerFrame=sqrt(DopplerM);
    DopplerFrame=DopplerFrame-min(DopplerFrame(:));
    DopplerFrame=DopplerFrame./max(DopplerFrame(:));
    DopplerFrame(find(isnan(DopplerFrame)))=0;
    VesselsRGB=ind2rgb(1+floor(127*DopplerFrame),gray(128));

    bg=imagesc(X,Z,VesselsRGB);
    hold on

    fg=imagesc(X,Z,Mapsum);

    alpha(fg,abs(Mapsum).^p)
    caxis([0 1])

    colormap jet;

    if [k/frame_rate>=100 && k/frame_rate<=220]

        text(-2.0,0.2,[sprintf(' ISO ')],'FontSize',14,'Color','w','FontWeight','bold');
    
    end
    tt=round(k/frame_rate);
    text(-3.3,0.2,[sprintf('%5d',tt),'s'],'FontSize',14,'Color','w','FontWeight','bold');
    colorbar('Color',[0 0 0]);
    set(gcf,'color','white');  %%背景颜色
    set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],'Color',[1 1 1]);
    set(gca,'looseInset',[0 0 0 0]);
    set(gca,'Fontsize',18);

    axis off
    axis equal tight
    axis(range);



    frame = getframe(gcf);   
    writeVideo(v, frame);   
%     saveas(gcf,['result\',num2str(floor(k./frame_rate)),'s'],'tif')
%     saveas(gcf,['result\',num2str(floor(k./frame_rate)),'s'],'fig')
    close(gcf)
end
hold off

% close AVI
close(v);
