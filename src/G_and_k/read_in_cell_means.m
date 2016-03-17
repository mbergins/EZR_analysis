function means = read_in_cell_means(file_set)

means = struct('Image_num',[],'Cell_num',[],'FRET',[],'Donor',[],...
    'Acceptor',[],'FRET_per_Acc',[],'Donor_per_Acc',[],'Area',[]);


for i=1:length(file_set.FRET_files)
    FRET = imread(file_set.FRET_files{i});
    Donor = imread(file_set.Donor_files{i});
    Acceptor = imread(file_set.Acceptor_files{i});
    mask_label = imread(file_set.Mask_files{i});
    
    for cell_num = 1:max(mask_label(:))
        FRET_mean = mean(FRET(mask_label == cell_num));
        Acc_mean = mean(Acceptor(mask_label == cell_num));
        Donor_mean = mean(Donor(mask_label == cell_num));
        
        means.Image_num = [means.Image_num, i];
        means.Cell_num = [means.Cell_num, cell_num];
        means.FRET = [means.FRET, FRET_mean];
        means.Acceptor = [means.Acceptor, Acc_mean];
        means.Donor = [means.Donor, Donor_mean];
        means.FRET_per_Acc = [means.FRET_per_Acc, FRET_mean/Acc_mean];
        means.Donor_per_Acc = [means.Donor_per_Acc, Donor_mean/Acc_mean]; 
        means.Area = [means.Area, sum(sum(mask_label == cell_num))];
    end
end


end