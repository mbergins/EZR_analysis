base_dir = '/home/mbergins/Documents/Projects/FRET-Processing/results/2-19-2016 GGS/A431/';

GGS_2 = struct();
GGS_2_folder = fullfile(base_dir,'GGS_2/FRET Correct Images/');
GGS_2.FRET_files = file_search('.*c_pre.*',GGS_2_folder,'return_complete_files',1);
GGS_2.Acceptor_files = file_search('^bsa_pre.*',GGS_2_folder,'return_complete_files',1);
GGS_2.Donor_files = file_search('.*bsd_pre.*',GGS_2_folder,'return_complete_files',1);

GGS_9 = struct();
GGS_9_folder = fullfile(base_dir,'GGS_9/FRET Correct Images/');
GGS_9.FRET_files = file_search('.*c_pre.*',GGS_9_folder,'return_complete_files',1);
GGS_9.Acceptor_files = file_search('^bsa_pre.*',GGS_9_folder,'return_complete_files',1);
GGS_9.Donor_files = file_search('.*bsd_pre.*',GGS_9_folder,'return_complete_files',1);

% GGS_2_5 = calc_G_per_pixel(GGS_2,GGS_5);
% GGS_2_9 = calc_G_per_pixel(GGS_2,GGS_9);
% GGS_5_9 = calc_G_per_pixel(GGS_5,GGS_9);

% GGS_2_5 = calc_G_and_K_per_cell(GGS_2,GGS_5);
% GGS_2_9 = calc_G_and_K_per_cell(GGS_2,GGS_9);
% GGS_5_9 = calc_G_and_K_per_cell(GGS_5,GGS_9);

%Get Single Data Sets for analysis

output_dir = '/home/mbergins/Documents/Projects/FRET-Processing/results/G and k data_analysis/2-19-2016 A431/';

GGS_2_data = segment_cell_means(GGS_2);
[GGS_2_mat,headers] = convert_struct_to_matrix(GGS_2_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_2_per_cell.csv'),GGS_2_mat,headers);

draw_G_histograms(GGS_2_data,fullfile(output_dir,'G_calc_hists'),'GGS_2');

GGS_9_data = segment_cell_means(GGS_9);
[GGS_9_mat,headers] = convert_struct_to_matrix(GGS_9_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_9_per_cell.csv'),GGS_9_mat,headers);

draw_G_histograms(GGS_9_data,fullfile(output_dir,'G_calc_hists'),'GGS_9');

bootstrap_G_vals(GGS_2_data,GGS_9_data,output_dir);


GGS_2_data_pixel = read_in_images_mask(GGS_2);
draw_G_histograms(GGS_2_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_2_pixel');

GGS_9_data_pixel = read_in_images_mask(GGS_9);
draw_G_histograms(GGS_9_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_9_pixel');