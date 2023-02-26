clc;clear;close all

load SOCATv2022_NP_2.mat
load SOM_FFN_v2021.mat
load Glodap_co2sys.mat

%%
dataSOCAT = getSOCAT(socat);
dataSOMFFN = getSOMFFN(som_ffn);
dataGLODAP = Glodap;

%%
resultsSOCAT = cell(height(dataGLODAP), 5);
resultsSOMFFN = cell(height(dataGLODAP), 5);
resultsGLODAP = cell(height(dataGLODAP), 5);


for index = 1:height(dataGLODAP)

[dataSOCAT_value, longitude, latitude, year, month] = findData(dataSOCAT.longitude(index), ...
                             dataSOCAT.latitude(index), ...
                             dataSOCAT.year(index), ...
                             dataSOCAT.month(index), ...
                             dataSOCAT, dataSOMFFN, dataGLODAP);

[dataSOMFFN_value, longitude, latitude, year, month] = findData(dataSOMFFN.longitude(index), ...
                             dataSOMFFN.latitude(index), ...
                             dataSOMFFN.year(index), ...
                             dataSOMFFN.month(index), ...
                             dataSOCAT, dataSOMFFN, dataGLODAP);

[dataGLODAP_value, longitude, latitude, year, month] = findData(dataGLODAP.longitude(index), ...
                             dataGLODAP.latitude(index), ...
                             dataGLODAP.year(index), ...
                             dataGLODAP.month(index), ...
                             dataGLODAP, dataSOMFFN, dataGLODAP);

    resultsSOCAT{index, 1} = dataSOCAT_value;
    resultsSOCAT{index, 2} = longitude;
    resultsSOCAT{index, 3} = latitude;
    resultsSOCAT{index, 4} = year;
    resultsSOCAT{index, 5} = month;

    resultsSOMFFN{index, 1} = dataSOMFFN_value;
    resultsSOMFFN{index, 2} = longitude;
    resultsSOMFFN{index, 3} = latitude;
    resultsSOMFFN{index, 4} = year;
    resultsSOMFFN{index, 5} = month;
    
    resultsGLODAP{index, 1} = dataGLODAP_value;
    resultsGLODAP{index, 2} = longitude;
    resultsGLODAP{index, 3} = latitude;
    resultsGLODAP{index, 4} = year;
    resultsGLODAP{index, 5} = month;

end

%%
[nRows, nCols] = size(resultsSOCAT);
dataSOCAT = zeros(nRows, nCols);

for i = 1:nRows
    for j = 1:nCols
        curr_elem = resultsSOCAT{i,j};
        if isa(curr_elem, 'double')
            dataSOCAT(i,j) = curr_elem;
        elseif isa(curr_elem, 'single')
            dataSOCAT(i,j) = double(curr_elem);
        else
            dataSOCAT(i,j) = str2double(curr_elem);
        end
    end
end

dataSOCAT = array2table(dataSOCAT, 'VariableNames', {'data', 'longitude', 'latitude', 'year', 'month'});

%%
[nRows, nCols] = size(resultsSOMFFN);
dataSOMFFN = zeros(nRows, nCols);

for i = 1:nRows
    for j = 1:nCols
        curr_elem = resultsSOMFFN{i,j};
        if isa(curr_elem, 'double')
            dataSOMFFN(i,j) = curr_elem;
        elseif isa(curr_elem, 'single')
            dataSOMFFN(i,j) = double(curr_elem);
        else
            dataSOMFFN(i,j) = str2double(curr_elem);
        end
    end
end

dataSOMFFN = array2table(dataSOMFFN, 'VariableNames', {'data', 'longitude', 'latitude', 'year', 'month'});

%%
[nRows, nCols] = size(resultsGLODAP);
dataGLODAP = zeros(nRows, nCols);

for i = 1:nRows
    for j = 1:nCols
        curr_elem = resultsGLODAP{i,j};
        if isa(curr_elem, 'double')
            dataGLODAP(i,j) = curr_elem;
        elseif isa(curr_elem, 'single')
            dataGLODAP(i,j) = double(curr_elem);
        else
            dataGLODAP(i,j) = str2double(curr_elem);
        end
    end
end

dataGLODAP = array2table(dataGLODAP, 'VariableNames', {'data', 'longitude', 'latitude', 'year', 'month'});

%%

save('filter_dataSOCAT.mat', 'dataSOCAT')
save('filter_dataSOMFFN.mat', 'dataSOMFFN')
save('filter_dataGLODAP.mat', 'dataGLODAP')

%% function
function dataSOCAT = getSOCAT(socat)
    tmp1 = socat.data;
    data = tmp1.fCO2rec;
    year = tmp1.Time.Year;
    month = tmp1.Time.Month;
    longitude = tmp1.longitude;
    latitude = tmp1.latitude;
    tmp3 = table(data, longitude, latitude, year, month);
    tmp3.longitude = round(tmp3.longitude);
    tmp3.latitude = round(tmp3.latitude);

    dataSOCAT = tmp3;
    dataSOCAT = dataSOCAT(dataSOCAT.year < 2021 & dataSOCAT.year >= 1982, :);
end

function dataSOMFFN = getSOMFFN(som_ffn)
    k = numel(som_ffn.date);
    i = 1:k;
    tmp1 = som_ffn.spCO2(:, :, i);
    tmp2 = reshape(tmp1, [], 1);
    tmp2 = double(tmp2);
    lon = repmat(repmat(som_ffn.lon, 180, 1), 468, 1);
    lon = double(lon);
    lat = repmat(repelem(som_ffn.lat, 360, 1), 468, 1);
    lat = double(lat);
    year = repelem(som_ffn.date.Year(i), numel(tmp1(:, :, 1)), 1);
    month = repelem(som_ffn.date.Month(i), numel(tmp1(:, :, 1)), 1);

    tmp3 = table(tmp2, lon, lat, year, month);
    tmp4 = tmp3(tmp3.tmp2 < 1e+20, :);
    tmp4.Properties.VariableNames = {'data', 'longitude', 'latitude', 'year', 'month'};
    tmp4.longitude = round(tmp4.longitude);
    tmp4.latitude = round(tmp4.latitude);
    dataSOMFFN = tmp4;
end


function [data_value, longitude, latitude, year, month] = findData(longitude, latitude, year, month, dataSOCAT, dataSOMFFN, dataGLODAP)
    % Search for matching rows in each dataset in turn
    idx_SOCAT = find(dataSOCAT.longitude == longitude & dataSOCAT.latitude == latitude & ...
                     dataSOCAT.year == year & dataSOCAT.month == month);
    idx_SOMFFN = find(dataSOMFFN.longitude == longitude & dataSOMFFN.latitude == latitude & ...
                     dataSOMFFN.year == year & dataSOMFFN.month == month);
    idx_GLODAP = find(dataGLODAP.longitude == longitude & dataGLODAP.latitude == latitude & ...
                     dataGLODAP.year == year & dataGLODAP.month == month);
    
    % Return the first matching value found in the datasets
    if ~isempty(idx_SOCAT)
        data_value = dataSOCAT.data(idx_SOCAT(1));
        longitude = dataSOCAT.longitude(idx_SOCAT(1));
        latitude = dataSOCAT.latitude(idx_SOCAT(1));
        year = dataSOCAT.year(idx_SOCAT(1));
        month = dataSOCAT.month(idx_SOCAT(1));
    elseif ~isempty(idx_SOMFFN)
        data_value = dataSOMFFN.data(idx_SOMFFN(1));
        longitude = dataSOMFFN.longitude(idx_SOMFFN(1));
        latitude = dataSOMFFN.latitude(idx_SOMFFN(1));
        year = dataSOMFFN.year(idx_SOMFFN(1));
        month = dataSOMFFN.month(idx_SOMFFN(1));
    elseif ~isempty(idx_GLODAP)
        data_value = dataGLODAP.data(idx_GLODAP(1));
        longitude = dataGLODAP.longitude(idx_GLODAP(1));
        latitude = dataGLODAP.latitude(idx_GLODAP(1));
        year = dataGLODAP.year(idx_GLODAP(1));
        month = dataGLODAP.month(idx_GLODAP(1));
    else
        data_value = NaN;
        longitude = NaN;
        latitude = NaN;
        year = NaN;
        month = NaN;
    end
end
