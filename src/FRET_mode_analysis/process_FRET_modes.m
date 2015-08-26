small_oxy_modes = get_FRET_exp_modes('../../../FRET-Processing/results/6-9-2015 Small Volume Photobleach Test/Oxy/');
[small_oxy_mean,small_oxy_upper,small_oxy_lower] = determine_confidence_int(small_oxy_modes);

small_no_oxy_modes = get_FRET_exp_modes('../../../FRET-Processing/results/6-9-2015 Small Volume Photobleach Test/No_oxy/');
[small_no_oxy_mean,small_no_oxy_upper,small_no_oxy_lower] = determine_confidence_int(small_no_oxy_modes);


TS_reg_modes = get_FRET_exp_modes('../../../FRET-Processing/results/5-8-2015 EZR Timelapse/TS/');
[TS_reg_mean,TS_reg_upper,TS_reg_lower] = determine_confidence_int(TS_reg_modes);

CTS_reg_modes = get_FRET_exp_modes('../../../FRET-Processing/results/5-8-2015 EZR Timelapse/CTS/');
[CTS_reg_mean,CTS_reg_upper,CTS_reg_lower] = determine_confidence_int(CTS_reg_modes);


TS_full_modes = get_FRET_exp_modes('../../../FRET-Processing/results/6-5-2015 Photobleach Test/TS_full_media/');
[TS_full_mean,TS_full_upper,TS_full_lower] = determine_confidence_int(TS_full_modes);

TS_half_modes = get_FRET_exp_modes('../../../FRET-Processing/results/6-5-2015 Photobleach Test/TS_half_media/');
[TS_half_mean,TS_half_upper,TS_half_lower] = determine_confidence_int(TS_half_modes);



time = 5*(1:(size(TS_reg_modes,2)));

errorbar(time,small_oxy_mean,small_oxy_upper,small_oxy_lower);
xlabel('Time (minutes)');
ylabel('Mean FRET Mode');
hold on;
errorbar(time,small_no_oxy_mean,small_no_oxy_upper,small_no_oxy_lower,'-r');

legend('Small Vol Oxy','Small Vol No Oxy');
hold off;


errorbar(time,TS_full_mean,TS_full_upper,TS_full_lower,'-m');
hold on;
errorbar(time,TS_half_mean,TS_half_upper,TS_half_lower,'-b');
xlabel('Time (minutes)');
ylabel('Mean FRET Mode');

legend('Full Dish','2mL Dish','Location','northwest')


errorbar(time,TS_reg_mean,TS_reg_upper,TS_reg_lower,'-m');
hold on;
errorbar(time,CTS_reg_mean,CTS_reg_upper,CTS_reg_lower,'-b');
xlabel('Time (minutes)');
ylabel('Mean FRET Mode');

legend('EZR-TS','EZR-CTS')
