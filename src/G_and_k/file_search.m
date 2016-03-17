function filecell = file_search(exp,folder,varargin)
% file_search Search for files in a given folder using a regular expression
%             to filter the results
%
%   Required Parameters: 
%     -exp - the experssion used as a filter, use '.*' to find all files
%     -folder - where to search for files
%
%   Optional: 
%     -return_complete_files - True/False for returning the complete
%                              path to the file
%
%   Example:
%    - file_search('.*','my_data_directory');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter Parsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_p = inputParser;

i_p.addParameter('return_complete_files',0,@(x)x==1 || x==0);

i_p.parse(varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

listing = dir(folder);

%the first two entries from dir are always, '.' and '..', they are
%references to the current directory and one up, remove them from the
%search
listing(1:2)=[];

isfolder = {listing.isdir};
files = {listing.name};
for m = 1:length(isfolder)
    if isfolder{m} == 1
        sublist = dir(fullfile(folder,listing(m).name));
        sublist(1:2) = [];
        subfiles = {sublist.name};
        files = [files subfiles];
    end
end

match = regexp(files,exp);
indi = [];
for i = 1:length(match)
    if match{i}==1
        indi = [indi i];
    end
end
filecell = files(indi);

if (i_p.Results.return_complete_files)
    for i = 1:length(filecell)
        filecell(i) = fullfile(folder,filecell(i));
    end
end