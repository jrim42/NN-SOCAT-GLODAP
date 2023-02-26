%%
clc;
clear;
close all;

load ../../data/SOM_FFN_v2021.mat;
load ../../data/SOCATv2022_NP_2.mat;

%%
som_ffn.lonGrd = som_ffn.lonGrd + 180;
som_ffn.latGrd = som_ffn.latGrd + 90;

socat.yearMin = min(socat.data.Time.Year);
socat.yearMax = max(socat.data.Time.Year);
som_ffn.yearMin = min(som_ffn.date.Year);
som_ffn.yearMax = max(som_ffn.date.Year);
timeR = [max(socat.yearMin, som_ffn.yearMin), 
         min(socat.yearMax, som_ffn.yearMax)];

%%
setting = getYear(timeR, socat);

%%
f1 = figure('Name', "yearly comparison of SOM-FFN and SOCAT", ...
           'NumberTitle', 'off');
f1.Position(3:4) = [1200, 600];
hold on;

%%
dataSOCAT = getSOCAT(setting, socat);
dataSOMFFN = getSOMFFN(setting, som_ffn);
dataDiff1 = getDiff2(dataSOMFFN, dataSOCAT);

setting.yearStr = num2str(setting.startYear) + " ~ " + num2str(setting.endYear);

sub = subplot(2, 3, 1);
drawMap(dataSOMFFN, som_ffn, sub, "SOMFFN");
title(setting.yearStr + " SOM-FFN");

sub = subplot(2, 3, 2);
drawMap(dataSOCAT, socat, sub, "SOCAT");
title(setting.yearStr + " SOCAT");

sub = subplot(2, 3, 3);
drawMap(dataDiff1, socat, sub, "diff");
title("difference");

%%
res = parseDiff(setting, dataDiff1);
res = getDiffTable(dataDiff1, res);

sub = subplot(2, 3, 4:5);
drawHistogram(res, setting);

res = filterDiff(res);
dataDiff2 = dataDiff1;
sig = find(dataDiff2 >= res.rangeMin & dataDiff2 <= res.rangeMax);
dataDiff2(sig) = -999;
sub = subplot(2, 3, 6);
drawMap(dataDiff2, socat, sub, "diff");
title("filtered difference");

%% ============================= functions (1) =============================
function setting = getYear(timeR, socat)
    disp("< enter the year between 1995 ~ 2020");
    startYear = input("> begin: ");
    while (startYear < timeR(1) || startYear > timeR(2))
        disp("< wrong input. try again.");
        startYear = input("> begin: ");
    end
    endYear = input("> end: ");
    while (endYear < startYear || endYear > timeR(2))
        disp("< wrong input. try again.");
        endYear = input("> end: ");
    end
    setting.startYear = startYear;
    setting.endYear = endYear;
    setting.yearRange = [startYear, endYear];
end

%% ============================= functions (2) =============================
function dataSOCAT = getSOCAT(setting, socat)
    tmp1 = socat.data(socat.data.Time.Year >= setting.startYear & ...
                      socat.data.Time.Year <= setting.endYear, :);
    tmp2 = timetable2table(tmp1, 'ConvertRowTimes', false);
    tmp2 = sortrows(tmp2);
    tmp2.longitude = round(tmp2.longitude);
    tmp2.latitude = round(tmp2.latitude);

    crd.lonMin = min(tmp2.longitude);
    crd.lonMax = max(tmp2.longitude);
    crd.latMin = min(tmp2.latitude);
    crd.latMax = max(tmp2.latitude);

    dataSOCAT = getAvg(crd, tmp2);
end

function dataSOCAT = getAvg(crd, t)  
    tmp = zeros(360, 180);
    i = crd.lonMin;
    while i <= crd.lonMax
        j = crd.latMin;
        while j <= crd.latMax
            res = find(t.longitude == i & t.latitude == j);
            if height(res) > 0
                avg = sum(t.fCO2rec(res)) / height(res);
                tmp(i, j) = avg;
            else
                tmp(i, j) = 0;
            end
            j = j + 1;
        end
        i = i + 1;
    end
    dataSOCAT = tmp;
end

%% ============================= functions (3) =============================
function dataSOMFFN = getSOMFFN(setting, som_ffn)
    start = (setting.startYear - 1982) * 12 + 1;
    finish = (setting.endYear - 1982) * 12 + 12;
    range = start:finish;
    tmp = som_ffn.spCO2(:, :, range);
    dataSOMFFN = mean(tmp, 3);
end

%% ============================= functions (4) =============================
function dataDiff1 = getDiff1(dataSOMFFN, dataSOCAT)
    tmp = zeros(360, 180);
    i = 1;
    while i <= 360
        j = 1;
        while j <= 180
            val1 = dataSOCAT(i, j);
            val2 = dataSOMFFN(i, j);
            if val1 > 0 && val2 > 1
                tmp(i, j) = (val1 - val2) / val1;
            else
                tmp(i, j) = -999;
            end
            j = j + 1;
        end
        i = i + 1;
    end
    dataDiff1 = tmp;
end

function dataDiff1 = getDiff2(dataSOMFFN, dataSOCAT)
    tmp = zeros(360, 180);
    i = 1;
    while i <= 360
        j = 1;
        while j <= 180
            val1 = dataSOCAT(i, j);
            val2 = dataSOMFFN(i, j);
            if val1 > 0 && val2 > 1
                tmp(i, j) = val1 - val2;
            else
                tmp(i, j) = -999;
            end
            j = j + 1;
        end
        i = i + 1;
    end
    dataDiff1 = tmp;
end

function res = parseDiff(setting, dataDiff1)
    dataDiff1(dataDiff1 == -999) = NaN;
    disp("=========================================");
    disp(" difference between " + setting.yearStr + " (μatm)");
    disp("-----------------------------------------");
    res.diffMin = min(dataDiff1, [], 'all', 'omitnan');
    res.diffMax = max(dataDiff1, [], 'all', 'omitnan');
    res.diffMean = mean(dataDiff1, 'all', 'omitnan');
    disp("    min  =  " + num2str(res.diffMin));
    disp("    max  =  " + num2str(res.diffMax));
    disp("    mean =  " + num2str(res.diffMean));
    disp("=========================================");
end

function res = getDiffTable(dataDiff1, res)
    diff = reshape(dataDiff1, [], 1);
    diffLat = zeros(360 * 180, 1);
    diffLon = zeros(360 * 180, 1);
    i = 1;
    cnt = 1;
    while i <= 180
        j = 1;
        while j <=360
            diffLat(cnt, 1) = i;
            diffLon(cnt, 1) = j;
            j = j + 1;
            cnt = cnt + 1;
        end
        i = i + 1;
    end

    dataDiff2 = table(diffLat, diffLon, diff);
    sig = find(dataDiff2.diff ~= -999);
    dataDiff3 = dataDiff2(sig, :);
    dataDiff3 = renamevars(dataDiff3, ["diffLat", "diffLon", "diff"], ...
                                    ["lat", "lon", "diff"]);
    res.data = dataDiff3;
end

function res = filterDiff(res)
    res.rangeMin = input("> diff min: ");
    res.rangeMax = input("> diff max: ");
    sig = find(res.data.diff <= res.rangeMin | res.data.diff >= res.rangeMax);
    res.filtered = res.data(sig, :);
end

%% ============================= functions (5) =============================
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
        % clim([-200, 200]);    
        clim([-150, 150]);    
        set(get(h, 'ylabel'), 'String', 'difference [μatm]');
    else
        cmap = [flipud(m_colmap('water', 3)); m_colmap('jet')];
        colormap(sub, cmap);
        clim([300, 450]);    
        set(get(h, 'ylabel'), 'String', 'μatm');
    end
end

function drawHistogram(res, setting)
    histogram(res.data.diff);
    title(setting.yearStr + " NN-SOCAT difference");
    xlabel("difference value");
    ylabel("frequency");
end