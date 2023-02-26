clc;clear;close all

load SOCATv2022_NP_2.mat
load SOM_FFN_v2021.mat

%%
data_SOCAT = get_SOCAT(socat);
data_SOMFFN = get_SOMFFN(som_ffn);

f = figure('Name', 'Year comparision');
f.Position(3:4) = [1200, 600];
hold on;

sub = subplot(1,2,1);
boxplot(data_SOCAT.fCO2, data_SOCAT.Year);
title("Year comparison of fCO2 from SOCAT data");

sub = subplot(1,2,2);
boxplot(data_SOMFFN.spCO2, data_SOMFFN.Year);
title("Year comparision of spCO2 from SOMFFN data");

%% t-test
[h,p,ci,stats] = ttest2(data_SOCAT{:, 'Year'}, ...
                           data_SOMFFN{:, 'Year'}, ...
                           'Vartype', 'unequal')

%% function

function data_SOCAT = get_SOCAT(socat)
    Year = double(socat.data.Time.Year);
    fCO2 = double(socat.data.fCO2rec);
    tmp = table(Year, fCO2);
    data_SOCAT = rmoutliers(tmp);

end


function data_SOMFFN = get_SOMFFN(som_ffn)
    k = numel(som_ffn.date);
    i = 1:k;
    tmp1 = som_ffn.spCO2(:, :, i);
    tmp2 = reshape(tmp1, [], 1);
    tmp3 = repelem(som_ffn.date.Year(i), numel(tmp1(:, :, 1)));
    tmp4 = table(tmp3, tmp2);
    tmp5 = tmp4(tmp4.tmp2 < 1e+20,:);
    tmp5.Properties.VariableNames = {'Year', 'spCO2'};
    tmp6 = tmp5;
    data_SOMFFN = rmoutliers(tmp6);
end