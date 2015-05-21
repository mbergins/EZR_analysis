function [pixel_vals,mode_vals,hist_modes] = read_in_all_pixels(search_str)

base_name = fileparts(search_str);

file_set = dir(search_str);
file_set = file_set(3:end);

assert(not(isempty(file_set)));

fprintf('Reading in %d images.\n', length(file_set));

pixel_vals = [];
mode_vals = [];
hist_modes = [];
for i=1:length(file_set);
    image = imread(fullfile(base_name,file_set(i).name));
    temp = image(:);
    temp = temp(temp >= 0.001 & temp <= 1);
    %fprintf('%f - %f\n',mode(temp),mean(temp));
    
    [counts,mids] = hist(temp,1000);
    hist_modes = [hist_modes,mids(find(max(counts)==counts,1))];
    
    mode_vals = [mode_vals, mode(temp)];
    pixel_vals = [pixel_vals;temp(:)]; %#ok<AGROW>
end