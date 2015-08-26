hypo_modes = get_FRET_exp_modes('../../../FRET-Processing/results/6-16-2015 Hypotonic Shock/TS/');
[hypo_mean,hypo_upper,hypo_lower] = determine_confidence_int(hypo_modes);



time = 2*(1:(size(hypo_modes,2)));

errorbar(time,hypo_mean,hypo_upper,hypo_lower);
xlabel('Time (minutes)');
ylabel('Mean FRET Mode');
hold on;

legend('EZR-TS Hypo Shock between 10-12');
hold off;



