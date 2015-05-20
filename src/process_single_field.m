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

% for i = 1:length(acceptor_files)
%     find_cell_mask_region_thresh(fullfile(acceptor_folder,acceptor_files{i}));
% end

FRET_folder = fullfile(exp_folder,'FRET');
FRET_files = file_search('.*',FRET_folder);

% %FRET Highlighting
% for i = 1:length(acceptor_files)
%     highlight_low_FRET(fullfile(acceptor_folder,acceptor_files{i}), ...
%         fullfile(acceptor_folder,FRET_files{i}),...
%         0.37);
%     fprintf('Done with %d\n', i);
% end

%FRET Analysis
cell_mask_folder = fullfile(exp_folder,'cell_masks');
cell_mask_files = file_search('.*',cell_mask_folder);

rosin_thresh_folder = fullfile(exp_folder,'rosin_thresh');
rosin_thresh_files = file_search('.*',rosin_thresh_folder);

assert(length(cell_mask_files) == length(FRET_files));
rosin_means = [];
for i = 1:length(cell_mask_files)
    rosin_temp = measure_FRET_from_edge(fullfile(FRET_folder,FRET_files{i}),...
        fullfile(cell_mask_folder,cell_mask_files{i}),...
        fullfile(acceptor_folder,acceptor_files{i}),...
        fullfile(rosin_thresh_folder,rosin_thresh_files{i}));
    
    rosin_means = [rosin_means; rosin_temp];
end

csvwrite(fullfile(exp_folder,'rosin_means.csv'),rosin_means);

mins = toc(start_full)/60;

fprintf('Full EZR analysis took %0.1f minutes for %d images\n',mins,length(acceptor_files));