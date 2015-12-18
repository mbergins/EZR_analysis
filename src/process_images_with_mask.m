function rosin_means = process_images_with_mask(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x) x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

addpath(genpath('image_processing_misc'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file_set = get_filenames(i_p.Results.exp_folder);

for i = 1:length(file_set.Acceptor)
    cell_label = imread(file_set.cell_label{i});
    cell_mask = cell_label > 0;
    
    FRET = imread(file_set.FRET{i});
    FRET_med = medfilt2(FRET,[5 5]);
    
    [folder,FRET_file] = fileparts(file_set.FRET{i});
    
    output_folder = fullfile(folder,'..','median_masked_FRET');
    mkdir_no_err(output_folder);
    out_file = fullfile(output_folder,[FRET_file '.tif']);
    imwrite2tif(FRET_med.*cell_mask,[],out_file,'single');
    
    Eff = imread(file_set.Eff{i});
    Eff_med = medfilt2(Eff,[5 5]);
    
    [~,Eff_file] = fileparts(file_set.FRET{i});
    
    output_folder = fullfile(folder,'..','median_masked_Eff');
    mkdir_no_err(output_folder);
    out_file = fullfile(output_folder,[Eff_file '.tif']);
    imwrite2tif(Eff_med.*cell_mask,[],out_file,'single');
end

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