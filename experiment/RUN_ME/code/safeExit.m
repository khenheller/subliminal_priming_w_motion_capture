% Closes Psychtoolbox and Natnet client before exisiting the experiment.
% p - all experiment's parameters.
function [] = safeExit(p)
    if ~p.DEBUG
        p.NATNETCLIENT.disconnect;
    end
%     Priority(0);
    sca;
    ShowCursor;
    ListenChar(0);
end