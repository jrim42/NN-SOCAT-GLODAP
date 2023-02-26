clc;clear;close all

load SOM_FFN_v2021.mat
load Glodap.mat
%% dataSOMFFN을 GLODAP 기준으로 filtering
SOMFFN = getSOMFFN(som_ffn);


results = cell(height(Glodap), 5);

for index = 1:height(Glodap)
[data, longitude, latitude, year, month] = findData(Glodap.longitude(index), ...
Glodap.latitude(index), ...
Glodap.year(index), ...
Glodap.month(index), ...
SOMFFN);
results{index, 1} = data;
results{index, 2} = longitude;
results{index, 3} = latitude;
results{index, 4} = year;
results{index, 5} = month;
end


%% 빈 셀 해결 방법

tmp1 = ~cellfun(@isempty, results);
tmp2 = any(tmp1, 2);
data = results(tmp2, :);

%% cell 형태를 table 형태로 바꾼 후 dataSOMFFN 저장

[nRows, nCols] = size(data);
dataSOMFFN = zeros(nRows, nCols);

for i = 1:nRows
    for j = 1:nCols
        curr_elem = data{i,j};
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

save('dataSOMFFN_GLODAP.mat', "dataSOMFFN")


%% dataGLODAP을 위에서 만든 dataSOMFFN으로 filtering

results = cell(height(dataSOMFFN), 5);

for index = 1:height(dataSOMFFN)
[data, longitude, latitude, year, month] = finddata(dataSOMFFN.longitude(index), ...
dataSOMFFN.latitude(index), ...
dataSOMFFN.year(index), ...
dataSOMFFN.month(index), ...
Glodap);
results{index, 1} = data;
results{index, 2} = longitude;
results{index, 3} = latitude;
results{index, 4} = year;
results{index, 5} = month;
end

%% cell 형태를 table 형태로 바꾼 후 dataGLODAP 저장
% 새롭게 필터링한 results는 빈 셀이 없으므로 위의 빈 셀 제거 항목은 생략

[nRows, nCols] = size(results);
dataGLODAP = zeros(nRows, nCols);

for i = 1:nRows
    for j = 1:nCols
        curr_elem = results{i,j};
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

save('dataGLODAP.mat', "dataGLODAP")

%% function
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

function [data, longitude, latitude, year, month] = finddata(longitude, ...
latitude, ...
year, ...
month, ...
Glodap)
    match = find(Glodap.longitude == longitude & ...
                 Glodap.latitude == latitude & ...
                 Glodap.year == year & ...
                 Glodap.month == month);
    if ~isempty(match)
        data = Glodap.data(match(1));
        longitude = Glodap.longitude(match(1));
        latitude = Glodap.latitude(match(1));
        year = Glodap.year(match(1));
        month = Glodap.month(match(1));
    else
        data = [];
        longitude = [];
        latitude = [];
        year = [];
        month = [];
    end
end