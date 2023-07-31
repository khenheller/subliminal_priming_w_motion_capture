% For exp 3,
% Compares the RT of all subs between the first block 
% on the first day and the first block on the second day.
function [] = compareRTFirstSecondDay(traj_names, plt_p, p)
    avg_rt.day1 = nan(p.MAX_SUB, 1);
    avg_rt.day2 = nan(p.MAX_SUB, 1);

    % Take subs that were valid according to 2nd day.
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_day2_' traj_names{1}{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;

    for day = ["day1", "day2"]
        bad_trials = load(strcat(p.PROC_DATA_FOLDER, '/bad_trials_', day, '_', traj_names{1}{1}, '_subs_', p.SUBS_STRING, '.mat'));  bad_trials = bad_trials.reach_bad_trials;
        % Get data of each sub.
        for iSub = good_subs
            data_table = load(strcat(p.PROC_DATA_FOLDER, '/sub', num2str(iSub), day, '_reach_data.mat'));  data_table = data_table.reach_data_table;
            rt = data_table.target_rt(1 : end);
            % Remove trials in which RT isn't reliable.
            not_reliable = bad_trials{iSub}.late_res > 0;
            rt(not_reliable(1 : end)) = [];
            % Average rt for sub.
            avg_rt.(day)(iSub) = mean(rt, 'omitnan');
        end

        % Remove empty slots and convert to ms.
        avg_rt.(day) = avg_rt.(day)(good_subs) * 1000;
    end

    % Load data and prep params.
    beesdata = {avg_rt.day1,  avg_rt.day2};
    yLabel = 'Time (ms)';
    XTickLabel = ["Day1", "Day2"];
    colors = {plt_p.second_practice_color, plt_p.second_practice_color};
    title_char = 'Response time';
    % Plot.
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, plt_p.errbar_type, plt_p.alpha_size);
    
    % Connect each sub's dots with lines.
    y_data = [avg_rt.day1'; avg_rt.day2'];
    x_data = reshape(get(gca,'XTick'), 2,[]);
    x_data = repelem(x_data,1,length(good_subs));
    connect_dots(x_data, y_data);
    
    h = gca;
    h.XAxis.TickLength = [0 0];
    h.TickDir = 'out';
    % Legend.
%     h = [];
%     h(1) = bar(NaN,NaN,'FaceColor',plt_p.first_practice_color);
%     h(2) = bar(NaN,NaN,'FaceColor',plt_p.second_practice_color);
%     legend(h,'First day','Second day', 'Location','northwest');
    
    % T-test and Cohen's dz
    [~, p_val, ci, stats] = ttest(avg_rt.day1, avg_rt.day2);
    
    % Print stats to terminal.
    disp('------------First vs Second day RT------------');
    printStats('Response time', avg_rt.day1, avg_rt.day2, ["day1","day2"]p_val, ci, stats);
end