function hist_modes = get_FRET_modes_dual(exp_folder,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('exp_folder',@(x)exist(x,'dir') == 7);

i_p.addParameter('search_folder','FRET',@ischar);
i_p.addParameter('search_quantile',0,@isnumeric);

i_p.addParameter('save_figs',0,@(x)x==1 || x==0);
i_p.addParameter('write_masked_images',0,@(x)x==1 || x==0);
i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(exp_folder,varargin{:});

search_folder = i_p.Results.search_folder;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FRET_file_set = dir(fullfile(exp_folder,search_folder));
FRET_file_set = FRET_file_set(3:end);

if(isempty(FRET_file_set))
   fprintf('Cant Find any Files to analyze: %s',exp_folder);
   hist_modes = [];
   return;
end

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
    
    filter = ones(length(acceptor_linear),1);
    if (i_p.Results.search_quantile)
        above_zero = FRET_image_linear(FRET_image_linear > 0);
        filter = FRET_image_linear < quantile(above_zero,0.95);
    else
%         filter = FRET_image_linear >= 0.001 & FRET_image_linear <= 1;
    end
    
    filter = filter & acceptor_linear > 100 & acceptor_linear < 20000E10;
    filter = filter & donor_linear > 100 & donor_linear < 20000E10;
    filter = filter & dpa_linear >= 0.75 & dpa_linear <= 2;
    
    passed_FRET_pix = FRET_image_linear(filter);
    passed_Acc_pix = acceptor_linear(filter);
    passed_Donor_pix = donor_linear(filter);
    
    if (length(passed_FRET_pix) < 10000)
        hist_modes = [hist_modes,NaN];  %#ok<AGROW>
    else
        [counts,mids] = hist(passed_FRET_pix,256);
        hist_modes = [hist_modes,mids(find(max(counts)==counts,1))];  %#ok<AGROW>
    end
    
    if(i_p.Results.save_figs)
        output_folder = fullfile(exp_folder,sprintf('%s-Hists',i_p.Results.search_folder));
        mkdir_no_err(output_folder);
        hist(passed_FRET_pix,256);
        title(sprintf('Mode - %0.4f/5th - %0.2f/95th - %0.2f/Mean - %0.4f',hist_modes(end),...
            quantile(passed_FRET_pix,0.05),quantile(passed_FRET_pix,0.95),...
            mean(passed_FRET_pix)));
        y_limits = ylim;
        line([0.28,0.28],[y_limits(1),y_limits(2)]);
        xlim([0,1]);
        saveas(gcf,fullfile(output_folder,sprintf('%02d.png',i)));
        
        plot(passed_Acc_pix,passed_Donor_pix,'.');
        xlabel('Acceptor Pixels'); ylabel('Donor Pixels');
        lin_fit = polyfit(passed_Acc_pix,passed_Donor_pix,1);
        title(sprintf('Slope - %0.2f/Intercept - %0.2f',lin_fit(1),lin_fit(2)));
        saveas(gcf,fullfile(output_folder,sprintf('pixel_%02d.png',i)));
    end
    
    if (i_p.Results.write_masked_images)
        image_mask = reshape(filter,size(acceptor_image));
        
        acc_masked = acceptor_image .* image_mask;
        donor_masked = donor_image .* image_mask;
        eff_masked = FRET_image .* image_mask;
        
        mkdir_no_err(fullfile(exp_folder,'hist_masked','Acceptor'))
        mkdir_no_err(fullfile(exp_folder,'hist_masked','Donor'))
        mkdir_no_err(fullfile(exp_folder,'hist_masked','Eff'))
        
        imwrite2tif(acc_masked,[],...
            fullfile(exp_folder,'hist_masked','Acceptor',acceptor_file_set(i).name),...
            'single');
        imwrite2tif(donor_masked,[],...
            fullfile(exp_folder,'hist_masked','Donor',donor_file_set(i).name),...
            'single');
        imwrite2tif(eff_masked,[],...
            fullfile(exp_folder,'hist_masked','Eff',FRET_file_set(i).name),...
            'single');
        
        image_mask_perim = bwperim(image_mask);
        acc_high = create_highlighted_image(normalize_image(acc_masked),...
            image_mask,'mix_percent',0.25);
        
        mkdir_no_err(fullfile(exp_folder,'hist_high','Acceptor'))
%         mkdir_no_err(fullfile(exp_folder,'hist_masked','Donor'))
%         mkdir_no_err(fullfile(exp_folder,'hist_masked','Eff'))
        
        imwrite(acc_high, ...
            fullfile(exp_folder,'hist_high','Acceptor',[acceptor_file_set(i).name,'.png']));
%         imwrite2tif(donor_masked,[],...
%             fullfile(exp_folder,'hist_masked','Donor',donor_file_set(i).name),...
%             'single');
%         imwrite2tif(eff_masked,[],...
%             fullfile(exp_folder,'hist_masked','Eff',FRET_file_set(i).name),...
%             'single');

    end

end