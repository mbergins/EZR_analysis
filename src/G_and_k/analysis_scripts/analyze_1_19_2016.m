addpath(genpath('~/Documents/Projects/personal_libraries/image_processing_misc/'))

output_dir = '/home/mbergins/Documents/Projects/FRET-Processing/results/G and k data_analysis/1-19-2016 A431 EZR-TS Live/';

base_dir = '/home/mbergins/Documents/Projects/FRET-Processing/results/1-19-2016 EZR-TS Testing/';

TS = struct();
TS_folder = fullfile(base_dir,'KD_EZR-TS/images/');
TS.FRET_files = file_search('.*c_pre.*',TS_folder,'return_complete_files',1);
TS.Acceptor_files = file_search('^bsa_pre.*',TS_folder,'return_complete_files',1);
TS.Donor_files = file_search('.*bsd_pre.*',TS_folder,'return_complete_files',1);

TSmod = struct();
TSmod_folder = fullfile(base_dir,'TSmod/images/');
TSmod.FRET_files = file_search('.*c_pre.*',TSmod_folder,'return_complete_files',1);
TSmod.Acceptor_files = file_search('^bsa_pre.*',TSmod_folder,'return_complete_files',1);
TSmod.Donor_files = file_search('.*bsd_pre.*',TSmod_folder,'return_complete_files',1);

%Get Single Data Sets for analysis

TS_data = segment_cell_means(TS);
[TS_mat,headers] = convert_struct_to_matrix(TS_data);
csvwrite_with_headers(fullfile(output_dir,'TS_per_cell.csv'),TS_mat,headers);

draw_G_histograms(TS_data,fullfile(output_dir,'G_calc_hists'),'KD+EZR-TS');

TSmod_data = segment_cell_means(TSmod);
[TSmod_mat,headers] = convert_struct_to_matrix(TSmod_data);
csvwrite_with_headers(fullfile(output_dir,'TSmod_per_cell.csv'),TSmod_mat,headers);

draw_G_histograms(TSmod_data,fullfile(output_dir,'G_calc_hists'),'TSmod');