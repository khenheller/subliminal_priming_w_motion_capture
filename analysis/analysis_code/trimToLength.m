% Find shortest traj that is longer than a certain threshold,
% Trim all trajs to that length.
% trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim double matrix, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has MAX_CAP_LENGTH samples.
function [traj_mat, time_mat] = trimToLength(traj_mat, time_mat, p)
% Traj lengths.
lengths = NaN(size(traj_mat, 2), 1);
for iTraj = 1:size(traj_mat, 2)
    lengths(iTraj) = find(~isnan(traj_mat(:,iTraj,1)), 1, 'last');
end
% Exclude short (time) trajs.
lengths(lengths * p.REF_RATE_SEC < p.MIN_TRIM_FRAMES) = [];
% Trim all the minimal length.
min_traj_len = min(lengths);
traj_mat(min_traj_len+1 : end, :, :) = NaN;
time_mat(min_traj_len+1 : end, :) = NaN;
end