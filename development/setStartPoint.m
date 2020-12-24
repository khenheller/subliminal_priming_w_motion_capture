function [start_point] = setStartPoint()
    global NATNETCLIENT TOUCH_PLANE_INFO

    reply='N';
    while ~strcmpi(reply,'Y')

        % Asks if finger is at start point.
        Question = {'Place finger at starting point and then press ok'};
        ButtonName = questdlg(Question, 'Wait for finger positioning', 'Ok', 'Quit', 'Ok');

        switch ButtonName
            case 'Ok'
            case 'Quit'
                clear all; close all; Screen('CloseAll'); 
                disp('*** Exiting Program ***');
                return
        end

        markers = NATNETCLIENT.getFrame.LabeledMarker;
        cur_location = [markers(1).x markers(1).y markers(1).z];
        cur_location = transform4(TOUCH_PLANE_INFO.T_opto_plane, cur_location); % transform to screen related space.

        Question = {'STARTING POINT pre coordinate transform:'...
            ''...
            'Marker 1: ' num2str(cur_location(1:3))...
            ''...
            'Accept?'...
            ''};
        ButtonName = questdlg(Question, 'Data Check', 'Yes', 'No', 'Quit', 'Yes');

        switch ButtonName
            case 'Yes'
                start_point = cur_location;
                reply = 'Y';
            case 'No'
                reply = 'N';
            case 'Quit'
                clear all; close all; Screen('CloseAll'); 
                disp('*** Exiting Program ***');
                return
        end
    end
end