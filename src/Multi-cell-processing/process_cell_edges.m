function process_cell_edges(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

addpath(genpath('image_processing_misc'));
addpath(genpath('../shared'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_set = get_filenames(exp_folder);

data_set = struct('Image_num',[],'Obj_num',[],'Area',[],...
    'MajorAxisLength',[],'MinorAxisLength',[],'AcceptorMean',[],...
    'FRETMean',[],'DPAMean',[],'EffMean',[]);

ezr_regions = struct('Edge_eff_mode',[],'Non_edge_eff_mode',[]);

for i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num});
    FRET = imread(file_set.FRET{i_num});
    DPA = imread(file_set.DPA{i_num});
    Eff = imread(file_set.Eff{i_num});
    
    non_edge_mask = imread(file_set.non_edge_mask{i_num});
    edge_mask = imread(file_set.edge_mask{i_num});
    
    ezr_regions.Edge_eff_mode = [ezr_regions.Edge_eff_mode,...
        find_hist_mode(Eff(edge_mask),'limits',[0,1])];
    ezr_regions.Non_edge_eff_mode = [ezr_regions.Non_edge_eff_mode,...
        find_hist_mode(Eff(non_edge_mask),'limits',[0,1])];
    
    props = regionprops(edge_mask,Acceptor,'Area','MajorAxisLength',...
        'MinorAxisLength','MeanIntensity');
    
    FRET_props = regionprops(edge_mask,FRET,'MeanIntensity');
    DPA_props = regionprops(edge_mask,DPA,'MeanIntensity');
    Eff_props = regionprops(edge_mask,Eff,'MeanIntensity');
    
    
    data_set.Image_num = [data_set.Image_num; i_num*ones(length(props),1)];
    data_set.Obj_num = [data_set.Obj_num; (1:length(props))'];
        
    data_set.Area = [data_set.Area; [props.Area]'];
    data_set.MajorAxisLength = [data_set.MajorAxisLength; [props.MajorAxisLength]'];
    data_set.MinorAxisLength = [data_set.MinorAxisLength; [props.MinorAxisLength]'];
    data_set.AcceptorMean = [data_set.AcceptorMean; [props.MeanIntensity]'];
    
    data_set.FRETMean = [data_set.FRETMean; [FRET_props.MeanIntensity]'];
    data_set.DPAMean = [data_set.DPAMean; [DPA_props.MeanIntensity]'];
    data_set.EffMean = [data_set.EffMean; [Eff_props.MeanIntensity]'];
end
data_set_mat = convert_struct_to_matrix(data_set);
csvwrite_with_headers(fullfile(exp_folder,'EZR_objs.csv'),data_set_mat,...
    fieldnames(data_set));

ezr_regions_mat = convert_struct_to_matrix(ezr_regions);
csvwrite_with_headers(fullfile(exp_folder,'EZR_regions.csv'),ezr_regions_mat,...
    fieldnames(ezr_regions));

end