function [traj_df] = fTraj(traj_name, p)
traj_len = load([p.PROC_DATA_FOLDER '/trim_len.mat']);  traj_len = traj_len.trim_len;
% Build dataframe.
num_rows = p.N_SUBS * p.N_CONDS * p.NUM_TRIALS * traj_len;
columns = ["sub", "side", "cond", "xpos", "zindex"];
traj_df = table('Size',[num_rows, length(columns)], 'VariableType',{'double','string','string','double','double'}, 'VariableName',columns);

% Fill table with goods.
j = 1;
for iSub = p.SUBS
    sub_trajs = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_name{1} '.mat']); sub_trajs = sub_trajs.trial.trajs;
    for cond = p.CONDS
        for side = ["left","right"]
            % Get trajs for this cond and side.
            trajs = sub_trajs.(strcat(cond,'_',side));
            num_trials = size(trajs,2);
            sub_col = repelem(iSub, num_trials*traj_len, 1);
            cond_col = repelem(cond, num_trials*traj_len, 1);
            side_col = repelem(side, num_trials*traj_len, 1);
            z_col = repmat([1:traj_len]', num_trials, 1);
            x_col = reshape(trajs(:,:,1), num_trials*traj_len, 1);
            traj_df(j:j-1+num_trials*traj_len, :) = table(sub_col, side_col, cond_col, x_col, z_col); % has to match columns!
            j = j + num_trials*traj_len;
        end
    end
end
traj_df(ismissing(traj_df.side),:) = [];
end