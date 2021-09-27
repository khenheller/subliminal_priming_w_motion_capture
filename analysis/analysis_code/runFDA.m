% Runs Functional Data Analysis on trajs of all subs.
% Output: all outputs are struct with field for each axis (x,y,z).
%   p_val - p values for each point in the traj.
%   corr_p - corrected for repeated measures with variables with more than 2 levels.
%   t - ANOVA table.
%   stats - contains all sort of statistics.
function [p_val, corr_p, t, stats] = runFDA(trajs_name, p)
    fdaMat = struct('x',[],'y',[],'z',[]);
    group = {[], [], []}; % 3 grouping options: same/diff, left/right, subs.
    
    % GROUPING THE DATA
    for iSub = p.SUBS
        single = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'sorted_trials_' trajs_name{1} '.mat']);  single = single.single;
        trajs = single.trajs; % Sub's trajss (sorted).
        % Concatenate all the sub's trials.
        fdaMat.x = [fdaMat.x; trajs.same_left(:,:,1)'; trajs.same_right(:,:,1)'; trajs.diff_left(:,:,1)'; trajs.diff_right(:,:,1)'];
        fdaMat.y = [fdaMat.y; trajs.same_left(:,:,2)'; trajs.same_right(:,:,2)'; trajs.diff_left(:,:,2)'; trajs.diff_right(:,:,2)'];
        fdaMat.z = [fdaMat.z; trajs.same_left(:,:,3)'; trajs.same_right(:,:,3)'; trajs.diff_left(:,:,3)'; trajs.diff_right(:,:,3)'];
        amnt_trials.same  = size(trajs.same_left,  2) + size(trajs.same_right, 2);
        amnt_trials.diff  = size(trajs.diff_left,  2) + size(trajs.diff_right, 2);
        amnt_trials.left  = size(trajs.same_left,  2) + size(trajs.diff_left,  2);
        amnt_trials.right = size(trajs.same_right, 2) + size(trajs.diff_right, 2);
        % group trials according to same / diff cond.
        group{1} = [group{1}; ones(1,amnt_trials.same)'; 2*ones(1,amnt_trials.diff)'];
        % group trials according to left / right reach.
        group{2} = [group{2}; ones(1,size(trajs.same_left,2))'; 2*ones(1,size(trajs.same_right,2))';...
                              ones(1,size(trajs.diff_left,2))'; 2*ones(1,size(trajs.diff_right,2))'];
        % group trials according to sub num.
        group{3} = [group{3}; iSub * ones(1,amnt_trials.same + amnt_trials.diff)']; % total num of trials.
    end
    
    % AVG THE DATA
    [mean.x, mean_group.x] = getRMMeans(fdaMat.x, group);
    [mean.y, mean_group.y] = getRMMeans(fdaMat.y, group);
    [mean.z, mean_group.z] = getRMMeans(fdaMat.z, group);
    
    % RUN FDA
    random_fact = [3]; % left/right and subnum are random factors.
    [p_val.x, corr_p.x, t.x, stats.x] = fanovan(mean.x, mean_group.x, 'model','full', 'random',random_fact, 'varnames',{'same_diff' 'left_right' 'sub'});
    [p_val.y, corr_p.y, t.y, stats.y] = fanovan(mean.y, mean_group.y, 'model','full', 'random',random_fact, 'varnames',{'same_diff' 'left_right' 'sub'});
    [p_val.z, corr_p.z, t.z, stats.z] = fanovan(mean.z, mean_group.z, 'model','full', 'random',random_fact, 'varnames',{'same_diff' 'left_right' 'sub'});
end