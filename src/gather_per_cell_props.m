function gather_per_cell_props(exp_folder,varargin)

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

acceptor_files = file_search('.*',fullfile(exp_folder,'Acceptor'),...
    'return_complete_files',1);
donor_files = file_search('.*',fullfile(exp_folder,'Donor'),...
    'return_complete_files',1);
FRET_files = file_search('.*',fullfile(exp_folder,'FRET'),...
    'return_complete_files',1);
DPA_files = file_search('.*',fullfile(exp_folder,'DPA'),...
    'return_complete_files',1);
eff_files = file_search('.*',fullfile(exp_folder,'Efficiency'),...
    'return_complete_files',1);


cell_mask_files = file_search('.*',fullfile(exp_folder,'cell_label'),...
    'return_complete_files',1);

data_set = struct('image_num',[],'cell_num',[],'Acceptor_mean',[],...
    'Donor_mean',[],'FRET_mean',[],'DPA_mean',[],'Efficiency_mean',[]);

for i_num = 1:length(acceptor_files)
    cell_mask = imread(cell_mask_files{i_num});
    
    acceptor = imread(acceptor_files{i_num});
    donor = imread(donor_files{i_num});
    FRET = imread(FRET_files{i_num});
    DPA = imread(DPA_files{i_num});
    eff = imread(eff_files{i_num});
    
    nonzero_regions = acceptor ~= 0;
    
    for cell_num = 1:max(cell_mask(:))
        this_cell = cell_mask == cell_num;
        this_cell = this_cell & nonzero_regions;
        
        data_set.image_num = [data_set.image_num,i_num];
        data_set.cell_num = [data_set.cell_num,cell_num];
        
        data_set.Acceptor_mean = [data_set.Acceptor_mean,...
            mean(acceptor(this_cell))];
        data_set.Donor_mean = [data_set.Donor_mean,...
            mean(donor(this_cell))];        
        data_set.FRET_mean = [data_set.FRET_mean,...
            mean(FRET(this_cell))];
        data_set.DPA_mean = [data_set.DPA_mean,...
            mean(DPA(this_cell))];        
        data_set.Efficiency_mean = [data_set.Efficiency_mean,...
            mean(eff(this_cell))];        
        
    end
end

data_mat = convert_struct_to_matrix(data_set);

headers = {'Image Number','Cell Number','Acceptor Mean','Donor Mean',...
    'FRET Mean','DPA Mean','Efficiency Mean'};

csvwrite_with_headers(fullfile(exp_folder,'per_cell_data.csv'),data_mat,...
    headers);