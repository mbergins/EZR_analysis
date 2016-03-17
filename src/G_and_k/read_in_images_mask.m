function pixels = read_in_images_mask(file_set)

pixels = struct('FRET',[],'Donor',[],'Acceptor',[]);

for i=1:length(file_set.FRET_files)
    FRET = imread(file_set.FRET_files{i});
    Donor = imread(file_set.Donor_files{i});
    Acceptor = imread(file_set.Acceptor_files{i});
    if (isfield(fieldnames(file_set),'Mask_files'))
        mask = imread(file_set.Mask_files{i});
    end
    
    if (exist('mask','var'))
        data_pixels = FRET > 0 & Donor > 0 & Acceptor > 500 & mask;
    else
        data_pixels = FRET > 0 & Donor > 0 & Acceptor > 500;
    end
    
    pixels.FRET = [pixels.FRET; FRET(data_pixels)];
    pixels.Donor = [pixels.Donor; Donor(data_pixels)];
    pixels.Acceptor = [pixels.Acceptor; Acceptor(data_pixels)];
end