function find_cell_mask(acceptor_file,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.StructExpand = true;

i_p.addRequired('acceptor_file',@(x)exist(x,'file') == 2);

i_p.addParameter('min_cell_area',20000,@(x)isnumeric(x) && x > 0);
i_p.addParameter('unimodal_correction',3,@(x)isnumeric(x) && x > 0);
i_p.addParameter('min_region_intensity_average',500,@(x)isnumeric(x) && x > 0);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(acceptor_file,varargin{:});

addpath(genpath('image_processing_misc'));

acceptor_image = double(imread(acceptor_file));
acceptor_image_norm = normalize_image(acceptor_image);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find regions to look for cells
cell_regions = acceptor_image > 0;
cell_regions = bwpropopen(cell_regions,'Area',i_p.Results.min_cell_area,...
    'connectivity',8);
cell_regions = bwlabel(cell_regions,8);

region_props = regionprops(cell_regions,acceptor_image,'MeanIntensity'); %#ok<MRPBW>

cell_regions = ismember(cell_regions,...
    find([region_props.MeanIntensity] > i_p.Results.min_region_intensity_average));
cell_regions = bwlabel(cell_regions,8);

cell_structure_type = zeros(size(acceptor_image,1),size(acceptor_image,2));
cell_label = zeros(size(acceptor_image,1),size(acceptor_image,2));

for cell_region_num = 1:max(cell_regions(:))
    this_region_binary = cell_regions == cell_region_num;
    this_region = acceptor_image .* double(this_region_binary);
    acceptor_non_zero = nonzeros(this_region(:));
    
    unimodal_thresh_sets = [];
    
    for i = 500:10:1000
        [hist_peaks,hist_centers] = hist(acceptor_non_zero(:),i);
        unimodal_thresh_sets = [unimodal_thresh_sets,hist_centers(RosinThresh(hist_peaks))]; %#ok<AGROW>
    end
    
    %find regions which appear to be part of a cell
    primary_cell_body = this_region > mean(unimodal_thresh_sets)*i_p.Results.unimodal_correction;
    primary_cell_body = bwpropopen(primary_cell_body,'Area',i_p.Results.min_cell_area,...
        'connectivity',4);
    primary_cell_body = fill_small_holes(primary_cell_body,50);
    
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
    cell_body_overlap = ismember(high_threshed_label,cell_body_overlap_labels);
    
    cell_structure_type(cell_body_overlap) = 2;
    cell_structure_type(primary_cell_body) = 1;
    
    cell_label(cell_body_overlap | primary_cell_body) = 1;
end

cell_label = bwlabel(cell_label,8);

thick_perims = thicken_perimeter(bwperim(cell_label),cell_label);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualizations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vis_label = thick_perims;
vis_label(acceptor_image == 0) = 3;

cmap = [1,0,0;0,1,0;1,1,0];

cell_vis_image = create_highlighted_image(acceptor_image_norm,vis_label,'color_map',cmap);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[folder,file] = fileparts(acceptor_file);

imwrite_with_folder_creation(uint8(cell_label),...
    fullfile(folder,'..','cell_label',[file '.png']));

imwrite_with_folder_creation(cell_vis_image,...
    fullfile(folder,'..','cell_mask_vis',[file '.png']));
