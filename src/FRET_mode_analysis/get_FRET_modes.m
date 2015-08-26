function [pixel_vals,mode_vals,hist_modes] = get_FRET_modes(search_str)

base_name = fileparts(search_str);

file_set = dir(search_str);
file_set = file_set(3:end);

assert(not(isempty(file_set)),...
       sprintf('Cant Find any Files to analyze: %s',search_str));

fprintf('Reading in %d images.\n', length(file_set));

pixel_vals = [];
mode_vals = [];
hist_modes = [];
for i=1:length(file_set);
    image = imread(fullfile(base_name,file_set(i).name));
    temp = image(:);
    temp = temp(temp >= 0.001 & temp <= 1);
    %fprintf('%f - %f\n',mode(temp),mean(temp));
    
%     hist_hnd = hist(temp,256);
%     xlim([0,1]);
%     saveas(hist_hnd,sprintf('%02d.png',i));
%     close;
%     
    [counts,mids] = hist(temp,256);
    hist_modes = [hist_modes,mids(find(max(counts)==counts,1))];
    
    mode_vals = [mode_vals, mode(temp)];
    pixel_vals = [pixel_vals;temp(:)]; %#ok<AGROW>
end