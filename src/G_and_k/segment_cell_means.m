function means = segment_cell_means(file_set)

means = struct('Image_num',[],'Cell_num',[],'FRET',[],'Donor',[],...
    'Acceptor',[],'FRET_per_Acc',[],'Donor_per_Acc',[],'Area',[]);

for i=1:length(file_set.FRET_files)
    FRET = imread(file_set.FRET_files{i});
    Donor = imread(file_set.Donor_files{i});
    Acceptor = imread(file_set.Acceptor_files{i});
    Acceptor_norm = normalize_image(Acceptor,'quantiles',[0.01,1]);
    
    mask = Acceptor > 1000;
    mask = remove_edge_objects(mask);
    mask = bwpropopen(mask,'Area',25000);
    mask = imfill(mask,'holes');
    mask = mask & not(Acceptor == 0);
    
    mask = bwpropopen(mask,'Area',25000);
    
    mask_label = bwlabel(mask);
    
    mask_border = bwperim(mask);
    mask_border = thicken_perimeter(mask_border,mask);
    mask_highlight = create_highlighted_image(Acceptor_norm,mask_border,...
        'color_map',[0,1,0]);
    
    [folder,~,~] = fileparts(file_set.Acceptor_files{i});
    
    imwrite(mask_highlight,fullfile(folder,sprintf('cell_mask_%02d.png',i)));
    
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