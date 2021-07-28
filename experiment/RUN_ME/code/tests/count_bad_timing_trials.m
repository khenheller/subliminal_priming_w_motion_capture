clc;
clear all;
for j = 1:14
    test_res = load(['./test_results/sub' num2str(j) '.mat']);  test_res = test_res.test_res.dev_table;
    sub{j} = test_res;
    disp(['Sub ' num2str(j) ': ' num2str(height(test_res)) ' trials']);
end
