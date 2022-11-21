% Calc average between subjects.
% r = reach, k = keyboard.
function [r_subs_avg, k_subs_avg] = avgBetween(traj_name, p)
    traj_len = p.NORM_TRAJ * p.NORM_FRAMES + ~p.NORM_TRAJ * p.MIN_TRIM_FRAMES;
    % Init reach vars.
    r_subs_avg.traj  = struct('con_left',zeros(traj_len, 3), 'con_right',zeros(traj_len, 3), 'incon_left',zeros(traj_len, 3), 'incon_right',zeros(traj_len, 3));
    r_subs_avg.x_std = struct('con_left',zeros(traj_len,1), 'con_right',zeros(traj_len,1), 'incon_left',zeros(traj_len,1), 'incon_right',zeros(traj_len,1));
    r_subs_avg.head_angle = struct('con_left',zeros(traj_len,1), 'con_right',zeros(traj_len,1), 'incon_left',zeros(traj_len,1), 'incon_right',zeros(traj_len,1));
    r_subs_avg.rt        = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.react     = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.mt        = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.mad       = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.mad_p     = struct('con_left',[0 0 0], 'con_right',[0 0 0], 'incon_left',[0 0 0], 'incon_right',[0 0 0]);
    r_subs_avg.com       = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.tot_dist  = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.auc       = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.x_avg_std = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    r_subs_avg.fc_prime   = struct('con',0, 'incon',0);
    r_subs_avg.reach_area = struct('con',0, 'incon',0);
    r_subs_avg.pas = struct('con',[0 0 0 0], 'incon',[0 0 0 0]); % 4 lvls of pas.
    % Init keyboard vars.
    k_subs_avg.rt = struct('con_left',0, 'con_right',0, 'incon_left',0, 'incon_right',0);
    k_subs_avg.fc_prime = struct('con',0, 'incon',0);
    k_subs_avg.pas = struct('con',[0 0 0 0], 'incon',[0 0 0 0]); % 4 lvls of pas.
    
    reach_area = load([p.PROC_DATA_FOLDER '/reach_area_' traj_name{1} '_' p.DAY '_subs_' p.SUBS_STRING '.mat']);  reach_area = reach_area.reach_area;
    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    n_good_subs = length(good_subs);
    
    for iSub = good_subs
        p = defineParams(p, iSub);
        % load avg within subject.
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_name{1}]);  r_avg = avg.r_avg; k_avg = avg.k_avg;
        % sum to calc avg between subjects.
        % Reach
        r_subs_avg.traj      = sortedSum(r_subs_avg.traj, r_avg.traj);
        r_subs_avg.head_angle= sortedSum(r_subs_avg.head_angle, r_avg.head_angle);
        r_subs_avg.rt        = sortedSum(r_subs_avg.rt, r_avg.rt);
        r_subs_avg.react     = sortedSum(r_subs_avg.react, r_avg.react);
        r_subs_avg.mt        = sortedSum(r_subs_avg.mt, r_avg.mt);
        r_subs_avg.mad       = sortedSum(r_subs_avg.mad, r_avg.mad);
        r_subs_avg.mad_p     = sortedSum(r_subs_avg.mad_p, r_avg.mad_p);
        r_subs_avg.com       = sortedSum(r_subs_avg.com, r_avg.com);
        r_subs_avg.tot_dist  = sortedSum(r_subs_avg.tot_dist, r_avg.tot_dist);
        r_subs_avg.auc       = sortedSum(r_subs_avg.auc, r_avg.auc);
        r_subs_avg.x_std     = sortedSum(r_subs_avg.x_std, r_avg.x_std);
        r_subs_avg.fc_prime.con   = r_subs_avg.fc_prime.con + r_avg.fc_prime.con;
        r_subs_avg.fc_prime.incon = r_subs_avg.fc_prime.incon + r_avg.fc_prime.incon;
        r_subs_avg.pas.con        = r_subs_avg.pas.con + r_avg.pas.con;
        r_subs_avg.pas.incon      = r_subs_avg.pas.incon + r_avg.pas.incon;
        % Keyboard
        k_subs_avg.rt = sortedSum(k_subs_avg.rt, k_avg.rt);
        k_subs_avg.fc_prime.con   = k_subs_avg.fc_prime.con + k_avg.fc_prime.con;
        k_subs_avg.fc_prime.incon = k_subs_avg.fc_prime.incon + k_avg.fc_prime.incon;
        k_subs_avg.pas.con        = k_subs_avg.pas.con + k_avg.pas.con;
        k_subs_avg.pas.incon      = k_subs_avg.pas.incon + k_avg.pas.incon;
    end
    % Reach.
    r_subs_avg.traj      = divideByNumOfSubs(r_subs_avg.traj, n_good_subs);
    r_subs_avg.head_angle= divideByNumOfSubs(r_subs_avg.head_angle, n_good_subs);
    r_subs_avg.rt        = divideByNumOfSubs(r_subs_avg.rt, n_good_subs);
    r_subs_avg.react     = divideByNumOfSubs(r_subs_avg.react, n_good_subs);
    r_subs_avg.mt        = divideByNumOfSubs(r_subs_avg.mt, n_good_subs);
    r_subs_avg.mad       = divideByNumOfSubs(r_subs_avg.mad, n_good_subs);
    r_subs_avg.mad_p     = divideByNumOfSubs(r_subs_avg.mad_p, n_good_subs);
    r_subs_avg.com       = divideByNumOfSubs(r_subs_avg.com, n_good_subs);
    r_subs_avg.tot_dist  = divideByNumOfSubs(r_subs_avg.tot_dist, n_good_subs);
    r_subs_avg.auc       = divideByNumOfSubs(r_subs_avg.auc, n_good_subs);
    r_subs_avg.x_std     = divideByNumOfSubs(r_subs_avg.x_std, n_good_subs);
    r_subs_avg.x_avg_std = divideByNumOfSubs(r_subs_avg.mad_p, n_good_subs);
    r_subs_avg.fc_prime.con     = r_subs_avg.fc_prime.con / n_good_subs;
    r_subs_avg.fc_prime.incon   = r_subs_avg.fc_prime.incon / n_good_subs;
    r_subs_avg.pas.con          = r_subs_avg.pas.con / n_good_subs;
    r_subs_avg.pas.incon        = r_subs_avg.pas.incon / n_good_subs;
    r_subs_avg.reach_area.con   = mean(reach_area.con);
    r_subs_avg.reach_area.incon = mean(reach_area.incon);
    % Keyboard.
    k_subs_avg.rt = divideByNumOfSubs(k_subs_avg.rt, n_good_subs);
    k_subs_avg.fc_prime.con   = k_subs_avg.fc_prime.con / n_good_subs;
    k_subs_avg.fc_prime.incon = k_subs_avg.fc_prime.incon / n_good_subs;
    k_subs_avg.pas.con        = k_subs_avg.pas.con / n_good_subs;
    k_subs_avg.pas.incon      = k_subs_avg.pas.incon / n_good_subs;
end

% Sums according to trial type.
function [all_subs_avg] = sortedSum(all_subs_avg, single_sub_avg)
    all_subs_avg.con_left = all_subs_avg.con_left + single_sub_avg.con_left;
    all_subs_avg.con_right = all_subs_avg.con_right + single_sub_avg.con_right;
    all_subs_avg.incon_left = all_subs_avg.incon_left + single_sub_avg.incon_left;
    all_subs_avg.incon_right = all_subs_avg.incon_right + single_sub_avg.incon_right;
end

% Averages according to trial type.
function [all_subs_avg] = divideByNumOfSubs(all_subs_avg, n_good_subs)
    all_subs_avg.con_left = all_subs_avg.con_left / n_good_subs;
    all_subs_avg.con_right = all_subs_avg.con_right / n_good_subs;
    all_subs_avg.incon_left = all_subs_avg.incon_left / n_good_subs;
    all_subs_avg.incon_right = all_subs_avg.incon_right / n_good_subs;
end