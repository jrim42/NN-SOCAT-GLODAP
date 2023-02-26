clc;
clear;
close all;

load SOM_FFN_v2021.mat;
load Glodapv2.2022_sys.mat;

%% path
addpath('/Users/cheonjiyeon/Documents/MATLAB/m_map/')

%%
som_ffn.lonGrd = som_ffn.lonGrd + 180;
som_ffn.latGrd = som_ffn.latGrd + 90;


%%
glodap.yearMin = min(glodap.data.Time.Year);
glodap.yearMax = max(glodap.data.Time.Year);
som_ffn.yearMin = min(som_ffn.date.Year);
som_ffn.yearMax = max(som_ffn.date.Year);

timeR = [max(glodap.yearMin, som_ffn.yearMin), min(glodap.yearMax, som_ffn.yearMax)];
year = input("> year: ");
while (year < timeR(1) || year > timeR(2))
    disp("< comparison unavailable: try again between 1982 ~ 2020");
    year = input("> year: "); 
end

%%
dataGLODAP = getGLODAP(year, glodap);
dataSOMFFN = getSOMFFN(year, som_ffn);
dataDiff = getDiff(dataSOMFFN, dataGLODAP);

%%
f = figure('Name', "SOM-FFN and GLODAP of " + num2str(year), 'NumberTitle', 'off');
f.Position(3:4) = [600, 1200];
hold on;

sub = subplot(3, 1, 1);
drawMap(dataGLODAP, glodap, sub, "GLODAP");
title("GLODAP of " + num2str(year) + " (fCO2)");

sub = subplot(3, 1, 2);
drawMap(dataSOMFFN, som_ffn, sub, "SOMFFN");
title("SOM-FFN of " + num2str(year) + " (spCO2)");

sub = subplot(3, 1, 3);
drawMap(dataDiff, glodap, sub, "diff");
title("difference");

%% ================= functions =================
function dataGLODAP = getGLODAP(year, glodap)
    tmp1 = glodap.data(glodap.data.Time.Year == year, :);
    tmp2 = timetable2table(tmp1, 'ConvertRowTimes', false);
    tmp2 = sortrows(tmp2);
    tmp2.longitude = round(tmp2.longitude);
    tmp2.latitude = round(tmp2.latitude);

    crd.lonMin = min(tmp2.longitude);
    crd.lonMax = max(tmp2.longitude);
    crd.latMin = min(tmp2.latitude);
    crd.latMax = max(tmp2.latitude);

    dataGLODAP = getAvg(crd, tmp2);
end

function dataGLODAP = getAvg(crd, t)  
    tmp = zeros(360, 180);         % matrix filled with zeros
    i = crd.lonMin;
    while i <= crd.lonMax
        j = crd.latMin;
        while j <= crd.latMax
            res = find(t.longitude == i & t.latitude == j);
            if height(res) > 0
                avg = sum(t.fCO2(res)) / height(res);
                tmp(i, j) = avg;
            else
                tmp(i, j) = 0;
            end
            j = j + 1;
        end
        i = i + 1;
    end
    dataGLODAP = tmp;
end

function dataSOMFFN = getSOMFFN(year, som_ffn)
    start = (year - 1982) * 12 + 1;
    range = start:(start + 11);
    tmp1 = som_ffn.spCO2(:, :, range);
    dataSOMFFN = mean(tmp1, 3);
end

function dataDiff = getDiff(dataSOMFFN, dataGLODAP)
    tmp = zeros(360, 180);
    i = 1;
    while i <= 360
        j = 1;
        while j <= 180
            val1 = dataGLODAP(i, j);
            val2 = dataSOMFFN(i, j);
            if val1 > 0 && val2 > 1
                tmp(i, j) = abs(val1 - val2);
            else
                tmp(i, j) = -999;
            end
            j = j + 1;
        end
        i = i + 1;
    end
    dataDiff = tmp;
end

function drawMap(data, proj, sub, type)
    lonNP = [130, 245];
    latNP = [25, 65];

    m_proj('miller', 'lon', lonNP, 'lat', latNP);
    m_pcolor(proj.lonGrd, proj.latGrd, data);
    m_coast('patch', [.6 .6 .6]);   
    m_grid('tickdir', 'in', 'linewi', 2);

    h = colorbar;
    h.Location = 'southoutside';
    h.Box = 'on';
    set(h, 'tickdir', 'out');

    if type == "diff"
        cmap = [flipud(m_colmap('water', 3)); m_colmap('BOD')];
        colormap(sub, cmap);
        clim([0, 120]);    
        set(get(h, 'ylabel'), 'String', 'Absolute value difference');
    elseif type == "SOMFFN"
        cmap = [flipud(m_colmap('water', 3)); m_colmap('jet')];
        colormap(sub, cmap);
        clim([300, 450]);    
        set(get(h, 'ylabel'), 'String', 'μatm');
    else
        cmap = [flipud(m_colmap('water', 3)); m_colmap('jet')];
        colormap(sub, cmap);
        clim([100, 800]);    
        set(get(h, 'ylabel'), 'String', 'μatm');
    end
end