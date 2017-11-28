function crop_pattern_timelapse(field_folder,crop_centers,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.StructExpand = true;

i_p.addRequired('field_folder',@(x)exist(x,'dir') == 7);
i_p.addRequired('crop_centers',@isnumeric);

i_p.addParameter('crop_dimensions',[400,400],@isnumeric);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(field_folder,crop_centers,varargin{:});

addpath(genpath('../../image_processing_misc/'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

image_type_folders = dir(field_folder);
%get rid of the self and one up folder references
image_type_folders = image_type_folders(3:end);

for i = 1:length(image_type_folders)
    full_image_folder = fullfile(field_folder, image_type_folders(i).name);
    
    if (~ isdir(full_image_folder)), continue; end
    
    image_filenames = dir(full_image_folder);
    image_filenames = image_filenames(3:end);
    
    for j = 1:length(image_filenames)
        image = imread(fullfile(full_image_folder,image_filenames(j).name));
        for k = 1:size(crop_centers,1)
            x_crop = crop_centers(k,1) - i_p.Results.crop_dimensions(1)/2;
            if (x_crop < 1), x_crop = 1; end
            y_crop = crop_centers(k,2) - i_p.Results.crop_dimensions(2)/2;
            if (y_crop < 1), y_crop = 1; end
            
            crop_rect = [x_crop,y_crop,i_p.Results.crop_dimensions(1),...
                i_p.Results.crop_dimensions(2)];
            
            image_crop = imcrop(image,crop_rect);
            
            out_folder = sprintf('%s-%d',fileparts(field_folder),k);
            
            mkdir_no_err(fullfile(out_folder,image_type_folders(i).name));
            
            imwrite2tif(image_crop,[],...
                fullfile(out_folder,image_type_folders(i).name,image_filenames(j).name),...
                'single')
        end
    end    
end