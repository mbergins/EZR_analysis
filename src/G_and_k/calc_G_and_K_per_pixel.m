function props = calc_G_and_K_per_pixel(file_set_1, file_set_2)

pixels_1 = read_in_images_mask(file_set_1);
pixels_2 = read_in_images_mask(file_set_2);

props = struct();
props.G = mean(pixels_1.FRET./pixels_1.Acceptor) - mean(pixels_2.FRET./pixels_2.Acceptor);
props.G = props.G / (mean(pixels_2.Donor./pixels_2.Acceptor) - mean(pixels_1.Donor./pixels_1.Acceptor));

props.k_1 = mean((pixels_1.Donor + pixels_1.FRET/props.G)./pixels_1.Acceptor);
props.k_2 = mean((pixels_2.Donor + pixels_2.FRET/props.G)./pixels_2.Acceptor);



end