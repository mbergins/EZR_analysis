function bootstrap_G_vals(data_set_1,data_set_2,output_dir)

boot_1 = struct();

boot_1.FRET = bootstrp(100000,@mean,data_set_1.FRET);
boot_1.Acc = bootstrp(100000,@mean,data_set_1.Acceptor);
boot_1.Donor = bootstrp(100000,@mean,data_set_1.Donor);

boot_2 = struct();

boot_2.FRET = bootstrp(100000,@mean,data_set_2.FRET);
boot_2.Acc = bootstrp(100000,@mean,data_set_2.Acceptor);
boot_2.Donor = bootstrp(100000,@mean,data_set_2.Donor);

G_vals = (boot_1.FRET./boot_1.Acc - boot_2.FRET./boot_2.Acc) ./ ...
    (boot_2.Donor./boot_2.Acc - boot_1.Donor./boot_1.Acc);


hist(G_vals,1000);
title(sprintf('Bootstrap G Vals from Per Cell Numbers\nMedian: %0.2f',median(G_vals)));
saveas(gcf,fullfile(output_dir,'boot_G_full_range.png'));

G_truncate = G_vals(G_vals >= -20 & G_vals <= 20);

hist(G_truncate,1000);
title(sprintf('Bootstrap G Vals from Per Cell Numbers\nMedian: %0.2f',median(G_truncate)));
saveas(gcf,fullfile(output_dir,'boot_G_short_range.png'));

close all;