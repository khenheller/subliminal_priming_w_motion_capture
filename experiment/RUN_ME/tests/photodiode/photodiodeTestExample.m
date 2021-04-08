% In this exmaple the experiment's output file is called 'sub123123data.csv'.
% The most important output is "Big deviations between Matlab and Diode:", if these deviations don't exist
% it means Matlab measures the timing accuratly.
test_path = './test1';
events = {'fix_time', 'mask1_time', 'mask2_time', 'prime_time', 'mask3_time', 'target_time', 'categor_time'};
desired_durations = [1, 0.27, 0.03, 0.03, 0.03, 0.5, 1];
photodiodeTest(test_path, events, desired_durations);