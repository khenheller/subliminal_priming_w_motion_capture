% Calc average between subjects.
function [subs_avg] = avgBetween(traj_name, p)
    subs_avg.traj.same_left  = zeros(p.NORM_FRAMES, 3);
    subs_avg.traj.same_right = zeros(p.NORM_FRAMES, 3);
    subs_avg.traj.diff_left  = zeros(p.NORM_FRAMES, 3);
    subs_avg.traj.diff_right = zeros(p.NORM_FRAMES, 3);
    subs_avg.rt.same_left  = 0;
    subs_avg.rt.same_right = 0;
    subs_avg.rt.diff_left  = 0;
    subs_avg.rt.diff_right = 0;
    subs_avg.fc.same = 0;
    subs_avg.fc.diff = 0;
    
    bad_subs = load([p.PROC_DATA_FOLDER '/bad_subs_' traj_name{1} '.mat'], 'bad_subs');  bad_subs = bad_subs.bad_subs;
    subs = p.SUBS .* ~bad_subs{:,'any'}'; % remove bad subs.
    
    for iSub = subs
        % load avg within subject.
        avg = load([p.PROC_DATA_FOLDER '/sub' num2str(iSub) 'avg_' traj_name{1}]);  avg = avg.avg;
        % sum to calc avg between subjects.
        subs_avg.traj.same_left  = subs_avg.traj.same_left  + avg.traj.same_left;
        subs_avg.traj.same_right = subs_avg.traj.same_right + avg.traj.same_right;
        subs_avg.traj.diff_left  = subs_avg.traj.diff_left  + avg.traj.diff_left;
        subs_avg.traj.diff_right = subs_avg.traj.diff_right + avg.traj.diff_right;
        subs_avg.rt.same_left  = subs_avg.rt.same_left  + avg.rt.same_left;
        subs_avg.rt.same_right = subs_avg.rt.same_right + avg.rt.same_right;
        subs_avg.rt.diff_left  = subs_avg.rt.diff_left  + avg.rt.diff_left;
        subs_avg.rt.diff_right = subs_avg.rt.diff_right + avg.rt.diff_right;
        subs_avg.fc.same = subs_avg.fc.same + avg.fc.same;
        subs_avg.fc.diff = subs_avg.fc.diff + avg.fc.diff;
    end
    subs_avg.traj.same_left  = subs_avg.traj.same_left  / length(subs);
    subs_avg.traj.same_right = subs_avg.traj.same_right / length(subs);
    subs_avg.traj.diff_left  = subs_avg.traj.diff_left  / length(subs);
    subs_avg.traj.diff_right = subs_avg.traj.diff_right / length(subs);
    subs_avg.rt.same_left  = subs_avg.rt.same_left  / length(subs);
    subs_avg.rt.same_right = subs_avg.rt.same_right / length(subs);
    subs_avg.rt.diff_left  = subs_avg.rt.diff_left  / length(subs);
    subs_avg.rt.diff_right = subs_avg.rt.diff_right / length(subs);
    subs_avg.fc.same = subs_avg.fc.same / length(subs);
    subs_avg.fc.diff = subs_avg.fc.diff / length(subs);
end