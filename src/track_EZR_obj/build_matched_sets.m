function build_matched_sets(search_folder,varargin)
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.FunctionName = 'BUILD_MATCHED_SETS';

i_p.addRequired('search_folder',@(x)exist(search_folder,'dir') == 7);

i_p.parse(search_folder,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('../image_processing_misc/'))

start_set = file_search('.*',fullfile(search_folder,'pre_label'),'return_complete_files',1);
end_set = file_search('.*',fullfile(search_folder,'post_label'),'return_complete_files',1);

mkdir_no_err(fullfile(search_folder,'tracking_mat'));
mkdir_no_err(fullfile(search_folder,'tracking_vis'));

for k = 1:length(start_set)
    try
        [tracking_mat, output_vis] = track_obj(start_set{k},end_set{k});
        csvwrite_with_headers(fullfile(search_folder,'tracking_mat',...
            sprintf('%02d.csv',k)),tracking_mat,{'pre_obj_num','post_obj_num'})
        imwrite_with_folder_creation(output_vis,...
            fullfile(search_folder,'tracking_vis',sprintf('%02d.png',k)))
    catch
        csvwrite_with_headers(fullfile(search_folder,'tracking_mat',...
            sprintf('%02d.csv',k)),[NaN, NaN],{'pre_obj_num','post_obj_num'})
        imwrite_with_folder_creation(ones(100),...
            fullfile(search_folder,'tracking_vis',sprintf('%02d.png',k)))
    end
end