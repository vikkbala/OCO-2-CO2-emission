function flux_co2_mt_yr_diff_bkg = cs_emis_bkg_uncer(mu_fit, s_fit, x_fit, oco2_req_data_range, sp_mean, wv_mean, ws_nor_tra)

plume_def = [mu_fit+(2*s_fit), mu_fit-(2*s_fit)];

plume_idx = find(oco2_req_data_range.dis >= min(plume_def) & oco2_req_data_range.dis <= max(plume_def));
outside_plume_idx = find(oco2_req_data_range.dis < min(plume_def) | oco2_req_data_range.dis > max(plume_def));

flux_co2_mt_yr_diff_bkg = nan(4,1);


for random_idx_xx  = 1:4
    random_idx_outside_plume = randi([ 20, length(outside_plume_idx)]);
    
    bkg_val_loop = nanmean(oco2_req_data_range.co2(random_idx_outside_plume-10:random_idx_outside_plume+10));
    gau_fun_rem_bkg_uncer = oco2_req_data_range.gau_fun - bkg_val_loop;
    gau_fun_rem_bkg_uncer(outside_plume_idx) = 0;
    area_ld_uncer = trapz(x_fit,gau_fun_rem_bkg_uncer);
    
    co2_ld_uncer = ((area_ld_uncer * 44.01 * sp_mean - wv_mean * 9.81)/(28.9 * 9.81))* 10^(-6); % in ton/m
    flux_co2_uncer = co2_ld_uncer * (ws_nor_tra); % ton/s (for kt/hr: multiply 1*10^(-3)*3600)
    flux_co2_mt_yr_diff_bkg(random_idx_xx) = flux_co2_uncer*10^(-6)*365*24*60*60;

end

end