base_dir = '~/Documents/Projects/FRET-Processing/results/G and k data/091115_tCRMod_GGSn/';
output_dir = '~/Documents/Projects/FRET-Processing/results/G and k data_analysis/9-11-2015 CR/';

addpath(genpath('~/Documents/Projects/personal_libraries/image_processing_misc/'));

GGS_2 = struct();
GGS_2_folder = fullfile(base_dir,'tCRMod_GGS2','FRET Correct Images');
GGS_2.FRET_files = file_search('.*c_pre.*',GGS_2_folder,'return_complete_files',1);
GGS_2.Acceptor_files = file_search('^bsa_pre.*',GGS_2_folder,'return_complete_files',1);
GGS_2.Donor_files = file_search('.*bsd_pre.*',GGS_2_folder,'return_complete_files',1);
GGS_2.Mask_files = file_search('.*polymask_cells.*',GGS_2_folder,'return_complete_files',1);

GGS_9 = struct();
GGS_9_folder = fullfile(base_dir,'tCRMod_GGS9','FRET Correct Images');
GGS_9.FRET_files = file_search('.*c_pre.*',GGS_9_folder,'return_complete_files',1);
GGS_9.Acceptor_files = file_search('^bsa_pre.*',GGS_9_folder,'return_complete_files',1);
GGS_9.Donor_files = file_search('.*bsd_pre.*',GGS_9_folder,'return_complete_files',1);
GGS_9.Mask_files = file_search('.*polymask_cells.*',GGS_9_folder,'return_complete_files',1);

%Get Single Data Sets for analysis

GGS_2_data = read_in_cell_means(GGS_2);
[GGS_2_mat,headers] = convert_struct_to_matrix(GGS_2_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_2_per_cell.csv'),GGS_2_mat,headers);

draw_G_histograms(GGS_2_data,fullfile(output_dir,'G_calc_hists'),'GGS_2');

GGS_9_data = read_in_cell_means(GGS_9);
[GGS_9_mat,headers] = convert_struct_to_matrix(GGS_9_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_9_per_cell.csv'),GGS_9_mat,headers);

draw_G_histograms(GGS_9_data,fullfile(output_dir,'G_calc_hists'),'GGS_9');

bootstrap_G_vals(GGS_2_data,GGS_9_data);
 
 
GGS_2_data_pixel = read_in_images_mask(GGS_2);
draw_G_histograms(GGS_2_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_2_pixel');

GGS_9_data_pixel = read_in_images_mask(GGS_9);
draw_G_histograms(GGS_9_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_9_pixel');
