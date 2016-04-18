function file_struct = get_filenames(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x) x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_struct = struct();

file_struct.Acceptor = file_search('.*',fullfile(i_p.Results.exp_folder,'Acceptor'),...
    'return_complete_files',1);

file_struct.Donor = file_search('.*',fullfile(i_p.Results.exp_folder,'Donor'),...
    'return_complete_files',1);

file_struct.FRET = file_search('.*',fullfile(i_p.Results.exp_folder,'FRET'),...
    'return_complete_files',1);

file_struct.DPA = file_search('.*',fullfile(i_p.Results.exp_folder,'DPA'),...
    'return_complete_files',1);

file_struct.Eff = file_search('.*',fullfile(i_p.Results.exp_folder,'Efficiency'),...
    'return_complete_files',1);

file_struct.cell_label = file_search('.*',fullfile(i_p.Results.exp_folder,'cell_label'),...
    'return_complete_files',1);

file_struct.edge_mask = file_search('.*',fullfile(i_p.Results.exp_folder,'edge_mask'),...
    'return_complete_files',1);

