function touchDrawDemo

%ask whether to collect new touch_plane_info or use saved
ButtonName = questdlg('Perform calibraion?', ...
                     'New Calibration or load', ...
                     'New Calibration', 'Load Calibration', 'Quit', 'New Calibration');
switch ButtonName,
 case 'New Calibration',
    [touch_plane_info, client] = opti_setup_touch_plane_new;    
 case 'Load Calibration',
    [touch_plane_info, client] = use_last_touch_plane;
 case 'Quit',
    client.disconnect;
    Screen('closeAll');
    return;      
end % switch

white = [255 255 255];
black = [0 0 0];

cm = hsv*255;

Screen('Preference', 'SkipSyncTests', 1);
[mainWin, mainRect] = Screen('OpenWindow',2,white);
posStruct.centX = mainRect(3)/2;
posStruct.centY = mainRect(4)/2;
mmPerPixel = touch_plane_info.mmPerPixel/1000;

lastPos = [];
while 1
    markers = client.getFrame.LabeledMarker;
    if ~isempty(markers(1))
        curLocation = double([markers(1).x markers(1).y markers(1).z]);
        curLocation=transform4(touch_plane_info.T_opto_plane, curLocation);
        if ~isempty(lastPos)
                if round(curLocation(3)*1000/4) > 0 && round(curLocation(3)*1000) < 256
                    color = cm(round(curLocation(3)*1000/4),:);
                else
                    color = [0 0 0];
                end
                vel = sqrt((curLocation(1)-lastPos(1))^2 + (curLocation(2)-lastPos(2))^2 + (curLocation(3)-lastPos(3))^2) * 120;
                Screen('DrawLine', mainWin ,color, round(lastPos(1)/mmPerPixel), mainRect(4)-round(lastPos(2)/mmPerPixel), round(curLocation(1)/mmPerPixel), mainRect(4)-round(curLocation(2)/mmPerPixel),10);
                Screen('fillOval',mainWin,color,[-5+double(round(curLocation(1)/mmPerPixel)),mainRect(4)-5-double(round(curLocation(2)/mmPerPixel)), 5+double(round(curLocation(1)/mmPerPixel)), mainRect(4)+5-double(round(curLocation(2)/mmPerPixel))]);
                Screen('Flip',mainWin,0,1);

        else
            lastPos = curLocation;
        end
        lastPos = curLocation;
    end
    
    [touch,secs,keyCode] = KbCheck;
        
    if find(keyCode) == 27 %ESCAPE
        client.disconnect;
        clear all; close all; Screen('CloseAll'); 
        disp('*** Exiting Program ***');
        return;
    end
    
    if find(keyCode) == 32 %SPACE
        Screen('fillRect',mainWin,white);
        Screen('Flip',mainWin,0,1);
    end
    
end    