
function oco2_req_data = oco2_data_mani(date_ano,lat_ano, lon_ano)

lon_min = lon_ano - 1; lon_max = lon_ano + 1;       
lat_min = lat_ano - 1; lat_max = lat_ano + 1;

oco2_myFolder = 'D:\India_OCO2_emission\V11r_data';     
% oco2_myFolder = 'D:\India_OCO2_emission\V10_data';  
oco2_filePattern = fullfile(oco2_myFolder, '*.nc4');
oco2_ncFiles   = dir(oco2_filePattern);

for oco2_ncFiles_xx = 1:length(oco2_ncFiles)
    oco2_baseFileName = oco2_ncFiles(oco2_ncFiles_xx).name;
    time = str2double(oco2_baseFileName(12:17));
    if (time == date_ano)
        match_date = oco2_ncFiles_xx;
        break
    end
end

if ~isempty (match_date)
    oco2_ano_baseFileName = oco2_ncFiles(match_date).name;
    oco2_file = fullfile(oco2_myFolder, oco2_ano_baseFileName);
    oco2_var_info = ncinfo(oco2_file); oco2_dim = oco2_var_info.Dimensions;
    
    if ~isempty (oco2_dim)
        oco2_lons = ncread(oco2_file,'longitude'); oco2_lats = ncread(oco2_file,'latitude');
        oco2_co2 = ncread(oco2_file,'xco2'); oco2_co2_un = ncread(oco2_file,'xco2_uncertainty');
        oco2_qa = ncread(oco2_file,'xco2_quality_flag'); oco2_sou_id = ncread(oco2_file,'sounding_id');
        oco2_wat_vap = ncread(oco2_file,'/Retrieval/tcwv'); oco2_sur_pr = ncread(oco2_file,'/Retrieval/psurf');
        
        oco2_qa_do = find(oco2_lats >= lat_min & oco2_lats <= lat_max & oco2_lons >= lon_min & oco2_lons <= lon_max & oco2_qa == 0);
        
        if length(oco2_qa_do)>=1
            oco2_req_data = table(oco2_lats(oco2_qa_do),oco2_lons(oco2_qa_do),oco2_co2(oco2_qa_do),(1./oco2_co2_un(oco2_qa_do)),oco2_sou_id(oco2_qa_do),oco2_wat_vap(oco2_qa_do),(oco2_sur_pr(oco2_qa_do).*100));
            oco2_req_data.Properties.VariableNames = {'lat', 'lon', 'co2', 'uncer', 'id', 'wv', 'sp'};
            
            [~,sort_sou] = sort(oco2_req_data.id);
            oco2_req_data = oco2_req_data(sort_sou,:);
            
            dis = nan(height(oco2_req_data),1);
            for oco2_req_data_xx = 1:height(oco2_req_data)
                dis(oco2_req_data_xx) = distance(oco2_req_data.lat(1),oco2_req_data.lon(1),oco2_req_data.lat(oco2_req_data_xx),oco2_req_data.lon(oco2_req_data_xx));
            end
            oco2_req_data.dis = deg2km(dis,'earth');
            
        end
    end
end
end
