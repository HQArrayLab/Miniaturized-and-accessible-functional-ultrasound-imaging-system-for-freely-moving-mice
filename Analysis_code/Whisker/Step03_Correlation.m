
%% Perform Pearson's correlation on whisker_dataset 

clear;
load Data\scanAverage.mat; 
load Data\dataAtlas.mat;
slice=149;
lamda=1540/15e6;
dx=(lamda/3*1e3);
dz=(lamda/4*1e3);
scanfus.Data=scanfus.Data;
Z=(scanfus.VoxelSize(1)/1e3)*[0:1:size(scanfus.Data,1)-1];
X=(scanfus.VoxelSize(2)/1e3)*[-size(scanfus.Data,2)/2+0.5:1:size(scanfus.Data,2)/2-0.5];
range=[min(X) max(X) min(Z) max(Z)];

T1= floor(5*3.57);         % Start of the stimulus.
T2= floor(36*3.57);          % End of the stimulus.
mapOriginal=mapCorrelation(scanfus, T1, T2);
mapOriginal.Data(find(mapOriginal.Data<0.23))=0;

%% Brain image
close all
figure(1);
[nz,nx,np,nt]=size(scanfus.Data); % data dimensions
temp=mean(squeeze(scanfus.Data(:,:,1,:)),3);
imagesc(X,Z,(temp.^0.25)./max(temp(:))); 
hold on
addLines(LinReg.Cor,slice,X,Z,1.05,-1.55,1.00,0.05,dx,dz);
axis('equal','tight');
axis off;
axis(range)
colormap hot;
colorbar
title('Brain image');
hold off

%% Correlation map
p=1.4;
figure(2)

Doppler=scanfus.Data(:,:,1,:);
DopplerM = mean(Doppler,4);
DopplerFrame=sqrt(DopplerM(:,:,1));
DopplerFrame=DopplerFrame-min(DopplerFrame(:));
DopplerFrame=DopplerFrame./max(DopplerFrame(:));
DopplerFrame(find(isnan(DopplerFrame)))=0;
VesselsRGB=ind2rgb(1+floor(127*DopplerFrame),gray(128));
bg=imagesc(X,Z,VesselsRGB);

hold on

fg=imagesc(X,Z,mapOriginal.Data(:,:,1));
alpha(fg,abs(mapOriginal.Data(:,:,1)).^p)
caxis([0 1.2]);
colormap hot;
colorbar('Color',[0 0 0]);
set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],'Color',[0 0 0]);
axis equal tight
axis off
axis(range)

    
addLines(LinReg.Cor,slice,X,Z,1.05,-1.55,1.00,0.05,dx,dz);
title('Correlation map');
hold off

%% atlas
function h = addLines(LL, ip, X,Z,xk,xb,yk,yb,dx,dz)
    L = LL{ip};
    hold on;
    nb = length(L);
    h = gobjects(nb, 1);
    bian=L{4};
    SIZE=max(bian)-min(bian);
    rx=(2*SIZE(2)/3)./185;
    ry=(SIZE(1))./251;
%     rx=1.65
%     ry=1.65
    for ib = 2:nb
        x = L{ib};
        xx=x(:, 2)*dx./rx+X(1);
        yy=x(:, 1)./ry*dz+Z(1);
        xx=xx.*xk+xb;
        yy=yy.*yk+yb;
       h(ib) = plot(xx,yy, 'w:','MarkerSize',30,'LineWidth',1.5);   
    end

    hold off
end






