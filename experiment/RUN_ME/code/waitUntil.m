% Waits until event ends. 3 types of wait:
%   until event_dur - 1/2 refrate.
%   until event_dur - 3/4 refrate.
%   until last_event_time + event_dur - 1/2 refrate.
% didn't use switch case to save process times.
function [] = waitUntil(event_dur, p)
%     WaitSecs(event_dur - p.REF_RATE_SEC / 2); % "- p.REF_RATE_SEC / 2" so that it will flip exactly at the end of p.FIX_DURATION.
    WaitSecs(event_dur - p.REF_RATE_SEC * 3 / 4);
%     WaitSecs('UntilTime', times(1) + (event_dur - p.REF_RATE_SEC / 2));
end