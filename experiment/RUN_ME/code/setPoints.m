% Sets start and end points of reaching.
% p - all experiment's parameters.
function [p] = setPoints(p)
    p.START_POINT = setPoint(p.START_POINT_SCREEN, p);
    p.RIGHT_END_POINT = setPoint(p.RIGHT_END_POINT_SCREEN, p);
    p.LEFT_END_POINT = setPoint(p.LEFT_END_POINT_SCREEN, p);
    p.MIDDLE_POINT = setPoint(p.MIDDLE_POINT_SCREEN, p);
    file_name = [p.DATA_FOLDER '\sub' num2str(p.SUB_NUM) p.DAY '_start_end_points.mat'];
    save(file_name, 'p');
end