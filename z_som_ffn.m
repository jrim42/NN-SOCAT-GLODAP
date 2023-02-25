%%
clc;
clear;
close all;

addpath('/Users/jrim/Desktop/mat/MPI_SOM-FFN_v2021/');
addpath('/Applications/MATLAB_R2022b.app/toolbox/m_map');
addpath('/Applications/MATLAB_R2022b.app/toolbox/cbarrow');

%% nc file
src = 'MPI-SOM_FFN_v2021_NCEI_OCADS.nc';

finfo = ncinfo(src);

lon = ncread(src, 'lon');          % -180 ~ 180
lat = ncread(src, 'lat');          % -90 ~ 90
date = ncread(src, 'date');
spco2 = ncread(src, 'spco2_raw');

%% data handling
lonNP = [132, 243];
latNP = [27, 63];

[latM, lonM] = meshgrid(lat, lon);
latM2 = [latM; latM];
lonM2 = [lonM; lonM + 360];
spco2 = squeeze(spco2);

d = table(datetime(date(1,:), date(2,:), date(3,:)));
d2 = splitvars(d);
d3 = table2array(d2)';
d3.Format = "yyyy-MM-dd";
clear d;
clear d2;
clear date;

%% =================================== saving data ===================================
som_ffn.date = d3;
som_ffn.lon = lon + 180;
som_ffn.lat = lat + 90;
som_ffn.lonGrd = lonM;
som_ffn.latGrd = latM;
som_ffn.spCO2 = spco2;
save("SOM_FFN_v2021", "som_ffn");
%% ====================================================================================


%% figure setting
f = figure('Name', 'SOM-FFN: sea surface pCO2 product', ...
           'NumberTitle', 'off');
f.Position(3:4) = [600, 800];
hold on;

%%
years = 2019:2020;
len = width(years);
i = 1;
while i <= len
    start = (years(i) - 1982) * 12 + 1;
    range = start:(start + 11);
    spco2_selected = spco2(:, :, range);
    spco2_mean = mean(spco2_selected, 3);
    spco2_tmp = [spco2_mean; spco2_mean];

    nexttile;
    m_proj('miller', 'lon', lonNP, 'lat', latNP); 
    m_pcolor(lonM2, latM2, spco2_tmp);
    m_coast('patch', [.6 .6 .6]);   
    
    m_grid('tickdir', 'in', 'linewi', 2);
        
    colormap([m_colmap('jet'); m_colmap('water', 3)]);
    title(num2str(years(i)));
    clim([300, 450]);
    
    h = colorbar;
    h.Location = 'southoutside';
    h.Box = 'on';
    set(h, 'tickdir', 'out');
    set(get(h, 'ylabel'), 'String', 'spCO2 [μatm]');

    i = i + 1;
end







