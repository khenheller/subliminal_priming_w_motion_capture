clc;
clear all;
addpath(genpath('./imported_code'));
% -----------------------------------
% Counts trials with correct ans and trails with good RT in each day.
% Used to asses whether a participant should be invited ot the second day of the experiment.
% -----------------------------------
SUBS = [26 27 28 29 30 31 32 33 34 35 36 37 38 41 42];
load('../../experiment/RUN_ME/code/p.mat');
p = defineParams(p, SUBS, 'day1', SUBS(1));
nTrials = [240 480]; % num trials on day 1 and 2 accordingly.

good_timing = NaN(p.MAX_SUB, 2);
good_timing_per = NaN(p.MAX_SUB, 2);
correct = NaN(p.MAX_SUB, 2);
correct_per = NaN(p.MAX_SUB, 2);
not_at_chance = NaN(p.MAX_SUB, 2);

disp('Num of trials with good timing:');
for iSub = SUBS
    has_day2 = isfile([p.DATA_FOLDER '/sub' num2str(iSub) 'day2_data.csv']);
    for day = 1 : 1 + has_day2 % If has both days, checks timing for both.
        data = readtable([p.DATA_FOLDER '/sub' num2str(iSub) 'day' num2str(day) '_data.csv']);
        % Remove practice trials.
        data(data.practice > 0, :) = [];
        % Counts bad timing trials.
        good_timing_trials = ~(data.late_res | data.slow_mvmnt | data.early_res);
        good_timing(iSub,day) = sum(good_timing_trials);
        good_timing_per(iSub,day) = round(good_timing(iSub,day) ./ nTrials(day) * 100, 1); % percent.
        % Counts correct ans.
        correct(iSub,day) = sum(data.target_correct & good_timing_trials);
        correct_per(iSub,day) = round(correct(iSub,day) ./ good_timing(iSub,day) * 100, 1); % percent.
        % Checks if sub is guesssing in categor.
        not_at_chance(iSub,day) = myBinomTest(correct(iSub,day), good_timing(iSub,day), 0.5, 'Two') <= p.SIG_PVAL;
    end
    disp(['Sub' num2str(iSub) ': day1 ' num2str(good_timing(iSub,1)) '    day2 ' num2str(good_timing(iSub,2)) ',    in percent:    day1 ' num2str(good_timing_per(iSub,1)) '%    day2 ' num2str(good_timing_per(iSub,2)) '%']);
end
avg = nanmean(good_timing, 1);
stdev = nanstd(good_timing, 1);
avg_per = nanmean(good_timing_per, 1);
stdev_per = nanstd(good_timing_per, 1);
disp(['Across Subs, Mean:    day1 ' num2str(avg(1)) '   day2 ' num2str(avg(2)) ',   std: ' num2str(stdev)]);
disp(['Across Subs, Mean percent:    day1 ' num2str(avg_per(1)) '%   day2 ' num2str(avg_per(2)) '%,   std: ' num2str(stdev_per)]);
disp('Done checking timing\n');


disp('Num of trials with correct target classification:');
const_space = 7; % Between results in same line.
for iSub = SUBS
    disp(['Sub' num2str(iSub) ':'...
        'day1 ' pad(num2str(correct(iSub,1)), const_space, 'right')...
        'day2 ' pad(num2str(correct(iSub,2)), const_space, 'right')...
        'Isnt guessing on day1: ' pad(num2str(not_at_chance(iSub,1)), const_space, 'right')...
        'day2: ' pad(num2str(not_at_chance(iSub,2)), const_space, 'right')...
        'in percent: day1 ' pad([num2str(correct_per(iSub,1)) '%'], const_space, 'right')...
        'day2 ' pad([num2str(correct_per(iSub,2)) '%'], const_space, 'right')]);
end
avg = nanmean(correct, 1);
stdev = nanstd(correct, 1);
avg_per = nanmean(correct_per, 1);
stdev_per = nanstd(correct_per, 1);
disp(['Across Subs, Mean:    day1 ' num2str(avg(1)) '   day2 ' num2str(avg(2)) ',   std: ' num2str(stdev)]);
disp(['Across Subs, Mean percent:    day1 ' num2str(avg_per(1)) '%   day2 ' num2str(avg_per(2)) '%,   std: ' num2str(stdev_per)]);
disp('Done checking correctness');