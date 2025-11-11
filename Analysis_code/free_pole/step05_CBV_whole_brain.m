%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
load Data\Data_singletrials_correct.mat;
Data_average= (Data_cor_1+Data_cor_2+Data_cor_3+Data_cor_4+Data_cor_5+Data_cor_6)./6;


% load data_temp\roi_mask_video.mat;
frame_rate=3.57;
fusplane.Data=Data_average(1:150,1:115,:);%.*roi_mask;
lamda=1540/15e6;
dx=(0.05);
dz=(0.05);

Doppler = fusplane.Data(:,:,:);

%% Temporal Normalization
DopplerM = mean(Doppler(:,:,1:35),3);
DopplerN = bsxfun(@minus,Doppler, DopplerM);
DopplerN = bsxfun(@rdivide,DopplerN, DopplerM);
DopplerM(find((DopplerM==0)))=NaN;


%% Calculation of the correlation map %%
Map=DopplerN;

%% Display
p=0.8; % data transparency compression
X=(-size(Map,2)/2+0.5:size(Map,2)/2-0.5)*(0.05);
Z=(0:size(Map,1)-1)*(0.05);
range=[min(X)-0.01 max(X)+0.01 min(Z)-0.01 max(Z)+0.01];
% Mapsum = Map(:,:,1);
bin = 3;
step = 4;
v = VideoWriter('result\test.mp4','MPEG-4');   
v.Quality = 95;
v.FrameRate = 2;
open(v);   
i=0;
for k=1+bin:step:size(DopplerN,3)
    figure
    
    Mapsum =sum(Map(:,:,k-bin:k),3)./(bin+1);
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
    caxis([0 0.5])

    colormap jet;

    if [k/frame_rate>=20 && k/frame_rate<=30]

        text(-2.2,0.2,[sprintf(' On pole')],'FontSize',14,'Color','w','FontWeight','bold');
    end
    tt=round(k/frame_rate);
    text(-3.1,0.2,[sprintf('%5d',tt),'s'],'FontSize',14,'Color','w','FontWeight','bold');
    colorbar('Color',[0 0 0]);
    set(gcf,'color','white');  
    set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],'Color',[1 1 1]);
    set(gca,'looseInset',[0 0 0 0])
    set(gca,'Fontsize',18);

    axis off
    axis equal tight
    axis(range);


    frame = getframe(gcf);   
    writeVideo(v, frame);   
%     saveas(gcf,['result\simply\',num2str(floor(k./frame_rate)),'s'],'tif')
%     saveas(gcf,['result\simply\',num2str(floor(k./frame_rate)),'s'],'fig')
    close(gcf)
end
hold off

% close AVI
close(v);
