function hist_mode = find_hist_mode(intensity_vals,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;

i_p.addRequired('intensity_vals',@(x)isnumeric(x));

i_p.addParameter('limits',[-Inf,Inf],@(x)isnumeric(x) & x(1) < x(2));
i_p.addParameter('min_intensity_vals',10000,@(x)isnumeric(x) & x > 0);
i_p.addParameter('bin_count',256,@(x)isnumeric(x) & x > 0);

i_p.addParameter('debug',0,@(x)x==1 || x==0);

i_p.parse(intensity_vals,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intensity_vals = intensity_vals(~isnan(intensity_vals));
intensity_vals = intensity_vals(intensity_vals >= i_p.Results.limits(1) & ...
    intensity_vals <= i_p.Results.limits(2));


if (length(intensity_vals) < i_p.Results.min_intensity_vals)
    hist_mode = NaN;
else
    [counts,mids] = hist(intensity_vals,i_p.Results.bin_count);
    hist_mode = mids(find(max(counts)==counts,1));
end

end
