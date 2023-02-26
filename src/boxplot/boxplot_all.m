clc;clear;close all

load filter_dataSOCAT.mat
load filter_dataSOMFFN.mat
load filter_dataGLODAP.mat

%%
dataSOCAT = rmoutliers(dataSOCAT);
dataSOMFFN = rmoutliers(dataSOMFFN);
dataGLODAP = rmoutliers(dataGLODAP);

%%
f1 = figure('Name', 'Year comparision');
f1.Position(3:4) = [1400, 700];
hold on;

sub = subplot(1,3,1);
boxplot(dataSOCAT.data, dataSOCAT.year);
title("Year comparison of fCO2 from SOCAT data");

sub = subplot(1,3,2);
boxplot(dataSOMFFN.data, dataSOMFFN.year);
title("Year comparison of spCO2 from SOMFFN data");

sub = subplot(1,3,3);
boxplot(dataGLODAP.data, dataGLODAP.year);
title("Year comparision of fCO2 from GLODAP data");

%%
f1 = figure('Name', 'Month comparison');
f1.Position(3:4) = [1400, 700];
hold on

sub = subplot(1,3,1);
boxplot(dataSOCAT.data, dataSOCAT.month);
title("Month comparison of fCO2 from SOCAT data");

sub = subplot(1,3,2);
boxplot(dataSOMFFN.data, dataSOMFFN.month);
title("Month comparison of spCO2 from SOMFFN data");

sub = subplot(1,3,3);
boxplot(dataGLODAP.data, dataGLODAP.month);
title("Month comparison of fCO2 from GLODAP data");