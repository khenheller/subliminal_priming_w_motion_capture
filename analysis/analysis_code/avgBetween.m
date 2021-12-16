% Calc average between subjects.
function [subs_avg] = avgBetween(traj_name, p)
    % Init vars.
    subs_avg.traj.same_left  = zeros(p.NORM_FRAMES, 3);
    subs_avg.traj.same_right = zeros(p.NORM_FRAMES, 3);
    subs_avg.traj.diff_left  = zeros(p.NORM_FRAMES, 3);
    subs_avg.traj.diff_right = zeros(p.NORM_FRAMES, 3);
    subs_avg.rt.same_left  = 0;
    subs_avg.rt.same_right = 0;
    subs_avg.rt.diff_left  = 0;
    subs_avg.rt.diff_right = 0;
    subs_avg.react.same_left  = 0;
    subs_avg.react.same_right = 0;
    subs_avg.react.diff_left  = 0;
    subs_avg.react.diff_right = 0;
    subs_avg.mt.same_left  = 0;
    subs_avg.mt.same_right = 0;
    subs_avg.mt.diff_left  = 0;
    subs_avg.mt.diff_right = 0;
    subs_avg.fc_prime.same = 0;
    subs_avg.fc_prime.diff = 0;
    subs_avg.pas.same = [0 0 0 0]; % 4 lvls of pas.
    subs_avg.pas.diff = [0 0 0 0];
    subs_avg.mad.same_left  = 0;
    subs_avg.mad.same_right = 0;
    subs_avg.mad.diff_left  = 0;
    subs_avg.mad.diff_right = 0;
    subs_avg.mad_p.same_left  = zeros(1, 3);
    subs_avg.mad_p.same_right = zeros(1, 3);
    subs_avg.mad_p.diff_left  = zeros(1, 3);
    subs_avg.mad_p.diff_right = zeros(1, 3);
    subs_avg.reach_area.same = 0;
    subs_avg.reach_area.diff = 0;
    subs_avg.x_std.same_left  = zeros(p.NORM_FRAMES,1);
    subs_avg.x_std.same_right = zeros(p.NORM_FRAMES,1);
    subs_avg.x_std.diff_left  = zeros(p.NORM_FRAMES,1);
    subs_avg.x_std.diff_right = zeros(p.NORM_FRAMES,1);
    subs_avg.x_avg_std.same_left  = 0;
    subs_avg.x_avg_std.same_right = 0;
    subs_avg.x_avg_std.diff_left  = 0;
    subs_avg.x_avg_std.diff_right = 0;
    
    reach_area = load([p.PROC_DATA_FOLDER strrep(traj_name{1}, '_x','') '_' p.DAY '_reach_area.mat']);  reach_area = reach_area.reach_area;
    bad_subs = load([p.PROC_DATA_FOLDER '/bad_subs_' p.DAY '_' traj_name{1} '.mat'], 'bad_subs');  bad_subs = bad_subs.bad_subs;
    subs = p.SUBS .* ~bad_subs{p.SUBS,'any'}'; % remove bad subs.
    subs(subs==0) = [];
    
    for iSub = subs
        % load avg within subject.
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) p.DAY '_' 'avg_' traj_name{1}]);  avg = avg.avg;
        % sum to calc avg between subjects.
        subs_avg.traj.same_left  = subs_avg.traj.same_left  + avg.traj.same_left;
        subs_avg.traj.same_right = subs_avg.traj.same_right + avg.traj.same_right;
        subs_avg.traj.diff_left  = subs_avg.traj.diff_left  + avg.traj.diff_left;
        subs_avg.traj.diff_right = subs_avg.traj.diff_right + avg.traj.diff_right;
        subs_avg.rt.same_left  = subs_avg.rt.same_left  + avg.rt.same_left;
        subs_avg.rt.same_right = subs_avg.rt.same_right + avg.rt.same_right;
        subs_avg.rt.diff_left  = subs_avg.rt.diff_left  + avg.rt.diff_left;
        subs_avg.rt.diff_right = subs_avg.rt.diff_right + avg.rt.diff_right;
        subs_avg.react.same_left  = subs_avg.react.same_left  + avg.react.same_left;
        subs_avg.react.same_right = subs_avg.react.same_right + avg.react.same_right;
        subs_avg.react.diff_left  = subs_avg.react.diff_left  + avg.react.diff_left;
        subs_avg.react.diff_right = subs_avg.react.diff_right + avg.react.diff_right;
        subs_avg.mt.same_left  = subs_avg.mt.same_left  + avg.mt.same_left;
        subs_avg.mt.same_right = subs_avg.mt.same_right + avg.mt.same_right;
        subs_avg.mt.diff_left  = subs_avg.mt.diff_left  + avg.mt.diff_left;
        subs_avg.mt.diff_right = subs_avg.mt.diff_right + avg.mt.diff_right;
        subs_avg.fc_prime.same = subs_avg.fc_prime.same + avg.fc_prime.same;
        subs_avg.fc_prime.diff = subs_avg.fc_prime.diff + avg.fc_prime.diff;
        subs_avg.pas.same = subs_avg.pas.same + avg.pas.same;
        subs_avg.pas.diff = subs_avg.pas.diff + avg.pas.diff;
        subs_avg.mad.same_left  = subs_avg.mad.same_left  + avg.mad.same_left;
        subs_avg.mad.same_right = subs_avg.mad.same_right + avg.mad.same_right;
        subs_avg.mad.diff_left  = subs_avg.mad.diff_left  + avg.mad.diff_left;
        subs_avg.mad.diff_right = subs_avg.mad.diff_right + avg.mad.diff_right;
        subs_avg.mad_p.same_left  = subs_avg.mad_p.same_left  + avg.mad_p.same_left;
        subs_avg.mad_p.same_right = subs_avg.mad_p.same_right + avg.mad_p.same_right;
        subs_avg.mad_p.diff_left  = subs_avg.mad_p.diff_left  + avg.mad_p.diff_left;
        subs_avg.mad_p.diff_right = subs_avg.mad_p.diff_right + avg.mad_p.diff_right;
        subs_avg.x_std.same_left  = subs_avg.x_std.same_left  + avg.x_std.same_left;
        subs_avg.x_std.same_right = subs_avg.x_std.same_right + avg.x_std.same_right;
        subs_avg.x_std.diff_left  = subs_avg.x_std.diff_left  + avg.x_std.diff_left;
        subs_avg.x_std.diff_right = subs_avg.x_std.diff_right + avg.x_std.diff_right;
        subs_avg.x_avg_std.same_left  = subs_avg.x_avg_std.same_left  + avg.x_avg_std.same_left;
        subs_avg.x_avg_std.same_right = subs_avg.x_avg_std.same_right + avg.x_avg_std.same_right;
        subs_avg.x_avg_std.diff_left  = subs_avg.x_avg_std.diff_left  + avg.x_avg_std.diff_left;
        subs_avg.x_avg_std.diff_right = subs_avg.x_avg_std.diff_right + avg.x_avg_std.diff_right;
    end
    subs_avg.traj.same_left  = subs_avg.traj.same_left  / length(subs);
    subs_avg.traj.same_right = subs_avg.traj.same_right / length(subs);
    subs_avg.traj.diff_left  = subs_avg.traj.diff_left  / length(subs);
    subs_avg.traj.diff_right = subs_avg.traj.diff_right / length(subs);
    subs_avg.rt.same_left  = subs_avg.rt.same_left  / length(subs);
    subs_avg.rt.same_right = subs_avg.rt.same_right / length(subs);
    subs_avg.rt.diff_left  = subs_avg.rt.diff_left  / length(subs);
    subs_avg.rt.diff_right = subs_avg.rt.diff_right / length(subs);
    subs_avg.react.same_left  = subs_avg.react.same_left  / length(subs);
    subs_avg.react.same_right = subs_avg.react.same_right / length(subs);
    subs_avg.react.diff_left  = subs_avg.react.diff_left  / length(subs);
    subs_avg.react.diff_right = subs_avg.react.diff_right / length(subs);
    subs_avg.mt.same_left  = subs_avg.mt.same_left  / length(subs);
    subs_avg.mt.same_right = subs_avg.mt.same_right / length(subs);
    subs_avg.mt.diff_left  = subs_avg.mt.diff_left  / length(subs);
    subs_avg.mt.diff_right = subs_avg.mt.diff_right / length(subs);
    subs_avg.fc_prime.same = subs_avg.fc_prime.same / length(subs);
    subs_avg.fc_prime.diff = subs_avg.fc_prime.diff / length(subs);
    subs_avg.pas.same = subs_avg.pas.same / length(subs);
    subs_avg.pas.diff = subs_avg.pas.diff / length(subs);
    subs_avg.mad.same_left  = subs_avg.mad.same_left  / length(subs);
    subs_avg.mad.same_right = subs_avg.mad.same_right / length(subs);
    subs_avg.mad.diff_left  = subs_avg.mad.diff_left  / length(subs);
    subs_avg.mad.diff_right = subs_avg.mad.diff_right / length(subs);
    subs_avg.mad_p.same_left  = subs_avg.mad_p.same_left  / length(subs);
    subs_avg.mad_p.same_right = subs_avg.mad_p.same_right / length(subs);
    subs_avg.mad_p.diff_left  = subs_avg.mad_p.diff_left  / length(subs);
    subs_avg.mad_p.diff_right = subs_avg.mad_p.diff_right / length(subs);
    subs_avg.reach_area.same = mean(reach_area.same);
    subs_avg.reach_area.diff = mean(reach_area.diff);
    subs_avg.x_std.same_left  = subs_avg.x_std.same_left  / length(subs);
    subs_avg.x_std.same_right = subs_avg.x_std.same_right / length(subs);
    subs_avg.x_std.diff_left  = subs_avg.x_std.diff_left  / length(subs);
    subs_avg.x_std.diff_right = subs_avg.x_std.diff_right / length(subs);
    subs_avg.x_avg_std.same_left  = subs_avg.x_avg_std.same_left  / length(subs);
    subs_avg.x_avg_std.same_right = subs_avg.x_avg_std.same_right / length(subs);
    subs_avg.x_avg_std.diff_left  = subs_avg.x_avg_std.diff_left  / length(subs);
    subs_avg.x_avg_std.diff_right = subs_avg.x_avg_std.diff_right / length(subs);
end