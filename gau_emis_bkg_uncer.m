function scal_fact_diff_bkg = gau_emis_bkg_uncer(plume_idx,oco2_req_data_range_final)

co2_outside_plume = oco2_req_data_range_final.co2(~ismember(1:numel(oco2_req_data_range_final.co2), plume_idx));
scal_fact_diff_bkg = nan(4,1);

for random_idx_xx  = 1:4
    random_idx_outside_plume = randi([ 20, length(co2_outside_plume)-20]);
    
    bkg_val_loop = nanmean(co2_outside_plume(random_idx_outside_plume-10:random_idx_outside_plume+10));
    
    plume_obser = oco2_req_data_range_final.co2(plume_idx) - bkg_val_loop;
    plume_model = oco2_req_data_range_final.mod_enh(plume_idx);
    plume_model(plume_obser <= 0) = [];
    plume_obser(plume_obser <= 0) = [];
%     plume_model(plume_model >= 10)= nan;
    
    scal_fact_diff_bkg(random_idx_xx) = nanmean(plume_obser) ./ nanmean(plume_model);
%     scal_fact_diff_bkg(random_idx_xx) = nanmean(rmoutliers(plume_obser)) ./ nanmean(rmoutliers(plume_model));
%     scal_fact_diff_bkg(random_idx_xx) = nanmean(rmoutliers(plume_obser ./ plume_model));
end

end