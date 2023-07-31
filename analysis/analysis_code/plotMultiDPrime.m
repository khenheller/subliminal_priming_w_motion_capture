% Plots avg d' over all subs in each iteration of d prime decoding (keybaoard,reach and direct, indirect measures).
% Also plots the d' of all the subs in the last iteration.
function [] = plotMultiDPrime(traj_name, subplot_p, plt_p, p)
    disp('------------D Prime------------');

    % Print the result of many betas
    % figure();
    % beesdata = mat2cell(betas, iters, ones(size(betas, 2), 1));
    % yLabel = 'betas';
    % XTickLabel = [r_betas.Properties.VariableNames];
    % err_bar_type = 'se';
    % colors = repmat({plt_p.green_1}, 1, size(betas, 2));
    % title_char = ['Coefficients after ' num2str(iters) ' iterations'];
    % printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, err_bar_type, plt_p.alpha_size);

    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    % Load data.
    d_prime = load([p.PROC_DATA_FOLDER '/d_prime_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);
    r_d_prime = d_prime.r_d_prime;
    k_d_prime = d_prime.k_d_prime;

    % --------- All iters d' ---------
    subplot(subplot_p(1,1), subplot_p(1,2), subplot_p(1,3));
    % Avg over subs.
    avg_r_d_prime.direct = mean(r_d_prime.direct(:, good_subs), 2);
    avg_k_d_prime.direct = mean(k_d_prime.direct(:, good_subs), 2);
    avg_r_d_prime.indirect = mean(r_d_prime.indirect(:, good_subs), 2);
    avg_k_d_prime.indirect = mean(k_d_prime.indirect(:, good_subs), 2);
    % Prep ploting params
    beesdata = {avg_r_d_prime.direct, avg_r_d_prime.indirect,...
        avg_k_d_prime.direct, avg_k_d_prime.indirect};
    yLabel = 'Avg d prime';
    XTickLabel = ["reach_{direct}","reach_{indirect}","keyboard_{direct}","keyboard_{indirect}"];
    err_bar_type = 'se';
    colors = repmat({plt_p.green_1}, 1, 4);
    title_char = ['D prime after ' num2str(size(r_d_prime.direct, 1)) ' iterations'];
    % Plot
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, err_bar_type, plt_p.alpha_size);
    
    yline(0);
    set(gca, 'TickDir','out');
    set(gca, 'TickLength',[0, 0]);
    ylim([-1.5 2]);

    % --------- Last d' ---------
    subplot(subplot_p(2,1), subplot_p(2,2), subplot_p(2,3));
    % Prep ploting params
    beesdata = {r_d_prime.direct(end, good_subs), r_d_prime.indirect(end, good_subs),...
        k_d_prime.direct(end, good_subs), k_d_prime.indirect(end, good_subs)};
    yLabel = 'd prime';
    XTickLabel = ["reach_{direct}","reach_{indirect}","keyboard_{direct}","keyboard_{indirect}"];
    err_bar_type = 'se';
    colors = repmat({plt_p.green_1}, 1, 4);
    title_char = ['D prime of last iteration'];
    % Plot
    printBeeswarm(beesdata, yLabel, XTickLabel, colors, plt_p.space, title_char, err_bar_type, plt_p.alpha_size);
    yline(0);

    % Connect each sub's dots with lines.
    y_data = [r_d_prime.direct(end, good_subs), k_d_prime.direct(end, good_subs);...
        r_d_prime.indirect(end, good_subs), k_d_prime.indirect(end, good_subs)];
    x_data = reshape(get(gca,'XTick'), 2,[]);
    x_data = repelem(x_data,1,length(good_subs));
    connect_dots(x_data, y_data);
    
    set(gca, 'TickDir','out');
    set(gca, 'TickLength',[0, 0]);
    ylim([-1.5 2]);

    % T-test and Cohen's dz
    [~, r_p_val, r_ci, r_stats] = ttest(r_d_prime.direct(end, good_subs), r_d_prime.indirect(end, good_subs));
    [~, k_p_val, k_ci, k_stats] = ttest(k_d_prime.direct(end, good_subs), k_d_prime.indirect(end, good_subs));

    % Print stats to terminal.
    printStats('Reach d on final iter', r_d_prime.direct(end, good_subs), ...
        r_d_prime.indirect(end, good_subs), ["Direct","Indirect"], r_p_val, r_ci, r_stats);
    printStats('Keyboard d on final iter', k_d_prime.direct(end, good_subs), ...
        k_d_prime.indirect(end, good_subs), ["Direct","Indirect"], k_p_val, k_ci, k_stats);
end