exp_dir = '../../FRET-Processing/results/6-5-2015 Photobleach Test/TS_full_media/';

oxy_full_modes_hist = [];
oxy_full_modes = [];

for i = 1:10
    [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/Acceptor/*']);
%     [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/median_masked_Acceptor/*']);
    oxy_full_modes = [oxy_full_modes;full_mode];
    oxy_full_modes_hist = [oxy_full_modes_hist;hist_mode];
    disp(quantile(pixel_vals,[0.05,0.95]));
%     disp(i);
end

exp_dir = '../../FRET-Processing/results/6-5-2015 Photobleach Test/TS_half_media/';

oxy_half_modes_hist = [];
oxy_half_modes = [];

for i = 1:10
    [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/Acceptor/*']);
%     [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/median_masked_FRET/*']);
    oxy_half_modes = [oxy_half_modes;full_mode];
    oxy_half_modes_hist = [oxy_half_modes_hist;hist_mode];
    disp(quantile(pixel_vals,[0.05,0.95]));
%     disp(i);
end


exp_dir = '../../FRET-Processing/results/5-8-2015 EZR Timelapse/TS/';

TS_modes_hist = [];
TS_modes = [];

for i = 1:17
    [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/Acceptor/*']);
%     [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/median_masked_FRET/*']);
    TS_modes = [TS_modes;full_mode];
    TS_modes_hist = [TS_modes_hist;hist_mode];
    disp(quantile(pixel_vals,[0.05,0.95]));
%     disp(i);
end


exp_dir = '../../FRET-Processing/results/5-8-2015 EZR Timelapse/CTS/';

CTS_modes_hist = [];
CTS_modes = [];

for i = 1:12
    [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/Acceptor/*']);
%     [pixel_vals,full_mode,hist_mode] = read_in_all_pixels([exp_dir,num2str(i),'/median_masked_FRET/*']);
    CTS_modes = [CTS_modes;full_mode];
    CTS_modes_hist = [CTS_modes_hist;hist_mode];
    disp(quantile(pixel_vals,[0.05,0.95]));
%     disp(i);
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


time = 5*(1:(size(TS_modes_hist,2)));

errorbar(time,mean(TS_modes_hist),TS_ci(1,:),TS_ci(2,:));
xlabel('Time (minutes)');
ylabel('Mean Acceptor Mode');
hold on;
errorbar(time,mean(CTS_modes_hist),CTS_ci(1,:),CTS_ci(2,:),'-r');
legend('EZR-TS','EZR-CTS');
hold off;