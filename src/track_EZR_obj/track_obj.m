function [tracking_mat,output_vis] = track_obj(image_file_1,image_file_2,varargin)

start_time = tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_p = inputParser;
i_p.FunctionName = 'TRACK_OBJ';

i_p.addRequired('image_file_1',@(x)exist(image_file_1,'file') == 2);
i_p.addRequired('image_file_2',@(x)exist(image_file_2,'file') == 2);

i_p.parse(image_file_1,image_file_2,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Reading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

objects = cell(0);
tracking_props = cell(0);

image_reading_start = tic;
objects{1} = imread(image_file_1);
objects{2} = imread(image_file_2);

for i_num=1:length(objects)
    for ad_num = 1:max(objects{i_num}(:))
        tracking_props{i_num}(ad_num).assigned = 0;
        tracking_props{i_num}(ad_num).next_obj = [];
    end
end
fprintf('Reading images took ~%d minutes.\n', round(toc(image_reading_start)/60));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object Assocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assign_start = tic;
for i_num=1:(length(objects) - 1)
    pix_sim = calc_pix_sim(objects{i_num},objects{i_num+1});
    cent_dist = calc_cent_dist(objects{i_num},objects{i_num+1});
        
    %Start by searching for reciprical high pixel similarity matches,
    %defined as those objects that overlap a single object in the next frame by
    %50% or more
    [start_obj_hits, end_obj_hits] = find(pix_sim > 0.5);    
    for i = 1:length(start_obj_hits)
        start_obj = start_obj_hits(i);
        end_obj = end_obj_hits(i);
        
        %check to make sure these two objects are unique in their lists, if
        %so, make the connection and block the row (start_obj) and column
        %(end_obj)
        if (sum(start_obj == start_obj_hits) == 1 && ...
            sum(end_obj == end_obj_hits) == 1)
            
            tracking_props{i_num}(start_obj).next_obj = end_obj;
            
            pix_sim(start_obj,:) = NaN;
            pix_sim(:,end_obj) = NaN;

            cent_dist(start_obj,:) = NaN;
            cent_dist(:,end_obj) = NaN;
        end
    end
    
    %This loop finds any remaining pixel similarity measures above 20% and
    %matches them, one-by-one to their corresponding end objects. This code
    %mostly helps clear out the objects that overlap two objects with fairly
    %high similarity, but not one single object completely.
    while (any(any(pix_sim > 0.2)))
        [start_obj,end_obj] = find(pix_sim == max(pix_sim(:)),1,'first');
        
        tracking_props{i_num}(start_obj).next_obj = end_obj;
        
        pix_sim(start_obj,:) = NaN;
        pix_sim(:,end_obj) = NaN;

        cent_dist(start_obj,:) = NaN;
        cent_dist(:,end_obj) = NaN;
    end

    %This section of the code would use the distance between the centroids
    %to fill out the rest of the tracking list, but it isn't needed for the
    %puncta tracking
    
    if (mod(i_num,10)==0)
        runtime_now = toc(assign_start);
        estimated_remaining = round(((runtime_now/i_num)*(length(objects) - 1 - i_num))/60);
        fprintf('Done with image %d, estimating %d minutes left.\n',i_num,estimated_remaining);
    end
end

tracking_build_start = tic;
tracking_mat = convert_tracking_props_to_matrix(tracking_props);

tracking_build_time = round(toc(tracking_build_start)/60);
fprintf('Tracking matrix building took %d minutes.\n',tracking_build_time);

toc(start_time);

matched_rows = tracking_mat > 0;
matched_rows = matched_rows(:,1) .* matched_rows(:,2);
matched_sets = tracking_mat(logical(matched_rows),:);

objects_1_match = label2rgb(ismember(objects{1},matched_sets(:,1)));
objects_2_match = label2rgb(ismember(objects{2},matched_sets(:,2)));

output_vis = imfuse(objects_1_match,objects_2_match);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Similarity Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pix_sim = calc_pix_sim(ads_1,ads_2)
    pix_sim = zeros(max(ads_1(:)), max(ads_2(:)));
    
    for start_ad=1:max(ads_1(:))
        this_ad = ads_1 == start_ad;
        
        ad_size = sum(sum(this_ad));
        
        overlap_pix = ads_2(this_ad);
        
        overlap_pix = overlap_pix(overlap_pix ~= 0);
        if (isempty(overlap_pix))
            continue;
        end
        
        unique_overlap = unique(overlap_pix);
        
        for end_ad = unique_overlap'
            pix_sim(start_ad,end_ad) = sum(overlap_pix == end_ad)/ad_size;
        end
    end
end

function cent_dist = calc_cent_dist(ads_1,ads_2)
    props_1 = regionprops(ads_1,'Centroid');
    props_2 = regionprops(ads_2,'Centroid');
    
    centroid_1 = reshape([props_1.Centroid],2,[])';
    centroid_2 = reshape([props_2.Centroid],2,[])';
    cent_dist = pdist2(centroid_1,centroid_2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tracking Matrix Production
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tracking_matrix = convert_tracking_props_to_matrix(tracking_props)

objects = struct('start',{},'sequence',{});
tracking_num = 1;

[i_num,obj_num] = find_unassigned_obj(tracking_props);

while (i_num ~= 0 && obj_num ~= 0)
    if (length(objects) < tracking_num)
        objects(tracking_num).start = i_num;
    end
    
    objects(tracking_num).sequence = [objects(tracking_num).sequence, obj_num];
    tracking_props{i_num}(obj_num).assigned = 1;
    
    %pick out the next object to follow
    [i_num, obj_num] = follow_to_next_obj(tracking_props,i_num,obj_num);
    
    if (i_num == 0)
        [i_num, obj_num] = find_unassigned_obj(tracking_props);
        tracking_num = tracking_num + 1;
        if (mod(tracking_num,1000) == 0)
            fprintf('Done with building tracking for %d objects.\n', tracking_num);
        end
    end
end

tracking_matrix = zeros(length(objects),length(tracking_props));

for obj_num = 1:length(objects)
    col_range = objects(obj_num).start:(objects(obj_num).start + length(objects(obj_num).sequence) - 1);
    tracking_matrix(obj_num,col_range) = objects(obj_num).sequence;
end

for col_num = 1:size(tracking_matrix,2)
    this_col = tracking_matrix(:,col_num);
    this_col = this_col(this_col ~= 0);
    
    this_col = sort(unique(this_col))';
    
    %empty columns mean there weren't any objects in that time step, so
    %check for that in the following assert first, then if there were
    %objects, make sure all were accounted for
    assert(isempty(this_col) || all(this_col == 1:max(this_col)))
    
    assert((isempty(tracking_props{col_num}) && isempty(this_col)) || ...
        (length(tracking_props{col_num}) == max(this_col)));
end

end

function [i_num,obj_num] = find_unassigned_obj(tracking_props)

%scan through the tracking props data to find an entry where the assigned
%value is false, then immediatly return, taking the current value of i_num
%and obj_num with the return
for i_num=1:length(tracking_props)
    for obj_num=1:max(size(tracking_props{i_num}))
        try
            if (tracking_props{i_num}(obj_num).assigned)
                continue;
            else
                return;
            end
        catch
            continue;
        end
    end
    tracking_props{i_num} = [];
end

%we won't get to this part of the code unless there aren't unassigned
%objects left, in that case return the exit signal
i_num = 0;
obj_num = 0;

return;

end

function [i_num,obj_num] = follow_to_next_obj(tracking_props,i_num,obj_num)

try %#ok<*TRYNC>
    if (size(tracking_props{i_num}(obj_num).next_obj,2) == 0)
        i_num = 0;
        obj_num = 0;
        return;
    else
        obj_num = tracking_props{i_num}(obj_num).next_obj;
        i_num = i_num + 1;
        return;
    end
end

i_num = 0;
obj_num = 0;

return;

end
