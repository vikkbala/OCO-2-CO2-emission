function flux_co2_mt_yr_diff_pl = cs_emis_wind_uncer(year_file, epoch_anom, lat_ano, lon_ano, era5_wd_ano_req, oco2_req_data_range, area_ld, sp_mean, wv_mean)

pre_lev_top = [975,950];

flux_co2_mt_yr_diff_pl = nan(length(pre_lev_top),1);

for pre_lev_top_xx = 1:length(pre_lev_top)
    
    [era5_ws_ano_loop, era5_wd_ano_loop] =  era5_specific_ano(year_file, epoch_anom, pre_lev_top(pre_lev_top_xx), lat_ano, lon_ano);
    
    ws_nor_tra = cs_ws (oco2_req_data_range,era5_ws_ano_loop,era5_wd_ano_req);
    co2_ld = ((area_ld * 44.01 * sp_mean - wv_mean * 9.81)/(28.9 * 9.81))* 10^(-6); % in ton/m
    flux_co2 = co2_ld * (ws_nor_tra); % ton/s (for kt/hr: multiply 1*10^(-3)*3600)
    flux_co2_mt_yr_diff_pl(pre_lev_top_xx) = flux_co2*10^(-6)*365*24*60*60;
end

end