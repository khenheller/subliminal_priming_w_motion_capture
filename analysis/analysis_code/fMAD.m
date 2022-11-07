% Format MAD to R dataframe.
% Output:
%   Columns: sub, condition, reach area, num_trials.
%   Rows: one for each combination of sub and condition.
function [mad_df] = fMAD(traj_name, p)
% Build dataframe.
num_rows = p.N_SUBS * 2 * p.N_CONDS * p.NUM_TRIALS; % 2=left/right.
columns = ["sub", "side", "cond", "mad"];
mad_df = table('size',[num_rows length(columns)], 'VariableTypes',{'double','string','string','double'}, 'VariableNames',columns);

% Fill table with goods.
j = 1;
for iSub = p.SUBS
    % Load sub data.
    sub_mad = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' traj_name{1} '.mat']);  sub_mad = sub_mad.trial.mad;

    for side = ["left", "right"]
        for cond = p.CONDS
            % Count trials in condANDside.
            mad_col = sub_mad.(strcat(cond,'_',side));
            num_trials = length(mad_col);
            sub_col = repelem(iSub, num_trials, 1);
            side_col = repelem(side, num_trials, 1);
            cond_col = repelem(cond, num_trials, 1);
            % Assign to dataframe.
            mad_df(j:j+num_trials-1,:) = table(sub_col, side_col, cond_col, mad_col); % has to match columns!
            j = j+num_trials;
        end
    end
end
mad_df(ismissing(mad_df.cond), :) = [];

%{
% This uses average mad for each sub, instead of singel trial. %
% Get num of trials.
num_trials = load([p.PROC_DATA_FOLDER '/num_trials_' p.DAY '_' traj_name{1} '_subs_' p.SUBS_STRING '.mat'], 'num_trials');  num_trials = num_trials.num_trials;
% Fill table with goods.
j = 1;
for iSub = p.SUBS
    sub_mad = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_name{1} '.mat']);  sub_mad = sub_mad.avg.mad;
    for side = ["left", "right"]
        for cond = p.CONDS
            % Get value from field that matches side and cond.
            mad = sub_mad.(strcat(cond,'_',side));
            n_trials = num_trials.(strcat(cond,'_',side));
            % Assign to dataframe.
            mad_df(j,:) = table(iSub, side, cond, mad, n_trials(iSub));
            j = j+1;
        end
    end
end

%}
end