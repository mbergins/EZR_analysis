function props = calc_G_and_K_per_cell(file_set_1, file_set_2)

means_1 = read_in_cell_means(file_set_1);
means_2 = read_in_cell_means(file_set_2);



1;

% props = struct();
% props.G = mean(means_1.FRET./means_1.Acceptor) - mean(means_2.FRET./means_2.Acceptor);
% props.G = props.G / (mean(means_2.Donor./means_2.Acceptor) - mean(means_1.Donor./means_1.Acceptor));
% 
% props.diff_G = mean(means_1.FRET)/mean(means_1.Acceptor) - mean(means_2.FRET)/mean(means_2.Acceptor);
% props.diff_G = props.diff_G / (mean(means_2.Donor)/mean(means_2.Acceptor) - mean(means_1.Donor)/mean(means_1.Acceptor));
% 
% props.k_1 = mean((means_1.Donor + means_1.FRET/props.G)./means_1.Acceptor);
% props.k_2 = mean((means_2.Donor + means_2.FRET/props.G)./means_2.Acceptor);
% 
% per_cell_d_and_a_1 = find_per_cell_d_per_a(file_set_1,props.G,props.k_1);
% per_cell_d_and_a_2 = find_per_cell_d_per_a(file_set_2,props.G,props.k_1);
% 
% pass_dpa_1 = per_cell_d_and_a_1 > 0.8 & per_cell_d_and_a_1 < 1.2;
% pass_dpa_2 = per_cell_d_and_a_2 > 0.8 & per_cell_d_and_a_2 < 1.2;
% 
% %%Filter the image set based on first pass
% means_1 = read_in_images_mask_filt(file_set_1,pass_dpa_1);
% means_2 = read_in_images_mask_filt(file_set_2,pass_dpa_2);
% 
% props = struct();
% props.G = mean(means_1.FRET./means_1.Acceptor) - mean(means_2.FRET./means_2.Acceptor);
% props.G = props.G / (mean(means_2.Donor./means_2.Acceptor) - mean(means_1.Donor./means_1.Acceptor));
% 
% props.diff_G = mean(means_1.FRET)/mean(means_1.Acceptor) - mean(means_2.FRET)/mean(means_2.Acceptor);
% props.diff_G = props.diff_G / (mean(means_2.Donor)/mean(means_2.Acceptor) - mean(means_1.Donor)/mean(means_1.Acceptor));
% 
% props.k_1 = mean((means_1.Donor + means_1.FRET/props.diff_G)./means_1.Acceptor);
% props.k_2 = mean((means_2.Donor + means_2.FRET/props.diff_G)./means_2.Acceptor);
% 
% per_cell_d_and_a_1 = find_per_cell_d_per_a(file_set_1,props.G,props.k_1);
% per_cell_d_and_a_2 = find_per_cell_d_per_a(file_set_2,props.G,props.k_1);
% 
% pass_dpa_1 = per_cell_d_and_a_1 > 0.8 & per_cell_d_and_a_1 < 1.2;
% pass_dpa_2 = per_cell_d_and_a_1 > 0.8 & per_cell_d_and_a_1 < 1.2;
% 
% 
% 1;

end



function per_cell_d_per_a = find_per_cell_d_per_a(file_set,G,k)

per_cell_d_per_a = [];

for i=1:length(file_set.FRET_files)
    FRET = imread(file_set.FRET_files{i});
    Donor = imread(file_set.Donor_files{i});
    Acceptor = imread(file_set.Acceptor_files{i});
    mask = imread(file_set.Mask_files{i});
    
    d_per_a = (Donor + FRET/G)./(Acceptor * k);
    
    for cell_num = 1:max(mask(:))
        per_cell_d_per_a = [per_cell_d_per_a, nanmean(d_per_a(mask == cell_num))];
    end
    
end
end

