function acc_means = get_Acceptor_means(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);
i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acceptor_file_set = dir(fullfile(exp_folder,'Acceptor'));
acceptor_file_set = acceptor_file_set(3:end);

acc_means = [];
if(isempty(acceptor_file_set))
   fprintf('Cant Find any Files to analyze: %s',exp_folder);
   return;
end

fprintf('Reading in %d images.\n', length(acceptor_file_set));


for i=1:length(acceptor_file_set);
    acceptor_image = imread(fullfile(exp_folder,'Acceptor',acceptor_file_set(i).name));
    acc_pix = acceptor_image(:);
    acc_pix = acc_pix(acc_pix > 1000);
    acc_means = [acc_means, mean(acc_pix)];
end