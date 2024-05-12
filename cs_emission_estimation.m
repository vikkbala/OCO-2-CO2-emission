clear; clc
%% calling function for OCO-2 data
date_ano = 141023;
lat_ano = 23.95;
lon_ano = 82.6;

oco2_req_data = oco2_data_mani(date_ano,lat_ano, lon_ano);
%% OCO2 data manipulation
[max_co2, max_co2_ind] = max(oco2_req_data.co2);

dis_max = oco2_req_data.dis(max_co2_ind)+0; %% this should be confirmed by visual inspection)
lat_at_max_peak = oco2_req_data.lat(max_co2_ind); %% check whether lat and lon of max peak align with actual plume
lon_at_max_peak = oco2_req_data.lon(max_co2_ind);

dis_range_ind = find (oco2_req_data.dis <= dis_max+100 & oco2_req_data.dis >= dis_max-100);
oco2_req_data_range = table(oco2_req_data.lat(dis_range_ind),oco2_req_data.lon(dis_range_ind),oco2_req_data.co2(dis_range_ind),oco2_req_data.uncer(dis_range_ind),oco2_req_data.id(dis_range_ind),oco2_req_data.wv(dis_range_ind),oco2_req_data.sp(dis_range_ind),(oco2_req_data.dis(dis_range_ind)- dis_max));
oco2_req_data_range.Properties.VariableNames = {'lat', 'lon', 'co2', 'uncer', 'id','wv', 'sp','dis'};

x_fit = oco2_req_data_range.dis;
y_fit = oco2_req_data_range.co2;
y_wei = oco2_req_data_range.uncer;
%% Curve fit and remove background 

a_fit = 216.5; b_fit = 394.5; m_fit = -0.01202; mu_fit = -7.1; s_fit = 11.82;  %% estimated using curve fitting based on gau_fun

% gau_fun = ((m*x)+b)+((a/(s*(2*3.14).^(1/2)))*exp((-(x-mu).^2)/(2*s.^2)));
oco2_req_data_range.gau_fun = ((m_fit*x_fit)+b_fit)+((a_fit/(s_fit*(2*3.14).^(1/2)))*exp((-(x_fit-mu_fit).^2)/(2*s_fit.^2)));
oco2_req_data_range.lin_fun = (m_fit*x_fit)+b_fit;
oco2_req_data_range.gau_fun_rem_bkg = oco2_req_data_range.gau_fun - oco2_req_data_range.lin_fun;

oco2_req_data_range.obser_enh = oco2_req_data_range.co2 - oco2_req_data_range.lin_fun; 
area_ld = trapz(x_fit,oco2_req_data_range.gau_fun_rem_bkg);

figure
scatter (x_fit , oco2_req_data_range.co2,'filled') 
hold on
scatter (x_fit , oco2_req_data_range.gau_fun,'filled')
hold on
grid minor
ylim([min(oco2_req_data_range.co2)-1 max(oco2_req_data_range.co2)+1])
xlabel('distance (km)')
ylabel('XCO_2 (ppm)')
legend('Observed XCO_2 (ppm)','Fitted curve')
set(gca,'FontSize', 15,'fontweight','bold','FontName', 'Times New Roman')
%% calling function for wind information

date_ano_str = num2str(date_ano); year_file = ['20',date_ano_str(1:2)];
epoch_anom = posixtime(datetime(num2str(median(oco2_req_data_range.id)), 'InputFormat', 'yyyyMMddHHmmssSSS'));
pre_lev = 1000;

[era5_ws_ano, era5_wd_ano] =  era5_specific_ano(year_file, epoch_anom, pre_lev, lat_ano, lon_ano);
%% emission estimation
sp_mean = nanmean(oco2_req_data_range.sp,'all'); 
wv_mean = nanmean(oco2_req_data_range.wv,'all');

era5_wd_ano_req = era5_wd_ano -34; %% change this value based on visual alignmenet (and R value) in gaussian plume model
if era5_wd_ano_req > 360
    era5_wd_ano_req = era5_wd_ano_req-360;
elseif era5_wd_ano_req < 0
    era5_wd_ano_req = era5_wd_ano_req+360;
end
ws_nor_tra = cs_ws (oco2_req_data_range,era5_ws_ano,era5_wd_ano_req);

co2_ld = ((area_ld * 44.01 * sp_mean - wv_mean * 9.81)/(28.9 * 9.81))* 10^(-6); % in ton/m
flux_co2 = co2_ld * (ws_nor_tra); % ton/s (for kt/hr: multiply 1*10^(-3)*3600)
flux_co2_mt_yr = flux_co2*10^(-6)*365*24*60*60;
%% Uncertainity estimation
flux_co2_mt_yr_diff_pl = cs_emis_wind_uncer(year_file, epoch_anom, lat_ano, lon_ano, era5_wd_ano_req, oco2_req_data_range, area_ld, sp_mean, wv_mean);
flux_co2_mt_yr_wind_uncer = sqrt((flux_co2_mt_yr - flux_co2_mt_yr_diff_pl(1))^2 + (flux_co2_mt_yr - flux_co2_mt_yr_diff_pl(2))^2);

flux_co2_mt_yr_diff_bkg = cs_emis_bkg_uncer(mu_fit, s_fit, x_fit, oco2_req_data_range, sp_mean, wv_mean, ws_nor_tra);
flux_co2_mt_yr_bkg_uncer = std(flux_co2_mt_yr - flux_co2_mt_yr_diff_bkg);
flux_co2_mt_yr_uncer = sqrt(flux_co2_mt_yr_wind_uncer^2 + flux_co2_mt_yr_bkg_uncer^2);