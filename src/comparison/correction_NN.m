clc;
clear;
close all;

load ../../data/SOM_FFN_v2021.mat;
load ../../data/SOCATv2022_NP_2.mat;
load ../../data/NOAA_SST.mat;

% pCO2(nn) = pCO2(SOCAT) * exp(0.0322 * (Tnn - Tsocat))

sstTime = datetime(mnmean.date.dateYVec, mnmean.date.dateMVec, 15);
sstTime.Format = 'yyyy-MM-dd';

%%