function run_processing_on_all(folder,varargin)
% run_processing_on_folders - run processing steps on all subfolders in a
% given folder
%
% Parameters:
%   folder - the folder you want to search for subfolders to process

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('folder',@(x)exist(x,'dir') == 7);

i_p.parse(folder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sub_folders = dir(folder);
%toss the first two, always '.' and '..'
sub_folders = sub_folders(3:end);

for i = 1:length(sub_folders)
    if (sub_folders(i).isdir)
        fprintf('Working on %s (%d of %d).\n',sub_folders(i).name,i,length(sub_folders));
        try
            segment_cell_edges(fullfile(folder,sub_folders(i).name),varargin{:});
            process_cell_edges(fullfile(folder,sub_folders(i).name),varargin{:});
            build_visualizations(fullfile(folder,sub_folders(i).name),varargin{:});
        catch
            disp(['Error on: ', fullfile(folder,sub_folders(i).name)]);
        end
    end
end

system('notify-send ''Done with Processing''')

end
