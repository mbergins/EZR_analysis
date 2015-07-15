function find_cell_mask_region_thresh(acceptor_file,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.StructExpand = true;

i_p.addRequired('acceptor_file',@(x)exist(x,'file') == 2);

i_p.addParameter('min_cell_area',20000,@(x)isnumeric(x) && x > 0);
i_p.addParameter('unimodal_correction',2,@(x)isnumeric(x) && x > 0);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(acceptor_file,varargin{:});

addpath(genpath('image_processing_misc'));

acceptor_image = double(imread(acceptor_file));
acceptor_image_norm = normalize_image(acceptor_image);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cell_regions = acceptor_image > 0;
cell_regions = bwpropopen(cell_regions,'Area',i_p.Results.min_cell_area,...
    'connectivity',8);
cell_regions = bwlabel(cell_regions,8);

rosin_regions = zeros(size(cell_regions,1),size(cell_regions,2));

for cell_region_num = 1:max(cell_regions(:))
    this_region = acceptor_image .* double(cell_regions == cell_region_num);
    acceptor_non_zero = nonzeros(this_region(:));
    
    unimodal_thresh_sets = [];
    
    for i = 500:10:1000
        [hist_peaks,hist_centers] = hist(acceptor_non_zero(:),i);
        unimodal_thresh_sets = [unimodal_thresh_sets,hist_centers(RosinThresh(hist_peaks))]; %#ok<AGROW>
    end
    
    rosin_high_thresh = this_region > mean(unimodal_thresh_sets)*8;
    rosin_high_thresh = bwpropopen(rosin_high_thresh,'Area',i_p.Results.min_cell_area,...
        'connectivity',4);
    rosin_high_thresh = fill_small_holes(rosin_high_thresh,50);
    rosin_regions(rosin_high_thresh) = 1;
    
    %find regions which appear to be part of a cell
    primary_cell_body = this_region > mean(unimodal_thresh_sets)*i_p.Results.unimodal_correction;
    primary_cell_body = bwpropopen(primary_cell_body,'Area',i_p.Results.min_cell_area,...
        'connectivity',4);
    primary_cell_body = fill_small_holes(primary_cell_body,50);
    rosin_regions(primary_cell_body & not(rosin_regions)) = 2;
    
    %find dimmer structures that are still above background
    high_passed_image = apply_high_pass_filter(this_region,15);
    
    high_passed_pixels = nonzeros(high_passed_image);
    
    high_threshed = high_passed_image > std(high_passed_pixels(:));
    high_threshed = bwpropopen(high_threshed,'Area',10);
    high_threshed_label = bwlabel(high_threshed,4);
    
    %overlap the confident cell body image with the labeled dim object image
    %and pick out only those connected objects which touch the confident cell
    %body image
    cell_body_overlap_labels = nonzeros(unique(high_threshed_label.*primary_cell_body));
    cell_region = primary_cell_body | ismember(high_threshed_label,cell_body_overlap_labels);
    
    rosin_regions(cell_region & not(primary_cell_body)) = 3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualizations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vis_label = uint16(bwperim(rosin_regions > 0));
vis_label(bwperim(rosin_regions > 0 & rosin_regions <= 2)) = 2;
vis_label(acceptor_image == 0) = 3;

cmap = [1,0,0;0,1,0;1,1,0];

cell_vis_image = create_highlighted_image(acceptor_image_norm,vis_label,'color_map',cmap);

cmap = [1,0,1;0,1,0;0,0,1];
rosin_thresh_vis = create_highlighted_image(acceptor_image_norm,rosin_regions,'color_map',cmap,'mix_percent',0.25);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[folder,file] = fileparts(acceptor_file);

imwrite_with_folder_creation(rosin_regions > 0,...
    fullfile(folder,'..','cell_masks',[file '.png']));

imwrite_with_folder_creation(rosin_thresh_vis,...
    fullfile(folder,'..','rosin_thresh_vis',[file '.png']));

imwrite_with_folder_creation(uint8(rosin_regions),...
    fullfile(folder,'..','rosin_thresh',[file '.png']));

imwrite_with_folder_creation(cell_vis_image,...
    fullfile(folder,'..','cell_mask_vis',[file '.png']));
%
% if (i_p.Results.debug)
%     addpath('../visualize_cell_features/');
%
%     acceptor_image_orig = double(imread(acceptor_file));
%     mask_min_max = csvread(fullfile(fileparts(acceptor_file),filenames.raw_mask_min_max));
%     acceptor_image_orig_norm = (acceptor_image_orig - min(mask_min_max))/range(mask_min_max);
%
%     edge_highlight = create_highlighted_image(acceptor_image_orig_norm,bwperim(threshed_mask),'color_map',[1,0,0]);
%     [pathstr,name, ~] = fileparts(acceptor_file);
%     out_file = fullfile(pathstr,[name,'_edge.png']);
%
%     imwrite(edge_highlight,out_file);
% end