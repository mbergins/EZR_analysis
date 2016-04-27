function hist_modes = get_FRET_modes_dual(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('search_folder','FRET',@ischar);
i_p.addParameter('search_quantile',0,@isnumeric);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

search_folder = i_p.Results.search_folder;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FRET_file_set = dir(fullfile(exp_folder,search_folder));
FRET_file_set = FRET_file_set(3:end);

assert(not(isempty(FRET_file_set)),...
       sprintf('Cant Find any Files to analyze: %s',exp_folder));

acceptor_file_set = dir(fullfile(exp_folder,'Acceptor'));
acceptor_file_set = acceptor_file_set(3:end);
donor_file_set = dir(fullfile(exp_folder,'Donor'));
donor_file_set = donor_file_set(3:end);
dpa_file_set = dir(fullfile(exp_folder,'DPA'));
dpa_file_set = dpa_file_set(3:end);

fprintf('Reading in %d images.\n', length(FRET_file_set));

hist_modes = [];
for i=1:length(FRET_file_set);
    FRET_image = imread(fullfile(exp_folder,search_folder,FRET_file_set(i).name));
    FRET_image_linear = FRET_image(:);
    
    acceptor_image = imread(fullfile(exp_folder,'Acceptor',acceptor_file_set(i).name));
    donor_image = imread(fullfile(exp_folder,'Donor',donor_file_set(i).name));
    dpa_image = imread(fullfile(exp_folder,'DPA',dpa_file_set(i).name));
    
    acceptor_linear = acceptor_image(:);
    donor_linear = donor_image(:);
    dpa_linear = dpa_image(:);
    
    if (i_p.Results.search_quantile)
        above_zero = FRET_image_linear(FRET_image_linear > 0);
        filter = FRET_image_linear < quantile(above_zero,0.95);
    else
        filter = FRET_image_linear >= 0.001 & FRET_image_linear <= 1;
    end
    
    filter = filter & acceptor_linear > 1000 & acceptor_linear < 10000;
    filter = filter & donor_linear > 1000 & donor_linear < 10000;
%     filter = filter & dpa_linear >= 0.75 & dpa_linear <= 2;
    
    passed_FRET_pix = FRET_image_linear(filter);
    passed_Acc_pix = acceptor_linear(filter);
    
    if (length(passed_FRET_pix) < 10000)
        hist_modes = [hist_modes,NaN];  %#ok<AGROW>
    else
        [counts,mids] = hist(passed_FRET_pix,256);
        hist_modes = [hist_modes,mids(find(max(counts)==counts,1))];  %#ok<AGROW>
    end
end