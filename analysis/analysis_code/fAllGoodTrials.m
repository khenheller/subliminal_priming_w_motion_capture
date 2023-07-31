% Creates 2 dataframes (tables, one for keyboard one for reaching),
% columns are vars, rows are trials. Holds all the sub's good trials.
% Adds 2 extra columns to indicate trial type (con/incon and left/right).
function [r_table, k_table] = fAllGoodTrials(iSub, p)
% Choose whether or not to analyze timeseries vars.
analyze_timeseries = 1;
% Load data.
trials = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_target_x_to.mat']); 
r_sorted = trials.r_trial;
k_sorted = trials.k_trial;
% Can't touch this! Tuuu Du Du Du, Ta Ta! (All reaching vars you want to include).
vars = ["react","mt","mad","tot_dist","auc","max_vel"];
% Num trials.
n_trials = load([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_target_x_to_subs_' p.SUBS_STRING '.mat']);
r_n_trials = n_trials.reach_num_trials(iSub);
k_n_trials = n_trials.keyboard_num_trials(iSub);

% Combine left/right con/incon.
for var_name = vars
    r_combined.(var_name) = [r_sorted.(var_name).con_left; r_sorted.(var_name).con_right; r_sorted.(var_name).incon_left; r_sorted.(var_name).incon_right];
end
x = [r_sorted.trajs.con_left(:,:,1)'; r_sorted.trajs.con_right(:,:,1)'; r_sorted.trajs.incon_left(:,:,1)'; r_sorted.trajs.incon_right(:,:,1)'];
iep = [r_sorted.iep.con_left(:,:)'; r_sorted.iep.con_right(:,:)'; r_sorted.iep.incon_left(:,:)'; r_sorted.iep.incon_right(:,:)'];
k_combined.rt = [k_sorted.rt.con_left; k_sorted.rt.con_right; k_sorted.rt.incon_left; k_sorted.rt.incon_right];
% Convert to table.
r_table = struct2table(r_combined);
if analyze_timeseries
    r_table = [r_table array2table(x) array2table(iep)];
end
k_table = struct2table(k_combined);
% Add trial types.
r_table.cond = [repmat("con",r_n_trials.con,1); repmat("incon",r_n_trials.incon,1)];
r_table.side = [repmat("left",r_n_trials.con_left,1); repmat("right",r_n_trials.con_right,1);...
    repmat("left",r_n_trials.incon_left,1); repmat("right",r_n_trials.incon_right,1)];
k_table.cond = [repmat("con",k_n_trials.con,1); repmat("incon",k_n_trials.incon,1)];
k_table.side = [repmat("left",k_n_trials.con_left,1); repmat("right",k_n_trials.con_right,1);...
    repmat("left",k_n_trials.incon_left,1); repmat("right",k_n_trials.incon_right,1)];
end