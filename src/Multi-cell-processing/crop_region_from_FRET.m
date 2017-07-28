function crop_region_from_FRET(field_folder,crop_position,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.StructExpand = true;

i_p.addRequired('field_folder',@(x)exist(x,'dir') == 7);
i_p.addRequired('crop_position',@(x)isnumeric(x) & length(x) == 4);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(field_folder,crop_position,varargin{:});

addpath(genpath('../image_processing_misc/'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search_folders = {'Acceptor','Donor','Efficiency','DPA','FRET'};

%this is a bit of a hack to get the folder name of the field and then
%concatenate the crop positions onto the end to make a unique folder name
%for the cropped output
split_folders = strsplit(i_p.Results.field_folder,filesep);
field_name = strcat(split_folders{end - 1},'_',num2str(crop_position(1)),'-',...
    num2str(crop_position(2)),'-',num2str(crop_position(3)),'-',...
    num2str(crop_position(4)));

output_folder = fullfile(i_p.Results.field_folder,'..','Crops',field_name);

mkdir_no_err(output_folder);

for i = 1:length(search_folders)
    source_dir = fullfile(i_p.Results.field_folder,search_folders{i});
    file_hits = dir(source_dir);
    file_hits = file_hits(3:end);
    
    assert(not(isempty(file_hits)));
    
    mkdir_no_err(fullfile(output_folder,search_folders{i}));
    
    for j = 1:length(file_hits)
        this_image = imread(fullfile(source_dir,file_hits(j).name));
        this_image = imcrop(this_image,crop_position);
        
        output_file = fullfile(output_folder,search_folders{i},file_hits(j).name);
        
        imwrite2tif(this_image,[],output_file,'single');
    end
end