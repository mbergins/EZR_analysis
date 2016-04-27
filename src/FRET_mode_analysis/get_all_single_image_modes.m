function get_all_single_image_modes(base_dir,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('base_dir',@(x)exist(x,'dir') == 7);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(base_dir,varargin{:});

addpath(genpath('../image_processing_misc/'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Index Modes
index = struct();

output_headers = {};

exp_folders = dir(base_dir); exp_folders = exp_folders(3:end);

for i = 1:length(exp_folders)
    if (isdir(fullfile(base_dir,exp_folders(i).name)))
        fixed_name = matlab.lang.makeValidName(exp_folders(i).name);
        output_headers{end+1} = exp_folders(i).name; %#ok<AGROW>
        index.(fixed_name) = get_FRET_modes_dual(fullfile(base_dir,exp_folders(i).name));
    end
end

output_data = convert_struct_to_matrix(index);

csvwrite_with_headers(fullfile(base_dir,'index_hist_modes.csv'),...
    output_data,output_headers);

%Efficiency Modes
eff = struct();

output_headers = {};

exp_folders = dir(base_dir); exp_folders = exp_folders(3:end);

for i = 1:length(exp_folders)
    if (isdir(fullfile(base_dir,exp_folders(i).name)))
        fixed_name = matlab.lang.makeValidName(exp_folders(i).name);
        output_headers{end+1} = exp_folders(i).name; %#ok<AGROW>
        eff.(fixed_name) = get_FRET_modes_dual(fullfile(base_dir,exp_folders(i).name),...
            'search_folder','Efficiency');
    end
end

output_data = convert_struct_to_matrix(eff);

csvwrite_with_headers(fullfile(base_dir,'eff_hist_modes.csv'),...
    output_data,output_headers);

%DPA Modes
dpa = struct();

output_headers = {};

exp_folders = dir(base_dir); exp_folders = exp_folders(3:end);

for i = 1:length(exp_folders)
    if (isdir(fullfile(base_dir,exp_folders(i).name)))
        fixed_name = matlab.lang.makeValidName(exp_folders(i).name);
        output_headers{end+1} = exp_folders(i).name; %#ok<AGROW>
        dpa.(fixed_name) = get_FRET_modes_dual(fullfile(base_dir,exp_folders(i).name),...
            'search_folder','DPA','search_quantile',1);
    end
end

output_data = convert_struct_to_matrix(dpa);

csvwrite_with_headers(fullfile(base_dir,'dpa_hist_modes.csv'),...
    output_data,output_headers);


system('notify-send ''Done with Processing''')