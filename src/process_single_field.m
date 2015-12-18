function process_single_field(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_full = tic;

i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

addpath(genpath('image_processing_misc'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Cell Mask Generation
acceptor_folder = fullfile(exp_folder,'Acceptor');
acceptor_files = file_search('.*',acceptor_folder);

for i = 1:length(acceptor_files)
    find_cell_mask(fullfile(acceptor_folder,acceptor_files{i}));
end

gather_per_cell_props(exp_folder);

process_images_with_mask(exp_folder);

mins = toc(start_full)/60;

fprintf('Full EZR analysis took %0.1f minutes for %d images\n',mins,length(acceptor_files));