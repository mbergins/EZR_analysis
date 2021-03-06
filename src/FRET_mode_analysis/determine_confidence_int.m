function results = determine_confidence_int(data_mat)

results = struct('mean',mean(data_mat));
means = mean(data_mat);
all_ci = [];

for i=1:size(data_mat,2)
    [~,~,ci,~]  = ttest(data_mat(:,i));
    all_ci = [all_ci,ci];
end
all_ci(1,:) = mean(data_mat) - all_ci(1,:);
all_ci(2,:) = all_ci(2,:) - mean(data_mat);

results.upper = all_ci(1,:);
results.lower = all_ci(2,:);