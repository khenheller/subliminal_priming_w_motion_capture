clc;
clear all;
% -----------------------------------
% Amount of good timing trials on each day.
% -----------------------------------
SUBS = [26 27 28 29 30 31 32 33 34 35 36 37 38];
load('../../experiment/RUN_ME/code/p.mat');
p = defineParams(p, SUBS, 'day1', SUBS(1));
nTrials = [240 480]; % num trials on day 1 and 2 accordingly.

good_timing = NaN(p.MAX_SUB, 2);
good_timing_per = NaN(p.MAX_SUB, 2);
disp('Num of trials with good timing:');
for iSub = SUBS
    has_day2 = isfile([p.DATA_FOLDER '/sub' num2str(iSub) 'day2_data.csv']);
    for day = 1 : 1 + has_day2 % If has both days, checks timing for both.
        data = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'day' num2str(day) '_data.csv']);
        % Counts bad timing trials.
        late_trials = sum(data.late_res);
        slow_trials = sum(data.slow_mvmnt);
        early_trials = sum(data.early_res);
        bad_timing = late_trials + slow_trials + early_trials;
        good_timing(iSub,day) = nTrials(day) - bad_timing;
        good_timing_per(iSub,day) = round(good_timing(iSub,day) ./ nTrials(day) * 100, 1); % percent.
    end
    disp(['Sub' num2str(iSub) ': day1 ' num2str(good_timing(iSub,1)) '    day2 ' num2str(good_timing(iSub,2)) ',    in percent:    day1 ' num2str(good_timing_per(iSub,1)) '%    day2 ' num2str(good_timing_per(iSub,2)) '%']);
end
avg = nanmean(good_timing, 1);
stdev = nanstd(good_timing, 1);
avg_per = nanmean(good_timing_per, 1);
stdev_per = nanstd(good_timing_per, 1);
disp(['Across Subs, Mean:    day1 ' num2str(avg(1)) '   day2 ' num2str(avg(2)) ',   std: ' num2str(stdev)]);
disp(['Across Subs, Mean percent:    day1 ' num2str(avg_per(1)) '%   day2 ' num2str(avg_per(2)) '%,   std: ' num2str(stdev_per)]);
disp('Done checking timing');