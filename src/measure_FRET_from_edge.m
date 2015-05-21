function rosin_means = measure_FRET_from_edge(FRET_file,mask_file,acceptor_file,rosin_file,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('FRET_file',@(x)exist(x,'file') == 2);
i_p.addRequired('mask_file',@(x)exist(x,'file') == 2);
i_p.addRequired('acceptor_file',@(x)exist(x,'file') == 2);
i_p.addRequired('rosin_file',@(x)exist(x,'file') == 2);

i_p.addParamValue('debug',0,@(x)x==1 || x==0);

i_p.parse(FRET_file,mask_file,acceptor_file,rosin_file,varargin{:});

addpath(genpath('image_processing_misc'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Reading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cell_mask = imread(mask_file);
rosin_thresh = imread(rosin_file);

FRET = imread(FRET_file);
FRET_med = medfilt2(FRET,[5 5]);

acceptor_image = imread(acceptor_file);
acceptor_norm = normalize_image(acceptor_image,'quantiles',[0.01,0.99]);

[folder,file] = fileparts(FRET_file);

% output_folder = fullfile(folder,'..','masked_FRET');
% mkdir_no_err(output_folder);
% out_file = fullfile(output_folder,[file '.tif']);
% imwrite2tif(FRET.*cell_mask,[],out_file,'single');
% 
output_folder = fullfile(folder,'..','median_masked_FRET');
mkdir_no_err(output_folder);
out_file = fullfile(output_folder,[file '.tif']);
imwrite2tif(FRET_med.*cell_mask,[],out_file,'single');

% output_folder = fullfile(folder,'..','median_FRET');
% mkdir_no_err(output_folder);
% out_file = fullfile(output_folder,[file '.tif']);
% imwrite2tif(FRET_med,[],out_file,'single');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rosin_means = NaN*ones(1,3);
% for i = 1:3
%     rosin_means(i) = mean(FRET_med(rosin_thresh == i));
% end
% 
% cell_mask_label = bwlabel(cell_mask);
% high_tension_highlight = acceptor_norm;
% 
% for i = 1:max(cell_mask_label(:))
%     this_cell = cell_mask_label == i;
%     these_FRET_pixels = FRET_med(this_cell);
% 
%     high_tension_threshold = quantile(these_FRET_pixels,0.05);
%     
%     high_tension = FRET_med <= high_tension_threshold;
%     high_tension = high_tension .* cell_mask;
% 
%     high_tension_highlight = create_highlighted_image(high_tension_highlight,...
%         high_tension,'mix_percent',0.5);
% end
% 
% high_tension_highlight = imresize(high_tension_highlight,0.5);
% 
% output_folder = fullfile(folder,'..','high_tension_high');
% mkdir_no_err(output_folder);
% out_file = fullfile(output_folder,[file '.png']);
% imwrite(high_tension_highlight,out_file);


% 
% [folder,filename] = fileparts(FRET_file);
% 
% output_folder = fullfile(folder,'..','FRET_from_edge');
% mkdir_no_err(output_folder);
% 
% for i = 1:max(cell_mask_label(:))
%     mean_pix_intensities = [];
% 
%     this_cell = not(cell_mask_label == i);
%     
%     this_cell_dists = bwdist(this_cell);
%     
%     
%     bounds = 0:2:max(this_cell_dists(:));
%     
%     for j = 2:length(bounds)
%         this_ring = this_cell_dists > bounds(j-1) & this_cell_dists <= bounds(j);
%         mean_pix_intensities(j-1) = mean(FRET(this_ring));
%     end
%     
%     output_file = fullfile(output_folder,sprintf('%s_cell_%02d.csv',filename,i));
%     csvwrite(output_file,mean_pix_intensities);
% end