%% run this code after running Read_SOCATv3_v2022.m
    % you must select variables for datetime and fCO2
    % lon = 0 ~ 360
    % lat = 0 ~ 180   
    % run Read_SOCATv3_v2022.m;
%% or load mat file
clc;
clear;
close all;

load SOCATv2022_NP.mat

%% data into table form
d = [yr, mon, day, hh, mm, ss];
TT1 = timetable(datetime(d(:,1), d(:,2), d(:,3), d(:,4), d(:,5), d(:,6)), ...
           longitude, latitude, fCO2rec, QC_Flag);
clear yr mon day hh mm ss;

%% filtering QC
TT1.QC_Flag = categorical(TT1.QC_Flag);
% res = find(TT1.QC_Flag ~= 'A');
res = find(TT1.QC_Flag ~= 'A' & TT1.QC_Flag ~= 'B');
TT1(res, :) = [];

TT1 = sortrows(TT1, 'Time');
TT1.Time.Format = "yyyy-MM-dd HH:mm:ss";

%% lon and lats
coord.lon = 1:360;
coord.lat = 1:180;
[grd.latGrd, grd.lonGrd] = meshgrid(coord.lat, coord.lon);

%% =================================== saving data ===================================
socat.data = TT1;
socat.lon = coord.lon';
socat.lat = coord.lat';
socat.lonGrd = grd.lonGrd;
socat.latGrd = grd.latGrd;
save("SOCATv2022_NP_2", "socat");
%% ====================================================================================

%%
TT1.longitude = round(TT1.longitude, 0);
TT1.latitude = round(TT1.latitude, 0);

%% setting figure
f = figure('Name', "SOCAT: fCO2 rec", ...
           'NumberTitle', 'off');
f.Position(3:4) = [600, 800];
hold on;

%% setting (time)tables
year = 2019:2020;        % change it and try something else
i = 1;
len = width(year);
while i <= len
    TT2 = TT1(TT1.Time.Year == year(i), :);
    T1 = timetable2table(TT2, 'ConvertRowTimes', false);
    T1 = sortrows(T1);

    coord.lonMin = min(T1.longitude);
    coord.lonMax = max(T1.longitude);
    coord.latMin = min(T1.latitude);
    coord.latMax = max(T1.latitude);
    coord.lonR = [132, 243];
    coord.latR = [27, 63];
    
    fMin = min(T1.fCO2rec);
    fMax = max(T1.fCO2rec);

    % calculating average fCO2 value
    grd.fGrd = getAvg(coord, T1);
    drawMap(coord, grd);
    title(num2str(year(i)));
%     clim([fMin, fMax]);
    clim([200, 650]);

    i = i + 1;
end

%% calculating
function fGrd = getAvg(coord, T1)
    fGrd = zeros(360, 180);         % matrix filled with zeros
    j = coord.lonMin;
    while j <= coord.lonMax
        k = coord.latMin;
        while k <= coord.latMax
            res = find(T1.longitude == j & T1.latitude == k);
            if height(res) > 0
                avg = sum(T1.fCO2rec(res)) / height(res);
                fGrd(j, k) = avg;
            else
                fGrd(j, k) = 0;
            end
            k = k + 1;
        end
        j = j + 1;
    end
end

%% drawing map
function drawMap(coord, grd)
    nexttile;
    m_proj('miller', 'lon', coord.lonR, 'lat', coord.latR); 
    m_pcolor(grd.lonGrd, grd.latGrd, grd.fGrd);
    m_coast('patch', [.6 .6 .6]);   
    
    m_grid('tickdir', 'in', 'linewi', 2);
    colormap([flipud(m_colmap('water', 3)); m_colmap('jet')]);
    
    h = colorbar;
    h.Location = 'southoutside';
    h.Box = 'on';
    set(h, 'tickdir', 'out');
    set(get(h, 'ylabel'), 'String', 'fCO2 rec [μatm]');
end
