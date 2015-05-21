exp_dir = '../../results/2-25-2015 EZR-CTS/CTS/';

TS_modes_hist = [];
TS_modes = [];

for i = 1:13
    [~,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/FRET/*']);
    TS_modes = [TS_modes;full_mode];
    TS_modes_hist = [TS_modes_hist;hist_mode];
    disp(i);
end

CTS_modes_hist = [];
CTS_modes = [];

for i = 1:14
    [~,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/FRET/*']);
    CTS_modes = [CTS_modes;full_mode];
    CTS_modes_hist = [CTS_modes_hist;hist_mode];
    disp(i);
end

TS_ci = [];

for i=1:size(TS_modes_hist,2)
    [~,~,ci,~]  = ttest(TS_modes_hist(:,i));
    TS_ci = [TS_ci,ci];
end
TS_ci(1,:) = mean(TS_modes_hist) - TS_ci(1,:);
TS_ci(2,:) = TS_ci(2,:) - mean(TS_modes_hist);


CTS_ci = [];

for i=1:size(CTS_modes_hist,2)
    [~,~,ci,~]  = ttest(CTS_modes_hist(:,i));
    CTS_ci = [CTS_ci,ci];
end
CTS_ci(1,:) = mean(CTS_modes_hist) - CTS_ci(1,:);
CTS_ci(2,:) = CTS_ci(2,:) - mean(CTS_modes_hist);

