function draw_G_histograms(data_set,output_folder,prefix)

mkdir_no_err(output_folder);


[~,~,FRET_per_Acc_ci] = ttest(data_set.FRET./data_set.Acceptor);

if (length(data_set.Acceptor) > 10000)
    hist(data_set.FRET./data_set.Acceptor,1000);
else
    hist(data_set.FRET./data_set.Acceptor);
end
xlabel(sprintf('FRET/Acceptor - Mean: %0.2f\n95%%: %0.2f - %0.2f',...
    mean(data_set.FRET./data_set.Acceptor),FRET_per_Acc_ci(1),...
    FRET_per_Acc_ci(2)));
xlim([0,4]);
title(sprintf('%s (n=%d)',prefix,length(data_set.Acceptor)));
saveas(gcf,fullfile(output_folder,[prefix,'_FRET_per_Acc.png']));

[~,~,Donor_per_Acc_ci] = ttest(data_set.Donor./data_set.Acceptor);

if (length(data_set.Acceptor) > 10000)
    hist(data_set.Donor./data_set.Acceptor,1000);
else 
    hist(data_set.Donor./data_set.Acceptor);
end
xlabel(sprintf('Donor/Acceptor - Mean: %0.2f\n95%%: %0.2f - %0.2f',...
    mean(data_set.Donor./data_set.Acceptor),Donor_per_Acc_ci(1),...
    Donor_per_Acc_ci(2)));
xlim([0,4]);
title(sprintf('%s (n=%d)',prefix,length(data_set.Acceptor)));
saveas(gcf,fullfile(output_folder,[prefix,'_Donor_per_Acc.png']));
close all;