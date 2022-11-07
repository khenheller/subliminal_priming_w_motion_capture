% Runs Functional Data Analysis on trajs of all subs.
% Output: all outputs are struct with field for each axis (x,y,z).
%   p_val - p values for each point in the traj.
%   corr_p - corrected for repeated measures with variables with more than 2 levels.
%   t - ANOVA table.
%   stats - contains all sort of statistics.
function [p_val, corr_p, t, stats] = runFDA(trajs_name, p)
    fdaMat = struct('x',[],'y',[],'z',[]);
    group = {[], [], []}; % 3 grouping options: con/incon, left/right, subs.

    good_subs = load([p.PROC_DATA_FOLDER '/good_subs_' p.DAY '_' trajs_name{1} '_subs_' p.SUBS_STRING '.mat']);  good_subs = good_subs.good_subs;
    
    % GROUPING THE DATA
    for iSub = good_subs
        p = defineParams(p, iSub);
        trial = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_sorted_trials_' trajs_name{1} '.mat']);  trial = trial.r_trial;
        trajs = trial.trajs; % Sub's trajss (sorted).
        % Concatenate all the sub's trials.
        fdaMat.x = [fdaMat.x; trajs.con_left(:,:,1)'; trajs.con_right(:,:,1)'; trajs.incon_left(:,:,1)'; trajs.incon_right(:,:,1)'];
        fdaMat.y = [fdaMat.y; trajs.con_left(:,:,2)'; trajs.con_right(:,:,2)'; trajs.incon_left(:,:,2)'; trajs.incon_right(:,:,2)'];
        fdaMat.z = [fdaMat.z; trajs.con_left(:,:,3)'; trajs.con_right(:,:,3)'; trajs.incon_left(:,:,3)'; trajs.incon_right(:,:,3)'];
        amnt_trials.con  = size(trajs.con_left,  2) + size(trajs.con_right, 2);
        amnt_trials.incon  = size(trajs.incon_left,  2) + size(trajs.incon_right, 2);
        amnt_trials.left  = size(trajs.con_left,  2) + size(trajs.incon_left,  2);
        amnt_trials.right = size(trajs.con_right, 2) + size(trajs.incon_right, 2);
        % group trials according to con / incon cond.
        group{1} = [group{1}; ones(1,amnt_trials.con)'; 2*ones(1,amnt_trials.incon)'];
        % group trials according to left / right reach.
        group{2} = [group{2}; ones(1,size(trajs.con_left,2))'; 2*ones(1,size(trajs.con_right,2))';...
                              ones(1,size(trajs.incon_left,2))'; 2*ones(1,size(trajs.incon_right,2))'];
        % group trials according to sub num.
        group{3} = [group{3}; iSub * ones(1,amnt_trials.con + amnt_trials.incon)']; % total num of trials.
    end
    
    % AVG THE DATA
    [mean.x, mean_group.x] = getRMMeans(fdaMat.x, group);
    [mean.y, mean_group.y] = getRMMeans(fdaMat.y, group);
    [mean.z, mean_group.z] = getRMMeans(fdaMat.z, group);
    
    % RUN FDA
    random_fact = [3]; % left/right and subnum are random factors.
    [p_val.x, corr_p.x, t.x, stats.x] = fanovan(mean.x, mean_group.x, 'model','full', 'random',random_fact, 'varnames',{'con_incon' 'left_right' 'sub'});
    [p_val.y, corr_p.y, t.y, stats.y] = fanovan(mean.y, mean_group.y, 'model','full', 'random',random_fact, 'varnames',{'con_incon' 'left_right' 'sub'});
    [p_val.z, corr_p.z, t.z, stats.z] = fanovan(mean.z, mean_group.z, 'model','full', 'random',random_fact, 'varnames',{'con_incon' 'left_right' 'sub'});
end