clear all;
close all;
clc;

%% Parameters
load('../../experiment/RUN_ME/code/p.mat');
addpath(genpath('./imported_code'));

% Adjustable params.
SUBS = [26 28 29 31 32 33 34]; % to analyze.
DAY = 'day2';
pas_rate = 1; % to analyze.
picked_trajs = [1]; % traj to analyze (1=to_target, 2=from_target, 3=to_prime, 4=from_prime).
p = defineParams(p, SUBS, DAY, SUBS(1));

% Name of trajectory column in output data. each cell is a diff type of traj.
traj_names = {{'target_x_to' 'target_y_to' 'target_z_to'},...
    {'target_x_from' 'target_y_from' 'target_z_from'},...
    {'prime_x_to' 'prime_y_to' 'prime_z_to'},...
    {'prime_x_from' 'prime_y_from' 'prime_z_from'}};
traj_names = traj_names(picked_trajs);
% name of normalized traj column in output data.
traj_names_norm = [traj_names{:,:}];
traj_names_norm = reshape(traj_names_norm, [], length(traj_names));
traj_names_norm = strcat(traj_names_norm, '_norm');
traj_names_norm = traj_names_norm';
% Traj names without 'x'/'y'/'z'.
traj_types = [traj_names{:,:}];
traj_types = reshape(traj_types, [], length(traj_names));
traj_types = traj_types(1,:);
traj_types = replace(traj_types, '_x', '');
%% Add fields
% Adds late_res and slow_mvmnt fields to sub 1-14.
for iSub = p.SUBS
    % Checks if the fields were already added.
    data_file = fopen([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data.csv']);
    fields = textscan(data_file,'%s',1); % gets only fields
    fields = fields{:}{:};
    fields = split(fields, ',');
    has_fields = any(contains(fields, 'late_res')) &...
        any(contains(fields, 'slow_mvmnt')) &...
        any(contains(fields, 'early_res'));
    fclose(data_file);
    % If fields don't exist, add them.
    if ~has_fields
        data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data.csv']);
        traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj.csv']);
        start_end_points = load([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'start_end_points.mat']);
        p.START_POINT = start_end_points.p.START_POINT;
        data_table = addFields(data_table, traj_table, p);
        writetable(data_table, [p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data.csv']);
    end
end
%% Preprocessing & Normalization
% Trials too short to filter.
too_short_to_filter = table('Size', [max(p.SUBS) length(traj_types)],...
    'VariableTypes', repmat({'cell'}, length(traj_types), 1),...
    'VariableNames', traj_types);
disp('Preprocessing done for subject:');
for iSub = p.SUBS
    p = defineParams(p, SUBS, DAY, iSub);
    traj_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj.csv']);
    data_table = readtable([p.DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data.csv']);
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj.mat'], 'traj_table'); % '.mat' is faster to read than '.csv'.
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data.mat'], 'data_table');
    
    % remove practice.
    traj_table(traj_table{:,'practice'} > 0, :) = [];
    data_table(data_table{:,'practice'} > 0, :) = [];
    
    % Preprocessing and normalization.
    for iTraj = 1:length(traj_names)
        [traj_table, data_table, too_short_to_filter{iSub, iTraj}{:}] = preproc(traj_table, data_table, traj_names{iTraj}, p);
    end
    % Trim to normalized length (=p.norm_frames).
    matrix = reshape(traj_table{:,:}, p.MAX_CAP_LENGTH, p.NUM_TRIALS, width(traj_table));
    matrix = matrix(1:p.NORM_FRAMES, :, :);
    traj_table = traj_table(1 : p.NORM_FRAMES * p.NUM_TRIALS, :);
    traj_table{:,:} = reshape(matrix, p.NORM_FRAMES * p.NUM_TRIALS, width(traj_table));
    % Save
    writetable(traj_table, [p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj_proc.csv']);
    writetable(data_table, [p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data_proc.csv']);
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'traj_proc.mat'], 'traj_table');
    save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'data_proc.mat'], 'data_table');
    disp(num2str(iSub));
end
disp('Following trials where too short to filter:');
disp(too_short_to_filter);
save([p.PROC_DATA_FOLDER '/too_short_to_filter_subs_' regexprep(num2str(p.SUBS), '\s+', '_') '.mat'], 'too_short_to_filter');
disp('Preprocessing done.');
%% Trial Screening
for iTraj = 1:length(traj_names)
    [bad_trials, n_bad_trials, bad_trials_i] = trialScreen(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/bad_trials_' traj_names{iTraj}{1} '.mat'], 'bad_trials', 'n_bad_trials', 'bad_trials_i');
end
disp('Trial screening done.');
%% Subject screening
for iTraj = 1:length(traj_names')
    bad_subs = subScreening(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/bad_subs_' traj_names{iTraj}{1} '.mat'], 'bad_subs');
end
disp('Sub screening done.');
%% Maximum absolute deviation
for iTraj = 1:length(traj_names)
    for iSub = p.SUBS
        traj_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_' 'traj_proc.mat']);  traj_table = traj_table.traj_table;
        data_table = load([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_' 'data_proc.mat']);  data_table = data_table.data_table;
        data_table = calcMAD(traj_table, data_table, traj_names{iTraj}, p);
        save([p.PROC_DATA_FOLDER 'sub' num2str(iSub) p.DAY '_' 'data_proc.mat'], 'data_table');
    end
end
disp('MAD calc done.');
%% Sorting and averaging (within subject)
for iTraj = 1:length(traj_names)
    bad_trials = load([p.PROC_DATA_FOLDER '/bad_trials_' traj_names{iTraj}{1} '.mat'], 'bad_trials');  bad_trials = bad_trials.bad_trials;
    for iSub = p.SUBS
        [avg, single] = avgWithin(iSub, traj_names{iTraj}, bad_trials, pas_rate, p);
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat'], 'single');
        save([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat'], 'avg');
    end
end
disp('Sorting and avging within sub done.');
%% Reach Area
% Area between left and right traj for same/diff condition.
for iTraj = 1:length(traj_names)
    for iSub = p.SUBS
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        % Turn traj to 2D.
        same_left_2d  = [avg.traj.same_left(:,3)  avg.traj.same_left(:,1)];
        same_right_2d = [avg.traj.same_right(:,3) avg.traj.same_right(:,1)];
        diff_left_2d  = [avg.traj.diff_left(:,3)  avg.traj.diff_left(:,1)];
        diff_right_2d = [avg.traj.diff_right(:,3) avg.traj.diff_right(:,1)];
        % Area between left and right trajs.
        reach_area.same(iSub) = calcArea(same_left_2d, same_right_2d);
        reach_area.diff(iSub) = calcArea(diff_left_2d, diff_right_2d);
    end
    save([p.PROC_DATA_FOLDER strrep(traj_names{iTraj}{1}, '_x','') '_reach_area.mat'], 'reach_area');
end
disp('Reach area calc done.');
%% Sorting and averaging (between subjects)
for iTraj = 1:length(traj_names)
    subs_avg = avgBetween(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/subs_avg_' traj_names{iTraj}{1} '.mat'], 'subs_avg');
end
disp('Sorting and avging between sub done.');
%% FDA
for iTraj = 1:length(traj_names)
    [p_val, corr_p, ~, stats] = runFDA(traj_names{iTraj}, p);
    save([p.PROC_DATA_FOLDER '/fda_' traj_names{iTraj}{1} '.mat'], 'p_val','corr_p','stats');
end
disp('FDA calc done.');
%% Plotting params
close all;

avg_plot_width = 4;
alpha_size = 0.05; % For confidence interval.
space = 4; % between beeswarm graphs.
% Color of plots.
f_alpha = 0.2; % transperacy of shading.
same_col = [0 0.4470 0.7410];%[0 0.4470 0.7410 f_f_alpha];
same_avg_col = 'b';
diff_col = [0.6350 0.0780 0.1840];%[0.6350 0.0780 0.1840 f_f_alpha];
diff_avg_col = 'r';

% Unite all subs to one variable.
for iSub = p.SUBS
    for iTraj = 1:length(traj_names)
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        avg_each.traj(iTraj).same_left(:,iSub,:) = avg.traj.same_left;
        avg_each.traj(iTraj).same_right(:,iSub,:) = avg.traj.same_right;
        avg_each.traj(iTraj).diff_left(:,iSub,:) = avg.traj.diff_left;
        avg_each.traj(iTraj).diff_right(:,iSub,:) = avg.traj.diff_right;
        avg_each.rt(iTraj).same_left(iSub)  = avg.rt.same_left;
        avg_each.rt(iTraj).same_right(iSub) = avg.rt.same_right;
        avg_each.rt(iTraj).diff_left(iSub)  = avg.rt.diff_left;
        avg_each.rt(iTraj).diff_right(iSub) = avg.rt.diff_right;
        avg_each.react(iTraj).same_left(iSub)  = avg.react.same_left;
        avg_each.react(iTraj).same_right(iSub) = avg.react.same_right;
        avg_each.react(iTraj).diff_left(iSub)  = avg.react.diff_left;
        avg_each.react(iTraj).diff_right(iSub) = avg.react.diff_right;
        avg_each.mt(iTraj).same_left(iSub)  = avg.mt.same_left;
        avg_each.mt(iTraj).same_right(iSub) = avg.mt.same_right;
        avg_each.mt(iTraj).diff_left(iSub)  = avg.mt.diff_left;
        avg_each.mt(iTraj).diff_right(iSub) = avg.mt.diff_right;
        avg_each.mad(iTraj).same_left(iSub)  = avg.mad.same_left;
        avg_each.mad(iTraj).same_right(iSub) = avg.mad.same_right;
        avg_each.mad(iTraj).diff_left(iSub)  = avg.mad.diff_left;
        avg_each.mad(iTraj).diff_right(iSub) = avg.mad.diff_right;
        avg_each.x_std(iTraj).same_left(:,iSub)  = avg.x_std.same_left;
        avg_each.x_std(iTraj).same_right(:,iSub) = avg.x_std.same_right;
        avg_each.x_std(iTraj).diff_left(:,iSub)  = avg.x_std.diff_left;
        avg_each.x_std(iTraj).diff_right(:,iSub) = avg.x_std.diff_right;
        avg_each.cond_diff(iTraj).left(:,iSub,:)  = avg.cond_diff.left;
        avg_each.cond_diff(iTraj).right(:,iSub,:) = avg.cond_diff.right;
    end
    avg_each.fc.same(iSub) = avg.fc.same;
    avg_each.fc.diff(iSub) = avg.fc.diff;
end
%% Single Sub plots.
% Create figure for each sub.
for iSub = p.SUBS
    sub_f(iSub,1) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    sub_f(iSub,2) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    sub_f(iSub,3) = figure('Name',['Sub ' num2str(iSub)], 'WindowState','maximized', 'MenuBar','figure');
    % Add title.
    figure(sub_f(iSub,1)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
    figure(sub_f(iSub,2)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
    figure(sub_f(iSub,3)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String',['Sub ' num2str(iSub)], 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
end

% ------- Traj of each trial -------
for iSub = p.SUBS
%     figure('Name',['sub' num2str(iSub) ' traj'],'WindowState','maximized', 'MenuBar','figure');
    figure(sub_f(iSub,1));
    subplot(2,3,1);
    for iTraj = 1:length(traj_names)
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        % Flips traj to screen since its Z values are negative.
        flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
%         subplot(2,2,iTraj);
        hold on;
        % single trial.
        p1 = plot(single.trajs.same_left(:,:,1),  single.trajs.same_left(:,:,3)*flip_traj,  'Color',[same_col f_alpha]);
        p2 = plot(single.trajs.same_right(:,:,1), single.trajs.same_right(:,:,3)*flip_traj, 'Color',[same_col f_alpha]);
        p3 = plot(single.trajs.diff_left(:,:,1),  single.trajs.diff_left(:,:,3)*flip_traj,  'Color',[diff_col f_alpha]);
        p4 = plot(single.trajs.diff_right(:,:,1), single.trajs.diff_right(:,:,3)*flip_traj, 'Color',[diff_col f_alpha]);
        % Averages.
        plot(avg.traj.same_left(:,1),  avg.traj.same_left(:,3) * flip_traj,  same_avg_col, 'LineWidth',avg_plot_width);
        plot(avg.traj.same_right(:,1), avg.traj.same_right(:,3) * flip_traj, same_avg_col, 'LineWidth',avg_plot_width);
        plot(avg.traj.diff_left(:,1),  avg.traj.diff_left(:,3) * flip_traj,  diff_avg_col, 'LineWidth',avg_plot_width);
        plot(avg.traj.diff_right(:,1), avg.traj.diff_right(:,3) * flip_traj, diff_avg_col, 'LineWidth',avg_plot_width);
        % plot's description.
        h = [];
        h(1) = plot(nan,nan,'Color',same_col);
        h(2) = plot(nan,nan,'Color',diff_col);
        h(3) = plot(nan,nan,same_avg_col);
        h(4) = plot(nan,nan,diff_avg_col);
        legend(h, 'Same', 'Diff', 'Same avg', 'Diff avg', 'Location','southeast');
        xlabel('X'); xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)'); ylim([0, p.SCREEN_DIST]);
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        set(gca, 'FontSize',14);
    end
end

% ------- Avg traj with shade -------
for iSub = p.SUBS
%     figure('Name',['sub' num2str(iSub) p.DAY '_' ' traj'],'WindowState','maximized', 'MenuBar','figure');
    figure(sub_f(iSub,1));
    subplot(2,3,2);
    for iTraj = 1:length(traj_names)
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        % Flips traj to screen since its Z values are negative.
        flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
%         subplot(2,2,iTraj);
        hold on;
        % Avg with var shade.
        stdshade(single.trajs.same_left(:,:,1)',  f_alpha, same_col, avg.traj.same_left(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
        stdshade(single.trajs.same_right(:,:,1)', f_alpha, same_col, avg.traj.same_right(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
        stdshade(single.trajs.diff_left(:,:,1)',  f_alpha, diff_col, avg.traj.diff_left(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
        stdshade(single.trajs.diff_right(:,:,1)', f_alpha, diff_col, avg.traj.diff_right(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
        h = [];
        h(1) = plot(nan,nan,'Color',same_col);
        h(2) = plot(nan,nan,'Color',diff_col);
        legend(h, 'Same', 'Diff', 'Location','southeast');
        xlabel('X'); xlim([-0.12, 0.12]);
        ylabel('Z Axis (to screen)'); ylim([0, p.SCREEN_DIST]);
        title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
        set(gca, 'FontSize',14);
    end
end

% ------- React + Movement + Response Times -------
for iSub = p.SUBS
    figure(sub_f(iSub,1));
    subplot(2,1,2);
    for iTraj = 1:length(traj_names)
        hold on;
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        beesdata = {single.react.same_left,  single.react.diff_left,...
                    single.mt.same_left,     single.mt.diff_left,...
                    single.rt.same_left,     single.rt.diff_left,...
                    single.react.same_right, single.react.diff_right,...
                    single.mt.same_right,    single.mt.diff_right,...
                    single.rt.same_right,    single.rt.diff_right};
        yLabel = 'Time (Sec)';
        XTickLabel = [];
        colors = repmat({same_col, diff_col},1,6);
        title_char = cell2mat(['Time ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
        printBeeswarm(beesdata, yLabel, XTickLabel, colors, space, title_char, 'ci', alpha_size);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["",""]; ["React","MT","RT"]; ["Left","Right"]};
        dist = [0, 0.15, 0.4];
        font_size = [1, 15, 20];
        groupTick(ticks, labels, dist, font_size)
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',same_col);
        h(2) = bar(NaN,NaN,'FaceColor',diff_col);
        legend(h,'Same','Diff', 'Location','northwest');
    end
end

% ------- Reaction Time -------
% for iSub = p.SUBS
%     figure(sub_f(iSub));
%     subplot(2,1,2);
%     for iTraj = 1:length(traj_names)
%         hold on;
%         single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
%         beesdata = {single.react.same_left, single.react.diff_left, single.react.same_right, single.react.diff_right};
%         yLabel = 'Reaction Time (Sec)';
%         XTickLabels = {'Same left', 'Diff left', 'Same right', 'Diff right'};%cellstr(strrep(fieldnames(single.rt), '_',' '))'; % remove '_' from names.
%         colors = {same_col, diff_col, same_col, diff_col};
%         title_char = cell2mat(['Reaction Time ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
%         printBeeswarm(beesdata, yLabel, XTickLabels, colors, space, title_char, 'ci', alpha_size);
%     end
% end

% ------- Movement Time -------
% for iSub = p.SUBS
%     figure(sub_f(iSub));
%     subplot(2,1,2);
%     for iTraj = 1:length(traj_names)
%         hold on;
%         single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
%         beesdata = {single.mt.same_left, single.mt.diff_left, single.mt.same_right, single.mt.diff_right};
%         XTickLabels = {'Same left', 'Diff left', 'Same right', 'Diff right'};%cellstr(strrep(fieldnames(single.rt), '_',' '))'; % remove '_' from names.
%         yLabel = 'Movement Time (Sec)';
%         colors = {same_col, diff_col, same_col, diff_col};
%         title_char = cell2mat(['Movement Time ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
%         printBeeswarm(beesdata, yLabel, XTickLabels, colors, space, title_char, 'ci', alpha_size);
%     end
% end

% ------- RT -------
% for iSub = p.SUBS
%     figure(sub_f(iSub));
%     subplot(2,1,2);
%     for iTraj = 1:length(traj_names)
%         hold on;
%         single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
%         beesdata = {single.rt.same_left, single.rt.diff_left, single.rt.same_right, single.rt.diff_right};
%         XTickLabels = {'Same left', 'Diff left', 'Same right', 'Diff right'};%cellstr(strrep(fieldnames(single.rt), '_',' '))'; % remove '_' from names.
%         yLabel = 'RT (Sec)';
%         colors = {same_col, diff_col, same_col, diff_col};
%         title_char = cell2mat(['RT ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
%         printBeeswarm(beesdata, yLabel, XTickLabels, colors, space, title_char, 'ci', alpha_size);
%     end
% end

% ------- PAS -------
for iSub = p.SUBS
%     figure('Name',['sub' num2str(iSub) p.DAY '_' ' PAS']);
    figure(sub_f(iSub,1));
    subplot(2,6,5);
    avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
    bar(1:4, avg.pas.same * 100 / sum(avg.pas.same), 'FaceColor',same_col);
    hold on;
    bar(5:8, avg.pas.diff * 100 / sum(avg.pas.diff), 'FaceColor',diff_col);
    xticks(1:8);
    yticks(0:10:100);
    xticklabels({1:4 1:4});
    legend('Same','Diff');
    xlabel('PAS');
    ylabel('%', 'FontWeight','bold');
    ylim([0 100]);
    title(['PAS']);
    set(gca,'FontSize',14);
    ax = gca;
    ax.YGrid = 'on';
end

% ------- Forced Choice -------
for iSub = p.SUBS
%     figure('Name',['sub' num2str(iSub) p.DAY '_' ' Forced Choice']);
    figure(sub_f(iSub,1));
    subplot(2,6,6);
    avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
    single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
    fc_same = avg.fc.same * 100; % percentage.
    fc_diff = avg.fc.diff * 100;
    bar(1, fc_same, 'FaceColor',same_col);
    hold on;
    bar(2, fc_diff, 'FaceColor',diff_col);
    xticks(1:2);
    xticklabels({[num2str(round(fc_same,1)) '%'] [num2str(round(fc_diff,1)) '%']});
    yticks(0:10:100);
    plot([0 4], [50 50], '--k');
    legend('Same','Diff');
    xlabel('Same / Diff');
    ylabel('%Correct', 'FontWeight','bold');
    ylim([0 100]);
    title(['Forced Choice (PAS=1)']);
    set(gca,'FontSize',14);
    ax = gca;
    ax.YGrid = 'on';
    % Binomial test.
    n_same_trials = size(single.fc.same,1);
    n_diff_trials = size(single.fc.diff,1);
    binom_same = round(myBinomTest(sum(single.fc.same), n_same_trials, 0.5, 'Two'), 3);
    binom_diff = round(myBinomTest(sum(single.fc.diff), n_diff_trials, 0.5, 'Two'), 3);
    text(1, fc_same+5, ['p_{bin}=' num2str(binom_same)], 'HorizontalAlignment','center');
    text(2, fc_diff+5, ['p_{bin}=' num2str(binom_diff)], 'HorizontalAlignment','center');
end

% ------- MAD -------
% Maximum absolute deviation.
for iSub = p.SUBS
    figure(sub_f(iSub,2));
    subplot(1,2,1);
    for iTraj = 1:length(traj_names)
        hold on;
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        beesdata = {single.mad.same_left, single.mad.diff_left, single.mad.same_right, single.mad.diff_right};
        yLabel = 'MAD (meter)';
        XTickLabels = [];
        colors = {same_col, diff_col, same_col, diff_col};
        title_char = cell2mat(['Maximum Absolute Deviation ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
        printBeeswarm(beesdata, yLabel, XTickLabels, colors, space, title_char, 'ci', alpha_size);
        % Group graphs.
        ticks = get(gca,'XTick');
        labels = {["",""]; ["Left","Right"]};
        dist = [0, 0.01];
        font_size = [1, 15];
        groupTick(ticks, labels, dist, font_size)
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',same_col);
        h(2) = bar(NaN,NaN,'FaceColor',diff_col);
        legend(h,'Same','Diff', 'Location','northwest');
    end
end

% ------- MAD Point -------
% Maximally absolute deviating point.
for iSub = p.SUBS
    figure(sub_f(iSub,2));
    for iTraj = 1:length(traj_names)
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_names{iTraj}{1} '.mat']);  single = single.single;
        % Flips traj to screen since its Z values are negative.
        flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
        traj_same = {single.trajs.same_left, single.trajs.same_right};
        traj_diff = {single.trajs.diff_left, single.trajs.diff_right};
        mad_p_same = {single.mad_p.same_left, single.mad_p.same_right};
        mad_p_diff = {single.mad_p.diff_left, single.mad_p.diff_right};
        % 2 plots: left, right.
        for side = 1:2
            % draw traj of a trial.
            subplot(2,2,2*side); hold on;
            p1 = plot(traj_same{side}(:,:,1),  traj_same{side}(:,:,3)*flip_traj,  'Color',[same_col f_alpha]);
            p3 = plot(traj_diff{side}(:,:,1),  traj_diff{side}(:,:,3)*flip_traj,  'Color',[diff_col f_alpha]);
            xlabel('X'); xlim([-0.12, 0.12]);
            ylabel('Z Axis (to screen)'); ylim([0, p.SCREEN_DIST]);
            title('Maximally deviating point');
            set(gca, 'FontSize',14);
            % Draw MAD point.
            plot(mad_p_same{side}(:,1),  mad_p_same{side}(:,3)*flip_traj, 'o','color',same_col);
            plot(mad_p_diff{side}(:,1),  mad_p_diff{side}(:,3)*flip_traj, 'o','color',diff_col);
            % Draw target.
            target_pos = p.DIST_BETWEEN_TARGETS/2;
            plot([-target_pos target_pos], [p.SCREEN_DIST p.SCREEN_DIST], 'bo', 'LineWidth',6);
            h = [];
            h(1) = bar(NaN,NaN,'FaceColor',same_col);
            h(2) = bar(NaN,NaN,'FaceColor',diff_col);
            h(3) = plot(NaN,NaN,'ko');
            h(4) = plot(NaN,NaN,'bo','LineWidth',6);
            legend(h, 'Same', 'Diff', 'MAD','Target', 'Location','southeast');
            xlim([-0.11 0.11]);
        end
    end
end

% ------- X Deviation -------
for iSub = p.SUBS
    figure(sub_f(iSub,3));
    for iTraj = 1:length(traj_names)
        % Flips traj to screen since its Z values are negative.
        flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_names{iTraj}{1} '.mat']);  avg = avg.avg;
        % Left.
        subplot(4,2,6);
        hold on;
        plot(avg.traj.same_left(:,3)*flip_traj,  avg.x_std.same_left,  'color',same_col);
        plot(avg.traj.diff_left(:,3)*flip_traj,  avg.x_std.diff_left,  'color',diff_col);
        ylabel('X std');
        xlim([0 p.SCREEN_DIST]);
        set(gca,'FontSize',14);
        title('STD in X Axis, Left');
        h = [];
        h(1) = bar(NaN,NaN,'FaceColor',same_col);
        h(2) = bar(NaN,NaN,'FaceColor',diff_col);
        legend(h,'Same','Diff', 'Location','northwest');
        % Right
        subplot(4,2,8);
        hold on;
        plot(avg.traj.same_right(:,3)*flip_traj, avg.x_std.same_right, 'color',same_col);
        plot(avg.traj.diff_right(:,3)*flip_traj, avg.x_std.diff_right, 'color',diff_col);
        ylabel('X std');
        xlabel('Z (m)');
        xlim([0 p.SCREEN_DIST]);
        set(gca,'FontSize',14);
        title('STD in X Axis, Right');
    end
end
%% Multiple subs average plots.
% Create figures.
all_sub_f(1) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(2) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
all_sub_f(3) = figure('Name',['All Subs'], 'WindowState','maximized', 'MenuBar','figure');
% Add title.
figure(all_sub_f(1)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(2)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');
figure(all_sub_f(3)); annotation('textbox',[0.45 0.915 0.1 0.1], 'String','All Subs', 'FontSize',30, 'LineStyle','none', 'FitBoxToText','on');


% ------- Avg traj with shade -------
for iTraj = 1:length(traj_names)
%     traj_fda_f(iTraj) = figure('Name','avg_traj','WindowState','maximized', 'MenuBar','figure');
    figure(all_sub_f(2));
    subplot(2,2,2); % Avg traj and FDA in same figure.
    hold on;
    subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' traj_names{iTraj}{1} '.mat']);  subs_avg = subs_avg.subs_avg;
    % Flips traj to screen since its Z values are negative.
    flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
    % Avg with var shade.
    stdshade(avg_each.traj(iTraj).same_left(:,p.SUBS,1)',  f_alpha, same_col, subs_avg.traj.same_left(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
    stdshade(avg_each.traj(iTraj).same_right(:,p.SUBS,1)', f_alpha, same_col, subs_avg.traj.same_right(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
    stdshade(avg_each.traj(iTraj).diff_left(:,p.SUBS,1)',  f_alpha, diff_col, subs_avg.traj.diff_left(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
    stdshade(avg_each.traj(iTraj).diff_right(:,p.SUBS,1)', f_alpha, diff_col, subs_avg.traj.diff_right(:,3)*flip_traj, 0, 0, 'ci', alpha_size);
    h = [];
    h(1) = plot(nan,nan,'Color',same_col);
    h(2) = plot(nan,nan,'Color',diff_col);
    legend(h, 'Same', 'Diff', 'Location','southeast');
    xlabel('X'); xlim([-0.12, 0.12]);
    ylabel('Z Axis (to screen)'); ylim([0, p.SCREEN_DIST]);
    title(cell2mat(['Reach ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]));
    set(gca, 'FontSize',14);
    title('Avg trajectory');
end
% annotation('textbox',[0.4 0.9 0.1 0.1], 'String','Avg across Subs', 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on');

% ------- FDA -------
% fda_f = figure('Name','FDA','WindowState','maximized', 'MenuBar','figure');
f_alpha = 0.05;
for iTraj = 1:length(traj_names)
%     figure(traj_fda_f(iTraj));
    figure(all_sub_f(1));
    p_val = load([p.PROC_DATA_FOLDER '/fda_' traj_names{iTraj}{1} '.mat'], 'p_val');  p_val = p_val.p_val;
    subplot(2,3,6);
    hold on;
    plot(1/p.NORM_FRAMES : 1/p.NORM_FRAMES : 1, p_val.x(1,:), 'k', 'LineWidth',2); % 1=same/diff index in p_val.
    plot([0 1], [f_alpha f_alpha], 'r');
    xlabel('Percent of Z movement');
    ylabel('P value');
    set(gca,'FontSize',14);
    ylim([0 1]);
    xlim([0 1]);
    title('FDA - Significance of difference between\newlineconditions (trajSame_x,trajDiff_x)');
end
% annotation('textbox',[0 0.91 1 0.1], 'String','X deviation between same and diff', 'FontSize',40, 'LineStyle','none', 'FitBoxToText','on', 'HorizontalAlignment','center');

% ------- React + Movement + Response Times -------
f_alpha = 0.5;
figure(all_sub_f(3));
for iTraj = 1:length(traj_names)
    % Beeswarm.
    beesdata = {avg_each.react(iTraj).same_left(p.SUBS),      avg_each.react(iTraj).diff_left(p.SUBS),...
                    avg_each.mt(iTraj).same_left(p.SUBS),     avg_each.mt(iTraj).diff_left(p.SUBS),...
                    avg_each.rt(iTraj).same_left(p.SUBS),     avg_each.rt(iTraj).diff_left(p.SUBS),...
                    avg_each.react(iTraj).same_right(p.SUBS), avg_each.react(iTraj).diff_right(p.SUBS),...
                    avg_each.mt(iTraj).same_right(p.SUBS),    avg_each.mt(iTraj).diff_right(p.SUBS),...
                    avg_each.rt(iTraj).same_right(p.SUBS),    avg_each.rt(iTraj).diff_right(p.SUBS)};
    beesdata = cellfun(@times,beesdata,repmat({1000},size(beesdata)),'UniformOutput',false); % convert to ms.
    yLabel = 'Time (Sec)';
    XTickLabel = [];
    colors = repmat({same_col, diff_col},1,6);
    title_char = cell2mat(['Time ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
    subplot(2,1,2);
    hold on;
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, space, title_char, 'ci', alpha_size);
    % Group graphs.
    ticks = get(gca,'XTick');
    labels = {["",""]; ["React","MT","RT"]; ["Left","Right"]};
    dist = [0, 80, 160];
    font_size = [1, 15, 20];
    groupTick(ticks, labels, dist, font_size)
    % Connect each sub's dots with lines.
    left_data = [avg_each.react(iTraj).same_left(p.SUBS), avg_each.mt(iTraj).same_left(p.SUBS), avg_each.rt(iTraj).same_left(p.SUBS);
                 avg_each.react(iTraj).diff_left(p.SUBS), avg_each.mt(iTraj).diff_left(p.SUBS), avg_each.rt(iTraj).diff_left(p.SUBS)];
    right_data = [avg_each.react(iTraj).same_right(p.SUBS), avg_each.mt(iTraj).same_right(p.SUBS), avg_each.rt(iTraj).same_right(p.SUBS);
                 avg_each.react(iTraj).diff_right(p.SUBS), avg_each.mt(iTraj).diff_right(p.SUBS), avg_each.rt(iTraj).diff_right(p.SUBS)];
    y_data = [left_data right_data] * 1000; % turn to ms.
    x_data = reshape(get(gca,'XTick'), 2,[]);
    x_data = repelem(x_data,1,p.N_SUBS);
    plot(x_data, y_data, 'color',[0.1 0.1 0.1, f_alpha]);
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',same_col);
    h(2) = bar(NaN,NaN,'FaceColor',diff_col);
    legend(h,'Same','Diff', 'Location','northwest');
end

% ------- Forced choice -------
% fc_pas_f = figure('Name','Forced choice','Units','normalized','OuterPosition',[0.25 0.25 0.5 0.5]);
figure(all_sub_f(3));
subplot(2,2,1); % plot fc and pas together.
beesdata = {avg_each.fc.same(p.SUBS), avg_each.fc.diff(p.SUBS)};
[h, fc_p_val(1) , ci, stats] = ttest(avg_each.fc.same(p.SUBS), 0.5);
[h, fc_p_val(2) , ci, stats] = ttest(avg_each.fc.diff(p.SUBS), 0.5);
fc_p_val = round(fc_p_val, 2);
XTickLabel = {'Same', 'Diff'};
colors = {same_col, diff_col};
title_char = ['Forced response (PAS = ' num2str(pas_rate) ')'];
printBeeswarm(beesdata, [], XTickLabel, colors, space, title_char, 'ci', alpha_size);
plot([-20 20], [0.5 0.5], '--', 'color',[0.3 0.3 0.3 f_alpha], 'LineWidth',2); % Line at 50%.
text(get(gca, 'xTick'),[0.1 0.1], {['p = ' num2str(fc_p_val(1))], ['p = ' num2str(fc_p_val(2))]}, 'FontSize',14, 'HorizontalAlignment','center');
ylabel('% Correct', 'FontWeight','bold');
ylim([0 1]);

% ------- PAS -------
figure(all_sub_f(3));
hold on;
subplot(2,2,2); % plot fc and pas together.
subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' traj_names{iTraj}{1} '.mat']);  subs_avg = subs_avg.subs_avg;
bar(1:4, subs_avg.pas.same * 100 / sum(subs_avg.pas.same), 'FaceColor',same_col);
hold on;
bar(5:8, subs_avg.pas.diff * 100 / sum(subs_avg.pas.diff), 'FaceColor',diff_col);
xticks(1:8);
xticklabels({1:4 1:4});
xlabel('PAS');
ylabel('% Trials', 'FontWeight','bold');
ylim([0 100]);
title('PAS');
legend('Same','Diff');
set(gca,'FontSize',14);

% ------- MAD -------
% Maximum absolute deviation.
figure(all_sub_f(1));
subplot(1,3,1);
err_bar_type = 'se';
for iTraj = 1:length(traj_names)
    hold on;
    beesdata = {avg_each(iTraj).mad.same_left(p.SUBS), avg_each(iTraj).mad.diff_left(p.SUBS), avg_each(iTraj).mad.same_right(p.SUBS), avg_each(iTraj).mad.diff_right(p.SUBS)};
    yLabel = 'MAD (meter)';
    XTickLabels = [];
    colors = {same_col, diff_col, same_col, diff_col};
    title_char = cell2mat(['Maximum Absolute Deviation ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
    printBeeswarm(beesdata, yLabel, XTickLabels, colors, space, title_char, err_bar_type, alpha_size);
    % Group graphs.
    ticks = get(gca,'XTick');
    labels = {["",""]; ["Left","Right"]};
    dist = [0, 0.005];
    font_size = [1, 15];
    groupTick(ticks, labels, dist, font_size)
    % T-test
    [~, mad_p_val, ci, ~] = ttest(beesdata{1}, beesdata{2});
    text(mean(ticks(1:2)), (max([beesdata{1:2}])+0.005), ['p: ' num2str(mad_p_val)], 'HorizontalAlignment','center', 'FontSize',14);
    [~, mad_p_val, ci, ~] = ttest(beesdata{3}, beesdata{4});
    text(mean(ticks(3:4)), (max([beesdata{3:4}])+0.005), ['p: ' num2str(mad_p_val)], 'HorizontalAlignment','center', 'FontSize',14);
    % Connect each sub's dots with lines.
    y_data = [beesdata{1} beesdata{3}; beesdata{2} beesdata{4}];
    x_data = reshape(get(gca,'XTick'), 2,[]);
    x_data = repelem(x_data,1,p.N_SUBS);
    plot(x_data, y_data, 'color',[0.1 0.1 0.1, f_alpha]);
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',same_col);
    h(2) = bar(NaN,NaN,'FaceColor',diff_col);
    h(3) = plot(NaN,NaN,'k','LineWidth',14);
    legend(h,'Same','Diff',err_bar_type, 'Location','northwest');
end

% ------- Reach Area -------
% Area between avg left traj and avg right traj (in each condition).
figure(all_sub_f(2));
subplot(1,3,1);
err_bar_type = 'se';
for iTraj = 1:length(traj_names)
    hold on;
    reach_area = load([p.PROC_DATA_FOLDER strrep(traj_names{iTraj}{1}, '_x','') '_reach_area.mat']);  reach_area = reach_area.reach_area;
    beesdata = {reach_area.same(p.SUBS) reach_area.diff(p.SUBS)};
    yLabel = 'Reach area (cm^2)';
    XTickLabels = ["Same","Diff"];
    colors = {same_col, diff_col};
    title_char = cell2mat(['Reach Area ' regexp(traj_names{iTraj}{1},'_._(.+)','tokens','once') ' ' regexp(traj_names{iTraj}{1},'(.+)_.+_','tokens','once')]);
    printBeeswarm(beesdata, yLabel, XTickLabels, colors, space, title_char, err_bar_type, alpha_size);
    % T-test
    [~, mad_p_val, ci, ~] = ttest(beesdata{1}, beesdata{2});
    text(mean(ticks(1:2)), (max([beesdata{1:2}])+0.0015), ['p: ' num2str(mad_p_val)], 'HorizontalAlignment','center', 'FontSize',14);
    % Connect each sub's dots with lines.
    same_data = [avg_each.react(iTraj).same_left(p.SUBS), avg_each.mt(iTraj).same_left(p.SUBS), avg_each.rt(iTraj).same_left(p.SUBS);
                 avg_each.react(iTraj).diff_left(p.SUBS), avg_each.mt(iTraj).diff_left(p.SUBS), avg_each.rt(iTraj).diff_left(p.SUBS)];
    right_data = [avg_each.react(iTraj).same_right(p.SUBS), avg_each.mt(iTraj).same_right(p.SUBS), avg_each.rt(iTraj).same_right(p.SUBS);
                 avg_each.react(iTraj).diff_right(p.SUBS), avg_each.mt(iTraj).diff_right(p.SUBS), avg_each.rt(iTraj).diff_right(p.SUBS)];
    y_data = [reach_area.same(p.SUBS); reach_area.diff(p.SUBS)];
    x_data = reshape(get(gca,'XTick'), 2,[]);
    x_data = repelem(x_data,1,p.N_SUBS);
    plot(x_data, y_data, 'color',[0.1 0.1 0.1, f_alpha]);
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',same_col);
    h(2) = bar(NaN,NaN,'FaceColor',diff_col);
    h(3) = plot(NaN,NaN,'k','LineWidth',14);
    legend(h,'Same','Diff',err_bar_type, 'Location','northwest');
end

% ------- X STD -------
figure(all_sub_f(1));
for iTraj = 1:length(traj_names)
    % Flips traj to screen since its Z values are negative.
    flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
    subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' traj_names{iTraj}{1} '.mat']);  subs_avg = subs_avg.subs_avg;
    % Left.
    subplot(2,3,2);
    hold on;
    plot(subs_avg.traj.same_left(:,3)*flip_traj,  subs_avg.x_std.same_left, 'color',same_col);
    plot(subs_avg.traj.diff_left(:,3)*flip_traj,  subs_avg.x_std.diff_left, 'color',diff_col);
    ylabel('X STD');
    xlim([0 p.SCREEN_DIST]);
    set(gca,'FontSize',14);
    title('STD in X Axis, Left');
    h = [];
    h(1) = bar(NaN,NaN,'FaceColor',same_col);
    h(2) = bar(NaN,NaN,'FaceColor',diff_col);
    legend(h,'Same','Diff', 'Location','northwest');
    % Right
    subplot(2,3,3);
    hold on;
    plot(subs_avg.traj.same_right(:,3)*flip_traj, subs_avg.x_std.same_right, 'color',same_col);
    plot(subs_avg.traj.diff_right(:,3)*flip_traj, subs_avg.x_std.diff_right, 'color',diff_col);
    ylabel('X STD');
    xlabel('Z (m)');
    xlim([0 p.SCREEN_DIST]);
    set(gca,'FontSize',14);
    title('STD in X Axis, Right');
end

% ------- Condition Diff -------
% Difference between avg traj in each condition.
for iTraj = 1:length(traj_names)
    figure(all_sub_f(2));
    % Flips traj to screen since its Z values are negative.
    flip_traj = 1 + contains(traj_names{iTraj}{1}, '_to') * -2; % if contains: -1, else: 1.
    subs_avg = load([p.PROC_DATA_FOLDER '/subs_avg_' traj_names{iTraj}{1} '.mat']);  subs_avg = subs_avg.subs_avg;
    % Left.
    subplot(2,3,5);
    hold on;
    stdshade(avg_each.cond_diff.left(:,p.SUBS,1)', f_alpha, 'k', subs_avg.traj.same_left(:,3)*flip_traj, 0, 1,'ci', alpha_size);
    plot([0 p.SCREEN_DIST], [0 0], '--', 'LineWidth',3, 'color',[0.15 0.15 0.15 f_alpha]);
    xlabel('Z (m)');
    ylabel('X diff (m)');
    title('TrajSame_x - TrajDiff_x, Left');
    set(gca,'FontSize',14);
    legend(['CI, \alpha=' num2str(alpha_size)], 'same - diff');
    % Right
    subplot(2,3,6);
    hold on;
    stdshade(avg_each.cond_diff.right(:,p.SUBS,1)', f_alpha, 'k', subs_avg.traj.same_right(:,3)*flip_traj, 0, 1, 'ci', alpha_size);
    plot([0 p.SCREEN_DIST], [0 0], '--', 'LineWidth',3, 'color',[0.15 0.15 0.15 f_alpha]);
    xlabel('Z (m)');
    ylabel('X diff (m)');
    title('TrajSame_x - TrajDiff_x, Right');
    set(gca,'FontSize',14);
    legend(['CI, \alpha=' num2str(alpha_size)], 'same - diff');
end
%% GUI, compares proc to real traj.
% close all;
% warning('off','MATLAB:legend:IgnoringExtraEntries');
% miss_data(p, traj_names); clc;
%% Velocity
%{
        % calc velocity.-----------------------------------------------
        dx = traj_mat(2:end, :, :) - traj_mat(1:end-1, :, :); % distance between 2 samples.
        vel_per_axis = dx / p.SAMPLE_RATE_SEC;
        veloc = sqrt(sum(vel_per_axis.^2, 3));
        veloc = [veloc; veloc(end,:)];
        vel.same_left = veloc(:, same_trials.left);
        vel.same_right = veloc(:, same_trials.right);
        vel.diff_left = veloc(:, diff_trials.left);
        vel.diff_right = veloc(:, diff_trials.right);
        avg_vel.same_left = mean(vel.same_left, 2);
        avg_vel.same_right = mean(vel.same_right, 2);
        avg_vel.diff_left = mean(vel.diff_left, 2);
        avg_vel.diff_right = mean(vel.diff_right, 2);
        
        figure(vel_f);
        subplot(2,2,iTraj);
        hold on;
        % Same trials left.
        plot(traj_mat(:, same_trials.left, 3)*flip_traj, vel.same_left, 'Color',[0 0.4470 0.7410 0.3]);
        % Same trials right.
        plot(traj_mat(:, same_trials.right, 3)*flip_traj, vel.same_right, 'Color',[0 0.4470 0.7410 0.3]);
        % diff trials left.
        plot(traj_mat(:, diff_trials.left, 3)*flip_traj, vel.diff_left, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % diff trials right.
        plot(traj_mat(:, diff_trials.right, 3)*flip_traj, vel.diff_right, 'Color',[0.6350 0.0780 0.1840 0.3]);
        % Averages.
        plot(avg_traj_table.same_left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.same_left, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.same_right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.same_right, 'b', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.diff_left{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.diff_left, 'r', 'LineWidth',4); % X as func of Z.
        plot(avg_traj_table.diff_right{:, traj_names{iTraj}{3}}*flip_traj, avg_vel.diff_right, 'r', 'LineWidth',4); % X as func of Z.
        h(1) = plot(nan,nan,'Color',[0 0.4470 0.7410 0.3]);
        h(2) = plot(nan,nan,'Color',[0.6350 0.0780 0.1840 0.3]);
        h(3) = plot(nan,nan,'b');
        h(4) = plot(nan,nan,'r');
        legend(h, 'same', 'diff', 'same avg', 'diff avg', 'Location','southeast');
        xlabel('Z'); xlim([0, 0.4]);
        ylabel('Velocity'); ylim([0, 1]);
        title(traj_names{iTraj}{1}, 'Interpreter','none');
        set(gca, 'FontSize',14);
        %}
%%
function p = defineParams(p, SUBS, DAY, iSub)
    p.DATA_FOLDER = '../../raw_data/';

    p = load([p.DATA_FOLDER '/sub' num2str(iSub) DAY '_' 'p.mat']); p = p.p;
    p.DATA_FOLDER = '../../raw_data/';
    p.SUBS = SUBS;
    p.DAY = DAY;
    p.N_SUBS = length(p.SUBS);
    p.MAX_SUB = max(p.SUBS);
    % Normalization params.
    p.TRAJ_FILT_ORDER = 2;
    p.TRAJ_FILT_CUTOFF = 8;% in Hz.
    p.VEL_FILTER_ORDER = 2;
    p.VEL_FILTER_CUTOFF = 10;% in Hz.
    p.NORM_FRAMES = 200; % length of normalized trajs.
    p.NORM_TYPE = 4; % 1=to time, 2=to x, 3=to y, 4=to z.

    % Reach dist: Subs 1-10 = 40cm, Subs 10-20 = 35cm.
    % Recog cap length: Subs 1-10 = 5sec, Subs 10-20 = 7sec.
    % Categor cap length: Subs 1-10 = 1.5sec, Subs 10-20 = 0.75sec.
    if all(p.SUBS <= 10)
        p.SCREEN_DIST = 0.4;
        p.RECOG_CAP_LENGTH_SEC = 5;
        p.CATEGOR_CAP_LENGTH_SEC = 1.5;
    elseif all(p.SUBS > 10)
        p.SCREEN_DIST = 0.35;
        p.RECOG_CAP_LENGTH_SEC = 7;
        p.CATEGOR_CAP_LENGTH_SEC = 0.75;
    else
        error('Please analyze subs 1-10 seperatly from 11-20');
    end
    p.MIN_REACH_DIST = p.SCREEN_DIST - p.MAX_DIST_FROM_SCREEN;
    p.DIST_BETWEEN_TARGETS = 0.20; % In meter.
    p.TARGET_MISS_RANGE = 0.12; % In meter.
    p.RECOG_CAP_LENGTH = p.RECOG_CAP_LENGTH_SEC * p.REF_RATE_HZ; % Trajectory capture length (num of samples).
    p.CATEGOR_CAP_LENGTH = p.CATEGOR_CAP_LENGTH_SEC * p.REF_RATE_HZ;
    p.MAX_CAP_LENGTH = max(p.RECOG_CAP_LENGTH, p.CATEGOR_CAP_LENGTH);
    % @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
    p.PROC_DATA_FOLDER = '../processed_data/';
    p.TESTS_FOLDER = '../../experiment/RUN_ME/code/tests/test_results/';
    p.MIN_REACT_TIME_SAMPLES = 10;
    p.MAX_BAD_TRIALS = p.NUM_TRIALS - 60; % sub with more bad trials is disqualified.
    p.MIN_AMNT_TRIALS_IN_COND = 30; % sub with less good trials in each condition (same/diff) is disqualified.
    p.REACT_TIME_SAMPLES = p.REACT_TIME * p.REF_RATE_HZ;
    p.MOVE_TIME_SAMPLES = p.MOVE_TIME * p.REF_RATE_HZ;
    p.SIG_PVAL = 0.05;
    % @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@remove
end