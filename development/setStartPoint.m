function [start_point] = setStartPoint()
    global NATNETCLIENT

    reply='N';
    while ~strcmpi(reply,'Y')

        answer = {};
        while isempty(answer)        
            prompt={'Pixel Coords: '};
            name='Finger starting point';
            numlines=[1,35]; %this width allows for title to be seen
            defaultanswer={'[1920 1080]'};
            
            answer=inputdlg(prompt,name,numlines,defaultanswer);

            %convert from string to number data for output variables
            if ~isempty(answer)
                XAxisPixelCoords = str2num(answer{1});
            end
        end

        markers = NATNETCLIENT.getFrame.LabeledMarker;
        cur_location = [markers(1).x markers(1).y markers(1).z];

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