function segment_cell_edges(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

addpath(genpath('image_processing_misc'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_set = get_filenames(exp_folder);

for i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num});
    Acceptor_norm = normalize_image(imread(file_set.Acceptor{i_num}),...,
        'quantile',[0.05,0.99],'only_nonzero',1);

    edge_mask = Acceptor > 500;
    
    Acc_high = apply_high_pass_filter(Acceptor,15);
    edge_mask = edge_mask & Acc_high > 0.5*std(Acc_high(:));
    
    edge_mask = bwpropopen(edge_mask,'Area',100);
    edge_mask = fill_small_holes(edge_mask,10);
    edge_mask = remove_edge_objects(edge_mask);
    
    edge_mask_label = bwlabel(edge_mask);
    
    mask_highlight = create_highlighted_image(Acceptor_norm,edge_mask);
    mask_label_highlight = create_highlighted_image(Acceptor_norm,edge_mask_label);

    mkdir_no_err(fullfile(exp_folder,'Acceptor_norm'));
    imwrite(Acceptor_norm,fullfile(exp_folder,'Acceptor_norm',sprintf('%02d.png',i_num)));    
    
    mkdir_no_err(fullfile(exp_folder,'edge_mask'));
    imwrite(edge_mask,fullfile(exp_folder,'edge_mask',sprintf('%02d.png',i_num)));

    mkdir_no_err(fullfile(exp_folder,'edge_mask_highlight'));
    imwrite(mask_highlight,fullfile(exp_folder,'edge_mask_highlight',sprintf('%02d.png',i_num)));
    
    mkdir_no_err(fullfile(exp_folder,'edge_label_highlight'));
    imwrite(mask_label_highlight,fullfile(exp_folder,'edge_label_highlight',sprintf('%02d.png',i_num)));
end