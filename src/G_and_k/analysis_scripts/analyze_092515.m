base_dir = '../../../FRET-Processing/results/G and k data/092515_TV_GGS259/';

GGS_2 = struct();
GGS_2.FRET_files = file_search('.*c_pre.*',fullfile(base_dir,'tTVGGS2_M/'),'return_complete_files',1);
GGS_2.Acceptor_files = file_search('^bsa_pre.*',fullfile(base_dir,'tTVGGS2_M/'),'return_complete_files',1);
GGS_2.Donor_files = file_search('.*bsd_pre.*',fullfile(base_dir,'tTVGGS2_M/'),'return_complete_files',1);
GGS_2.Mask_files = file_search('.*polymask_cells.*',fullfile(base_dir,'tTVGGS2_M/'),'return_complete_files',1);

GGS_5 = struct();
GGS_5.FRET_files = file_search('.*c_pre.*',fullfile(base_dir,'tTVGGS5_M/'),'return_complete_files',1);
GGS_5.Acceptor_files = file_search('^bsa_pre.*',fullfile(base_dir,'tTVGGS5_M/'),'return_complete_files',1);
GGS_5.Donor_files = file_search('.*bsd_pre.*',fullfile(base_dir,'tTVGGS5_M/'),'return_complete_files',1);
GGS_5.Mask_files = file_search('.*polymask_cells.*',fullfile(base_dir,'tTVGGS5_M/'),'return_complete_files',1);

GGS_9 = struct();
GGS_9.FRET_files = file_search('.*c_pre.*',fullfile(base_dir,'tTVGGS9_M/'),'return_complete_files',1);
GGS_9.Acceptor_files = file_search('^bsa_pre.*',fullfile(base_dir,'tTVGGS9_M/'),'return_complete_files',1);
GGS_9.Donor_files = file_search('.*bsd_pre.*',fullfile(base_dir,'tTVGGS9_M/'),'return_complete_files',1);
GGS_9.Mask_files = file_search('.*polymask_cells.*',fullfile(base_dir,'tTVGGS9_M/'),'return_complete_files',1);

% GGS_2_5 = calc_G_per_pixel(GGS_2,GGS_5);
% GGS_2_9 = calc_G_and_K_per_pixel(GGS_2,GGS_9);
% GGS_5_9 = calc_G_per_pixel(GGS_5,GGS_9);

% GGS_2_5 = calc_G_and_K_per_cell(GGS_2,GGS_5);
% GGS_2_9 = calc_G_and_K_per_cell(GGS_2,GGS_9);
% GGS_5_9 = calc_G_and_K_per_cell(GGS_5,GGS_9);

%Get Single Data Sets for analysis

output_dir = '/home/mbergins/Documents/Projects/FRET-Processing/results/G and k data_analysis/9-25-15 CR/';

GGS_2_data = read_in_cell_means(GGS_2);
[GGS_2_mat,headers] = convert_struct_to_matrix(GGS_2_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_2_per_cell.csv'),GGS_2_mat,headers);

draw_G_histograms(GGS_2_data,fullfile(output_dir,'G_calc_hists'),'GGS_2');

GGS_5_data = read_in_cell_means(GGS_5);
[GGS_5_mat,headers] = convert_struct_to_matrix(GGS_5_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_5_per_cell.csv'),GGS_5_mat,headers);

draw_G_histograms(GGS_5_data,fullfile(output_dir,'G_calc_hists'),'GGS_5');

GGS_9_data = read_in_cell_means(GGS_9);
[GGS_9_mat,headers] = convert_struct_to_matrix(GGS_9_data);
csvwrite_with_headers(fullfile(output_dir,'GGS_9_per_cell.csv'),GGS_9_mat,headers);

draw_G_histograms(GGS_9_data,fullfile(output_dir,'G_calc_hists'),'GGS_9');

bootstrap_G_vals(GGS_2_data,GGS_9_data);


GGS_2_data_pixel = read_in_images_mask(GGS_2);
draw_G_histograms(GGS_2_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_2_pixel');

GGS_5_data_pixel = read_in_images_mask(GGS_5);
draw_G_histograms(GGS_5_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_5_pixel');

GGS_9_data_pixel = read_in_images_mask(GGS_9);
draw_G_histograms(GGS_9_data_pixel,fullfile(output_dir,'G_calc_hists'),'GGS_9_pixel');