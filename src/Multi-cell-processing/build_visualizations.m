function build_visualizations(exp_folder,varargin)

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

c_map = [0,0,0;jet(255)];
mkdir_no_err(fullfile(exp_folder,'visualizations'));
imwrite(output_color_map(c_map),fullfile(exp_folder,'visualizations','scale_bar.png'));

for i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num});
    FRET = imread(file_set.FRET{i_num});
    DPA = imread(file_set.DPA{i_num});
    Eff = imread(file_set.Eff{i_num});
    
    edge_mask = imread(file_set.edge_mask{i_num});
    edge_mask_label = bwlabel(edge_mask,4);
    
    props = regionprops(edge_mask,Acceptor,'Area','MajorAxisLength',...
        'MinorAxisLength','MeanIntensity');
    
    FRET_props = regionprops(edge_mask,FRET,'MeanIntensity');
    DPA_props = regionprops(edge_mask,DPA,'MeanIntensity');
    Eff_props = regionprops(edge_mask,Eff,'MeanIntensity');

    
    FRET_mean = make_mean_image(edge_mask_label,FRET_props,'MeanIntensity');
    FRET_mean_color = colorize_image(FRET_mean,c_map,'normalization_limits',[0.2,0.6]);
    imwrite(FRET_mean_color,fullfile(exp_folder,'visualizations',sprintf('FRET_mean_%02d.png',i_num)));
    
    DPA_mean = make_mean_image(edge_mask_label,DPA_props,'MeanIntensity');
    DPA_mean_color = colorize_image(DPA_mean,c_map,'normalization_limits',[0.75,1.5]);
    imwrite(DPA_mean_color,fullfile(exp_folder,'visualizations',sprintf('DPA_mean_%02d.png',i_num)));

    Eff_mean = make_mean_image(edge_mask_label,Eff_props,'MeanIntensity');
    Eff_mean_color = colorize_image(Eff_mean,c_map,'normalization_limits',[0.15,0.30]);
    imwrite(Eff_mean_color,fullfile(exp_folder,'visualizations',sprintf('Eff_mean_%02d.png',i_num)));
end

end


function mean_image = make_mean_image(label,props,mean_prop_name)
    this_mean_set = [props.(mean_prop_name)];
    mean_image = zeros(size(label,1),size(label,2));
    for i = 1:length(this_mean_set)
        mean_image(label == i) = this_mean_set(i);
    end
end
