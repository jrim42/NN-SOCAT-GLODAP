clc;clear;close all

load SOCATv2022_NP_2.mat
load SOM_FFN_v2021.mat


dataSOCAT = getSOCAT(socat);
SOMFFN = getSOMFFN(som_ffn);


%%
results = cell(height(dataSOCAT), 5);

for index = 1:height(dataSOCAT)
[data, longitude, latitude, year, month] = findData(dataSOCAT.longitude(index), ...
dataSOCAT.latitude(index), ...
dataSOCAT.year(index), ...
dataSOCAT.month(index), ...
SOMFFN);
results{index, 1} = data;
results{index, 2} = longitude;
results{index, 3} = latitude;
results{index, 4} = year;
results{index, 5} = month;
end

dataSOMFFN = results;

%%

% Get the number of rows and columns in the cell array
[nRows, nCols] = size(results);

% Initialize the table with zeros
dataSOMFFN = zeros(nRows, nCols);

% Loop through each element in the cell array
for i = 1:nRows
    for j = 1:nCols
        % Get the current element
        curr_elem = results{i,j};
        
        % Check the type of the data
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


save('dataSOMFFN.mat', 'dataSOMFFN')
save('dataSOCAT.mat', 'dataSOCAT')
%% function
function [data, longitude, latitude, year, month] = findData(longitude, ...
latitude, ...
year, ...
month, ...
SOMFFN)
    match = find(SOMFFN.longitude == longitude & ...
                 SOMFFN.latitude == latitude & ...
                 SOMFFN.year == year & ...
                 SOMFFN.month == month);
    if ~isempty(match)
        data = SOMFFN.data(match(1));
        longitude = SOMFFN.longitude(match(1));
        latitude = SOMFFN.latitude(match(1));
        year = SOMFFN.year(match(1));
        month = SOMFFN.month(match(1));
    else
        data = [];
        longitude = [];
        latitude = [];
        year = [];
        month = [];
    end
end


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


function SOMFFN = getSOMFFN(som_ffn)
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
    SOMFFN = tmp4;
end
