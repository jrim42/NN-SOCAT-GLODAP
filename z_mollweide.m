%%
clc;
clear;
close all;

addpath('/Users/jrim/Desktop/mat/MPI_SOM-FFN_v2021/');
addpath('/Applications/MATLAB_R2022b.app/toolbox/m_map');
addpath('/Applications/MATLAB_R2022b.app/toolbox/cbarrow');

%% nc file
src = 'MPI-SOM_FFN_v2021_NCEI_OCADS.nc';
finfo1 = ncinfo(src);
lon = ncread(src, 'lon');          % -180 ~ 180
lat = ncread(src, 'lat');          % -90 ~ 90
spco2 = ncread(src, 'spco2_smoothed');

%% getting input and setting data
[year, month] = getInput();

[latM, lonM] = meshgrid(lat, lon);
latM2 = [latM; latM];
lonM2 = [lonM; lonM + 360];
spco2 = squeeze(spco2);
start = (year - 1982) * 12 + month;
spco2_tmp = [spco2(:, :, start); spco2(:, :, start)];

setFigure();
drawMap(lonM2, latM2, spco2_tmp);
setColorbar();

%% ============================= functions =============================
function [year, month] = getInput()
    disp("< enter the year between 1982 ~ 2020");
    year = input("> year: ");
    while (year < 1982|| year > 2020)
        disp("< wrong input. try again.");
        year = input("> year: ");
    end
    disp("< enter the month between 1 ~ 12");
    month = input("> month: ");
    while (month < 1|| month > 12)
        disp("< wrong input. try again.");
        month = input("> month: ");
    end
end

function setFigure()
    f = figure('Name', ' sea surface pCO2 product', ...
           'NumberTitle', 'off');
    f.Position(3:4) = [1000, 500];

    title('2-step neural network sea surface pCO2 output');
    set(gca, 'Units', 'normalized')
    titleHandle = get(gca ,'Title');
    titlePos = get(titleHandle , 'position');
    titlePos = titlePos + [0.5, 0.1, 0];
    set(titleHandle, 'position', titlePos);
end

function drawMap(lonM2, latM2, spco2_tmp)
    lonS = [-100, 43; -75, 20; 20, 145; 43, 100; 145, 295; 100, 295];
    latS = [   0, 90;  -90, 0;  -90, 0;   0, 90;   -90, 0;    0, 90];

    hold on;
    for i = 1 : 6
        m_proj('mollweide', 'lon', lonS(i, :), 'lat', latS(i, :));
        m_pcolor(lonM2, latM2, spco2_tmp);
        m_contourf(lonM2, latM2, spco2_tmp, 300:10:450, 'color', 'k');    % contour
        m_coast('patch', [.6 .6 .6]);                                   % continent
        m_grid('fontsize', 10, ...
            'xticklabels', [], 'xtick', -180:30:360, ...
            'yticklabels', [], 'ytick', -80:20:80, ...
            'tickdir', 'out', ...
            'linest', '-', 'color', [.4 .4 .4]);
    end
    set(gca, 'xlimmode', 'auto', 'ylimmode', 'auto');
end

function setColorbar()
    colormap(parula(15));   % dividing colorbar
    h = colorbar;
    h.Location = 'southoutside';
    h.Position = [0.25 0.1 0.5 0.02];
    h.Box = 'on';
    clim([300, 450]);
    cbarrow;                % function for pointy-end colorbar
    set(h, 'tickdir', 'out');
    set(get(h, 'ylabel'), 'String', '[μatm]');
end