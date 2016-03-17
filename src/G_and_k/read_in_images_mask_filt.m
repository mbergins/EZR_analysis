function means = read_in_images_mask_filt(file_set,filter)

means = struct('FRET',[],'Donor',[],'Acceptor',[]);

for i=1:length(file_set.FRET_files)
    if (filter(i) == 0), continue; end
    
    FRET = imread(file_set.FRET_files{i});
    Donor = imread(file_set.Donor_files{i});
    Acceptor = imread(file_set.Acceptor_files{i});
    mask = imread(file_set.Mask_files{i});
    
    for cell_num = 1:max(mask(:))
        means.FRET = [means.FRET, mean(FRET(mask == cell_num))];
        means.Acceptor = [means.Acceptor, mean(Acceptor(mask == cell_num))];
        means.Donor = [means.Donor, mean(Donor(mask == cell_num))];
    end
    
end


end