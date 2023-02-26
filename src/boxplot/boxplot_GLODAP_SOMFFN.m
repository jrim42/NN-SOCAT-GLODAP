clc;clear;close all

load dataSOMFFN_GLODAP.mat
load dataGLODAP.mat

%%
dataGLODAP = rmoutliers(dataGLODAP);
dataSOMFFN = rmoutliers(dataSOMFFN);

f1 = figure('Name', 'Year comparision');
f1.Position(3:4) = [1200, 600];
hold on;

sub = subplot(1,2,1);
boxplot(dataSOMFFN.data, dataSOMFFN.year);
title("Year comparison of spCO2 from SOMFFN data");

sub = subplot(1,2,2);
boxplot(dataGLODAP.data, dataGLODAP.year);
title("Year comparision of fCO2 from GLODAP data");

%%
f2 = figure('Name', 'Month comaprison');
f2.Position(3:4) = [1200, 600];
hold on;

sub = subplot(1,2,1);
boxplot(dataSOMFFN.data, dataSOMFFN.month);
title("Month comparison of spCO2 from SOMFFN data");

sub = subplot(1,2,2);
boxplot(dataGLODAP.data, dataGLODAP.month);
title("Month comparison of fCO2 from GLODAP data");
