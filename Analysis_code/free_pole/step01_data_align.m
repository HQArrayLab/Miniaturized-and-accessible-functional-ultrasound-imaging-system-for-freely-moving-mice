clear;
clc;

load Data\freepole.mat;
load Data\T.mat;

fusplane.Data=PDI_Data;


data1=fusplane.Data;
framerate=3.57;
t1=20;
t2=40;
%% average
Data_1= data1(:,:,floor((T_start(1)-t1)*framerate):floor((T_start(1)+t2)*framerate));
Data_2= data1(:,:,floor((T_start(2)-t1)*framerate):floor((T_start(2)+t2)*framerate));
Data_3= data1(:,:,floor((T_start(3)-t1)*framerate):floor((T_start(3)+t2)*framerate)-1);
Data_4= data1(:,:,floor((T_start(4)-t1)*framerate):floor((T_start(4)+t2)*framerate));
Data_5= data1(:,:,floor((T_start(5)-t1)*framerate):floor((T_start(5)+t2)*framerate));
Data_6= data1(:,:,floor((T_start(6)-t1)*framerate):floor((T_start(6)+t2)*framerate));
Data_average=(Data_1+Data_2+Data_3+Data_4+Data_5+Data_6)./5;


save Data\Data_singletrials.mat Data_1 Data_2 Data_3 Data_4 Data_5 Data_6;