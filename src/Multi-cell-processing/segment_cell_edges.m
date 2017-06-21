function segment_cell_edges(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

addpath(genpath('../image_processing_misc'));
addpath(genpath('../shared'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_set = get_filenames(exp_folder);

parfor i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num});
    Acceptor_norm = normalize_image(imread(file_set.Acceptor{i_num}),...,
        'quantile',[0.05,0.99],'only_nonzero',1);

    %Pick out regions where EZR objects might be present
    cell_region = Acceptor > 100;
    
    %Also block regions around zeros, which result from overexposed
    %regions. Drop the region around those overexposed areas using a filter
    %of the same size as the high-pass 
    cell_region = cell_region & ~imdilate(Acceptor == 0,strel('disk',15));
    
    Acc_high = apply_high_pass_filter(Acceptor,15);
    
    edge_mask = Acc_high > 2*std(Acc_high(cell_region));
    
    edge_mask = bwpropopen(edge_mask,'Area',20,'connectivity',4);
    edge_mask = fill_small_holes(edge_mask,10);
    edge_mask = remove_edge_objects(edge_mask);
    edge_mask = edge_mask & cell_region;
    
    edge_mask_label = uint16(watershed_min_size(Acceptor,edge_mask,10));
    
    non_edge = Acceptor > std(Acceptor(:)) & imdilate(edge_mask,strel('disk',50)) & ~edge_mask;
    wide_non_edge = Acceptor > std(Acceptor(:)) & ...
        imdilate(edge_mask,strel('disk',50)) & ...
        ~imdilate(edge_mask,strel('disk',10));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Visualization
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    non_edge_hightlight = create_highlighted_image(Acceptor_norm,non_edge,'mix_percent',0.5);
    
    mask_highlight = create_highlighted_image(Acceptor_norm,edge_mask);
    mask_label_highlight = create_highlighted_image(Acceptor_norm,edge_mask_label);

    mkdir_no_err(fullfile(exp_folder,'Acceptor_norm'));
    imwrite(Acceptor_norm,fullfile(exp_folder,'Acceptor_norm',sprintf('%02d.png',i_num)));    
    
    mkdir_no_err(fullfile(exp_folder,'edge_mask'));
    imwrite(edge_mask,fullfile(exp_folder,'edge_mask',sprintf('%02d.png',i_num)));

    mkdir_no_err(fullfile(exp_folder,'edge_mask_label'));
    imwrite(edge_mask_label,fullfile(exp_folder,'edge_mask_label',sprintf('%02d.png',i_num)));
    
    mkdir_no_err(fullfile(exp_folder,'edge_mask_highlight'));
    imwrite(mask_highlight,fullfile(exp_folder,'edge_mask_highlight',sprintf('%02d.png',i_num)));
    
    mkdir_no_err(fullfile(exp_folder,'edge_label_highlight'));
    imwrite(mask_label_highlight,fullfile(exp_folder,'edge_label_highlight',sprintf('%02d.png',i_num)));
    
    mkdir_no_err(fullfile(exp_folder,'non_edge_mask'));
    imwrite(non_edge,fullfile(exp_folder,'non_edge_mask',sprintf('%02d.png',i_num)));

    mkdir_no_err(fullfile(exp_folder,'wide_non_edge_mask'));
    imwrite(wide_non_edge,fullfile(exp_folder,'wide_non_edge_mask',sprintf('%02d.png',i_num)));
    
    mkdir_no_err(fullfile(exp_folder,'non_edge_mask_highlight'));
    imwrite(non_edge_hightlight,fullfile(exp_folder,'non_edge_mask_highlight',sprintf('%02d.png',i_num)));
end