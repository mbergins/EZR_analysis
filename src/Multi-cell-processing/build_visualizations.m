function build_visualizations(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);
i_p.addParameter('Eff_limits',[0.20,0.3],@(x)isnumeric(x) & ...
    length(x) == 2 & x(1) < x(2));
i_p.addParameter('Eff_correction',1,@(x)isnumeric(x) & ...
    length(x) == 1);
i_p.addParameter('Acc_norm',[0,1],@(x)isnumeric(x) & length(x) == 2 & ...
    x(1) < x(2));

i_p.parse(exp_folder,varargin{:});

addpath(genpath('../image_processing_misc'));
addpath(genpath('../shared'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_set = get_filenames(exp_folder);

eff_c_map = [0,0,0;jet(255)];

vis_folder = fullfile(exp_folder,'visualizations');

mkdir_no_err(vis_folder);

imwrite(output_color_map(eff_c_map,'labels',i_p.Results.Eff_limits),...
    fullfile(vis_folder,'scale_bar_labels.png'));

imwrite(output_color_map(eff_c_map),...
    fullfile(vis_folder,'scale_bar.png'));

acc_c_map = gray(255);

acc_folder = fullfile(exp_folder,'Acceptor_norm');

mkdir_no_err(acc_folder)

imwrite(output_color_map(acc_c_map),...
    fullfile(acc_folder,'scale_bar.png'));

if (not(any(strcmp(i_p.UsingDefaults,{'Acc_norm'}))))
    imwrite(output_color_map(acc_c_map,'labels',i_p.Results.Acc_norm),...
        fullfile(acc_folder,'scale_bar_labels.png'));
end

parfor i_num = 1:length(file_set.Acceptor)
    Acceptor = imread(file_set.Acceptor{i_num}); %#ok<PFBNS>
    if (not(any(strcmp(i_p.UsingDefaults,{'Acc_norm'})))) %#ok<PFBNS>
        Acceptor_norm = normalize_image(Acceptor,'limits',i_p.Results.Acc_norm)
    else
        Acceptor_norm = normalize_image(Acceptor)
    end
    
    imwrite(Acceptor_norm,fullfile(exp_folder,'Acceptor_norm',sprintf('%02d.png',i_num)));
    
    Eff = imread(file_set.Eff{i_num});
    Eff = Eff * i_p.Results.Eff_correction
    
    edge_mask_label = imread(file_set.edge_mask_label{i_num});
    
    Eff_props = regionprops(edge_mask_label,Eff,'MeanIntensity');
    
    Eff_mean = make_mean_image(edge_mask_label,Eff_props,'MeanIntensity');
    Eff_mean_color = colorize_image(Eff_mean,eff_c_map,...
        'normalization_limits',i_p.Results.Eff_limits);
    imwrite(Eff_mean_color,...
        fullfile(vis_folder,sprintf('Eff_mean_%02d.png',i_num)));
    
    Eff_masked = Eff .* double(edge_mask_label > 0);
    Eff_color = colorize_image(Eff_masked,eff_c_map,...
        'normalization_limits',i_p.Results.Eff_limits);
    imwrite(Eff_color,...
        fullfile(vis_folder,sprintf('Eff_%02d.png',i_num)));
end

end

function mean_image = make_mean_image(label,props,mean_prop_name)
this_mean_set = [props.(mean_prop_name)];
mean_image = zeros(size(label,1),size(label,2));
for i = 1:length(this_mean_set)
    mean_image(label == i) = this_mean_set(i);
end
end
