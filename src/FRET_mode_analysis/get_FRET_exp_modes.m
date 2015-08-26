function all_hist_modes = get_FRET_exp_modes(exp_dir)

all_hist_modes = [];

for i = 1:(length(dir(exp_dir)) - 2)
% for i = 1:3
    [~,~,hist_mode] = get_FRET_modes(fullfile(exp_dir,num2str(i),'/FRET/*'));
    all_hist_modes = [all_hist_modes;hist_mode];
end

end