function scal_fact_diff_pl = gau_emis_wind_uncer(year_file, epoch_anom, lat_ano, lon_ano, rep_emi, lat_sou, lon_sou, era5_wd_ano_req, oco2_req_data_range)

% pre_lev_top = [900,925];
pre_lev_top = [975,950];

scal_fact_diff_pl = nan(length(pre_lev_top),1);

for pre_lev_top_xx = 1:length(pre_lev_top)
    
    [era5_ws_ano_loop, era5_wd_ano_loop] =  era5_specific_ano(year_file, epoch_anom, pre_lev_top(pre_lev_top_xx), lat_ano, lon_ano);
    co2_vc_summed =  gau_model(rep_emi, lat_sou, lon_sou, era5_ws_ano_loop, era5_wd_ano_req);
    
    oco2_req_data_range_final = gau_resample(co2_vc_summed,oco2_req_data_range, lat_sou, lon_sou, era5_wd_ano_req); 
    
    plume_idx = find(oco2_req_data_range_final.mod_enh >= 1/100*(max(oco2_req_data_range_final.mod_enh)));
    
    plume_obser = oco2_req_data_range_final.obser_enh(plume_idx);
    plume_model = oco2_req_data_range_final.mod_enh(plume_idx);
    plume_model(plume_obser <= 0) = [];
    plume_obser(plume_obser <= 0) = [];
%     plume_model(plume_model >= 10)= nan;
    
    scal_fact_diff_pl(pre_lev_top_xx) = nanmean(plume_obser) ./ nanmean(plume_model);
%     scal_fact_diff_pl = nanmean(rmoutliers(plume_obser)) ./ nanmean(rmoutliers(plume_model));
%     scal_fact_diff_pl(pre_lev_top_xx) = nanmean(rmoutliers(plume_obser ./ plume_model));
end

