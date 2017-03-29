function build_visualizations(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);
i_p.addParameter('Eff_limits',[0.20,0.30],@(x)isnumeric(x) & ...
    length(x) == 2 & x(1) < x(2));

i_p.parse(exp_folder,varargin{:});

addpath(genpath('../image_processing_misc'));
addpath(genpath('../shared'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_set = get_filenames(exp_folder);

c_map = [0,0,0;jet(255)];
mkdir_no_err(fullfile(exp_folder,'visualizations'));
imwrite(output_color_map(c_map),...
    fullfile(exp_folder,'visualizations','scale_bar.png'));
imwrite(output_color_map(c_map,'labels',i_p.Results.Eff_limits),...
    fullfile(exp_folder,'visualizations','scale_bar_labels.png'));

for i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num});
    Acceptor_norm = normalize_image(Acceptor);
    FRET = imread(file_set.FRET{i_num});
    DPA = imread(file_set.DPA{i_num});
    Eff = imread(file_set.Eff{i_num});
    
    edge_mask = imread(file_set.edge_mask{i_num});
    edge_mask_label = imread(file_set.edge_mask_label{i_num});
    
    props = regionprops(edge_mask,Acceptor,'Area','MajorAxisLength',...
        'MinorAxisLength','MeanIntensity');
    
    Eff_props = regionprops(edge_mask,Eff,'MeanIntensity');

    No_force_highlight = create_highlighted_image(Acceptor_norm,Eff > 0.27 & Acceptor > 1000);
    imwrite(No_force_highlight,fullfile(exp_folder,'visualizations',...
        sprintf('No_force_%02d.png',i_num)));
    
    Eff_mean = make_mean_image(edge_mask_label,Eff_props,'MeanIntensity');
    Eff_mean_color = colorize_image(Eff_mean,c_map, ...
        'normalization_limits',i_p.Results.Eff_limits);
    imwrite(Eff_mean_color,fullfile(exp_folder,'visualizations',...
        sprintf('Eff_mean_%02d.png',i_num)));
end

end

function mean_image = make_mean_image(label,props,mean_prop_name)
    this_mean_set = [props.(mean_prop_name)];
    mean_image = zeros(size(label,1),size(label,2));
    for i = 1:length(this_mean_set)
        mean_image(label == i) = this_mean_set(i);
    end
end