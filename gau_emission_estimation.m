clear; clc
%% calling function for OCO-2 data
date_ano = 141023;
lat_ano = 23.95;
lon_ano = 82.6;

date_ano_str = num2str(date_ano); year_file = ['20',date_ano_str(1:2)];

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

% gau_fun = ((m*x)+b)+((a/(s*(2*3.14).^(1/2)))*exp((-(x-mu).^2)/(2*s.^2)));

b_fit = 394.47; m_fit = -0.012; %% estimated using curve fitting based on gau_fun

lin_fun = (m_fit*x_fit)+b_fit;

oco2_req_data_range.obser_enh = oco2_req_data_range.co2 - lin_fun; 
%% calling function for wind information
epoch_anom = posixtime(datetime(num2str(median(oco2_req_data_range.id)), 'InputFormat', 'yyyyMMddHHmmssSSS'));
pre_lev = 1000;

[era5_ws_ano, era5_wd_ano, era5_wd_ano_org] =  era5_specific_ano(year_file, epoch_anom, pre_lev, lat_ano, lon_ano);
%% calling function for Gaussian plume model

sp_mean = nanmean(oco2_req_data_range.sp,'all'); %% this values only for visualizing the modelled XCO2 enhancements
wv_mean = nanmean(oco2_req_data_range.wv,'all');

rep_emi_cb = [16.45, 23.76, 11.42, 14.17, 4.32, 8.94, 5.08]; 
lat_sou = [23.9775233, 24.0983, 24.1033, 24.027, 24.18166, 24.203059, 24.2037876];
lon_sou = [82.6264733, 82.6719, 82.7068, 82.7915, 82.79109, 82.787317, 82.79733];


era5_wd_ano_req = era5_wd_ano -5; %% change this value based on visual alignmenet (and R value)
if era5_wd_ano_req > 360
    era5_wd_ano_req = era5_wd_ano_req-360;
end

rep_emi = rep_emi_cb.*10^12/(365*24*60*60);

co2_vc_summed =  gau_model(rep_emi, lat_sou, lon_sou, era5_ws_ano, era5_wd_ano_req); %% modelled gaussian plume enhancemenets

%% expected enhancements at OCO-2 footprint location
oco2_req_data_range_final = gau_resample(co2_vc_summed,oco2_req_data_range, lat_sou, lon_sou, era5_wd_ano_req); 
weight_co2 = oco2_req_data_range_final.uncer/nansum(oco2_req_data_range_final.uncer);
% plot -  model and observed enhancements in 2-d and scatter plot
xco2_gau_plot = co2_vc_summed * (28.97/44.01) * (9.81/(sp_mean - wv_mean * 9.81))*1000; %% ony for plotting purpose

gau_plot_obs_val(oco2_req_data_range_final)
gau_plot_model_obser_2d(xco2_gau_plot, oco2_req_data_range_final)
gau_plot_model_obser_scatter(oco2_req_data_range_final)
%% scaling factor estimation
plume_idx = find(oco2_req_data_range_final.mod_enh >= 1/100*(max(oco2_req_data_range_final.mod_enh)));

plume_obser = oco2_req_data_range_final.obser_enh(plume_idx);
plume_model = oco2_req_data_range_final.mod_enh(plume_idx);
plume_model(plume_obser <= 0) = [];
plume_obser(plume_obser <= 0) = [];
% plume_model(plume_model >= 10)= nan;

scal_fact = nanmean(plume_obser) ./ nanmean(plume_model);
% scal_fact = nanmean(rmoutliers(plume_obser)) ./ nanmean(rmoutliers(plume_model));
% scal_fact = nanmean(rmoutliers(plume_obser ./ plume_model));
reported = nansum(rep_emi_cb);
plume_R = min(corrcoef(plume_obser, plume_model,'rows','pairwise'),[],"all");

scatter(plume_obser, plume_model, 'o', 'filled','MarkerEdgeColor', 'k','HandleVisibility','off')
hold on
plot(1:17,1:17, '--k','LineWidth',3,'DisplayName','1:1 line')
grid minor
legend()
xlabel('Obser. Enhancements (ppm)')
ylabel('Exp. Enhancements (ppm)')
% ylim([0 max([plume_obser;plume_model])+1])
% xlim([min(plume_obser) max([plume_obser;plume_model])+1])
xticks([ 5 10 15])
xticklabels({'5','10','15'})
yticks([ 5 10 15])
yticklabels({'5','10','15'})

ylim([0 17])
xlim([min(plume_obser) 17])
set(gca,'FontSize', 15,'fontweight','bold','FontName', 'Times New Roman')
ax1 = gca; set(ax1,'XTick',get(ax1,'YTick'));
%% Uncertainity estimation
scal_fact_diff_pl = gau_emis_wind_uncer(year_file, epoch_anom, lat_ano, lon_ano, rep_emi, lat_sou, lon_sou, era5_wd_ano_req, oco2_req_data_range);
scal_fact_diff_bkg = gau_emis_bkg_uncer(plume_idx,oco2_req_data_range_final);

scal_fact_wind_uncer = sqrt((scal_fact - scal_fact_diff_pl(1))^2 + (scal_fact - scal_fact_diff_pl(2))^2);
scal_fact_bkg_uncer = std(scal_fact - scal_fact_diff_bkg);
scal_fact_uncer = sqrt(scal_fact_wind_uncer^2 + scal_fact_bkg_uncer^2);
%% Emission inventory reported emissions (within 40,50,60 Km)
addpath('C:\India_OCO2_emission\c_s emission')
era5_wd_ano_org = 91*2;
edgar_co2_emi =  edgar_upwind_emi(year_file, lat_ano, lon_ano, era5_wd_ano_org);
odiac_co2_emi =  odiac_upwind_emi(date_ano_str, lat_ano, lon_ano, era5_wd_ano_org);
%% Fire emissions (within 40,50,60 Km)
addpath('C:\India_OCO2_emission\CAMS_fire_emission')
cams_fire_co2_emi =  cams_fire_upwind_emi(date_ano, lat_ano, lon_ano, era5_wd_ano_org);