% Gets single sub, 
% For each trial:
%   Set origin as the first sample's coordinates.
%   Rotate axes to be orthogonal to screen --> not implemented since the calibration in the
%       exp makes sure axes are perpendicualr to the screen.
%   Set each trial's first timestamp as time=0.
% Receives: trajs_mat - a subject's trajectory, of 1 type (categot_to / categor_from / recog_to / recog_from).
%               3 Dim double matrix, row = sample, column = trial, 3rd dim = axis (x,y,z).
%               Each trial has MAX_CAP_LENGTH samples.
%           timestamps - timestamps of traj samples.
%                       Double matrix, row = timestamps, column = trials.
function [trajs_mat, timestamps_mat] = setOrigin(trajs_mat, timestamps_mat)
    
    origins = trajs_mat(1, :, :);
    % replicate origins, one for each sample.
    origins_mat = repelem(origins, size(trajs_mat, 1), 1, 1);
    % Move axis origin to start point.
    trajs_mat = trajs_mat - origins_mat;
    
    origins = timestamps_mat(1,:);
    origins_mat = repelem(origins, size(timestamps_mat, 1), 1);
    % Set each trial's first timestamp as time=0.
    timestamps_mat = timestamps_mat - origins_mat;
end