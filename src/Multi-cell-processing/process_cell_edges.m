function process_cell_edges(exp_folder,varargin)

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

data_set = struct('Image_num',[],'Obj_num',[],'Area',[],...
    'MajorAxisLength',[],'MinorAxisLength',[],'Solidity',[],...
    'AcceptorMean',[],'AcceptorBackground',[],'DonorMean',[],'FRETMean',[],...
    'DPAMean',[],'EffMean',[],'EffBackground',[],'Centroid_x',[],'Centroid_y',[]);

ezr_regions = struct('Edge_eff_mode',[],'Non_edge_eff_mode',[],...
    'wide_non_edge_eff_mode',[]);

for i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num});
    Donor = imread(file_set.Donor{i_num});
    FRET = imread(file_set.FRET{i_num});
    DPA = imread(file_set.DPA{i_num});
    Eff = imread(file_set.Eff{i_num});
    
    non_edge_mask = imread(file_set.non_edge_mask{i_num});
    wide_non_edge_mask = imread(file_set.wide_non_edge_mask{i_num});
    edge_mask = imread(file_set.edge_mask{i_num});
    edge_mask_label = imread(file_set.edge_mask_label{i_num});
    cell_mask = edge_mask | non_edge_mask;
    
    ezr_regions.Edge_eff_mode = [ezr_regions.Edge_eff_mode,...
        find_hist_mode(Eff(edge_mask),'limits',[0.01,0.99])];
    ezr_regions.Non_edge_eff_mode = [ezr_regions.Non_edge_eff_mode,...
        find_hist_mode(Eff(non_edge_mask),'limits',[0.01,0.99])];
    ezr_regions.wide_non_edge_eff_mode = [ezr_regions.wide_non_edge_eff_mode,...
        find_hist_mode(Eff(wide_non_edge_mask),'limits',[0.01,0.99])];
    
    props = regionprops(edge_mask_label,Acceptor,'Area','MajorAxisLength',...
        'MinorAxisLength','MeanIntensity','Solidity','Centroid');
    
    centroid_props = reshape([props.Centroid],[2],[]);
    
    Donor_props = regionprops(edge_mask_label,Donor,'MeanIntensity');
    FRET_props = regionprops(edge_mask_label,FRET,'MeanIntensity');
    DPA_props = regionprops(edge_mask_label,DPA,'MeanIntensity');
    Eff_props = regionprops(edge_mask_label,Eff,'MeanIntensity');
    
    eff_background = get_background_region_mean(edge_mask_label,Eff);
    acc_background = get_background_region_mean(edge_mask_label,Acceptor);
    
    data_set.Image_num = [data_set.Image_num; i_num*ones(length(props),1)];
    data_set.Obj_num = [data_set.Obj_num; (1:length(props))'];
    
    data_set.Area = [data_set.Area; [props.Area]'];
    data_set.MajorAxisLength = [data_set.MajorAxisLength; [props.MajorAxisLength]'];
    data_set.MinorAxisLength = [data_set.MinorAxisLength; [props.MinorAxisLength]'];
    data_set.Solidity = [data_set.Solidity; [props.Solidity]'];
    data_set.AcceptorMean = [data_set.AcceptorMean; [props.MeanIntensity]'];
    data_set.AcceptorBackground = [data_set.AcceptorBackground; acc_background'];
    data_set.DonorMean = [data_set.DonorMean; [Donor_props.MeanIntensity]'];
    
    data_set.FRETMean = [data_set.FRETMean; [FRET_props.MeanIntensity]'];
    data_set.DPAMean = [data_set.DPAMean; [DPA_props.MeanIntensity]'];
    data_set.EffMean = [data_set.EffMean; [Eff_props.MeanIntensity]'];
    data_set.EffBackground = [data_set.EffBackground; eff_background'];
    data_set.Centroid_x = [data_set.Centroid_x; centroid_props(1,:)'];
    data_set.Centroid_y = [data_set.Centroid_y; centroid_props(2,:)'];
end

data_set_mat = convert_struct_to_matrix(data_set);
csvwrite_with_headers(fullfile(exp_folder,'EZR_objs.csv'),data_set_mat,...
    fieldnames(data_set));

ezr_regions_mat = convert_struct_to_matrix(ezr_regions);
csvwrite_with_headers(fullfile(exp_folder,'EZR_regions.csv'),ezr_regions_mat,...
    fieldnames(ezr_regions));

end


function background_vals = get_background_region_mean(labeled_region,background)
    background_vals = NaN*ones(1,max(labeled_region(:)));
    for obj_num = 1:max(labeled_region(:))
        this_obj = labeled_region == obj_num;
        
        this_background_region = imdilate(this_obj,strel('disk',10)) & ...
            not(labeled_region);
        
        background_vals(obj_num) = mean(background(this_background_region));
    end
end