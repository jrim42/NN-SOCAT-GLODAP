clc;
clear;
close all;

src = 'sst.mnmean.nc';

finfo = ncinfo(src);

lon = ncread(src, 'lon');          % 0 ~ 360
lat = ncread(src, 'lat');          % -90 ~ 90
sst = ncread(src, 'sst');

[latM, lonM] = meshgrid(lat, lon);

[dateY, dateM] = meshgrid(1981:2023, 1:12);
dateYVec = reshape(dateY, [], 1);
dateMVec = reshape(dateM, [], 1);

date = table(dateYVec, dateMVec);
date([506:516], :) = [];
date([1:11], :) = [];

%% ========================== saving data ==========================
mnmean.date = date;
mnmean.lon = lon;
mnmean.lat = lat;
mnmean.lonGrd = lonM;
mnmean.latGrd = latM;
mnmean.sst = sst;
save("NOAA_SST", "mnmean");
%% ==================================================================
