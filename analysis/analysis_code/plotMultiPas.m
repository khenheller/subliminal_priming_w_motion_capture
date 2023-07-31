% Plots the average (over good subs) PAS.
% measure - 'reach'/'keyboard'.
% group - 'all_subs','good_subs', to include in analysis.
% plt_p - struct of plotting params.
% p - struct of exp params.
function [] = plotMultiPas(traj_name, measure, group, plt_p, p)
    avg_each = load([p.PROC_DATA_FOLDER '/avg_each_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  avg_each = avg_each.([measure, '_avg_each']);
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    
    % Which subs to analyze.
    if isequal(group, 'all_subs')
        subs = p.SUBS;
    elseif isequal(group, 'good_subs')
        subs = good_subs;
    else
        error('Wrong input, use all_subs or good_subs.');
    end
    % Average across subs.
    pas_con = mean(avg_each.pas.con(subs,:), 1);
    pas_incon = mean(avg_each.pas.incon(subs,:), 1);


    hold on;
    % Plot.
    bar(1:4, pas_con * 100 / sum(pas_con), 'FaceColor',plt_p.con_col);
    bar(5:8, pas_incon * 100 / sum(pas_incon), 'FaceColor',plt_p.incon_col);

    xticks(1:8);
    xticklabels({1:4 1:4});
    xlabel('PAS');
    ylabel('% Trials', 'FontWeight','bold');
    ylim([0 100]);
    title(['PAS, ' group ', ' measure]);
    set(gca,'FontSize',14);
    % Legend.
    legend('Con','Incon');

    % Cumulative ratings.
    disp(['@@@@--------Cumulative PAS ', measure, ' ', group, '--------@@@@']);
    con_pas = sum(avg_each.pas.con(subs,:), 1)';
    incon_pas = sum(avg_each.pas.incon(subs,:), 1)';
    combined_pas = sum([con_pas, incon_pas], 2);
    pas_ratings = table([1,2,3,4]', con_pas, incon_pas, combined_pas, combined_pas/sum(combined_pas),...
                        'VariableNames',{'rating','con','incon','sum', 'proportion'});
    disp(pas_ratings);
end