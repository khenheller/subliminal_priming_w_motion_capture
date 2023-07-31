function [touch_plane_info, natnetclient] = opti_setup_touch_plane_new(varargin)

%This gives an error (freezes) if the NET assembly is already loaded.  In
%that case you need to quit Matlab and start over

% if ~IsAssemblyAdded('NatNetML')  
%     Opti = NET.addAssembly('C:\Users\acelab\Documents\MATLAB\NatNetSDK\lib\x64\NatNetML.dll');
% end
% 
% client = NatNetML.NatNetClientML(1);

if length(varargin)==1
    ip = varargin{1};
else
    ip = '127.0.0.1';
end

%ask whether to collect new touch_plane_info or use saved
ButtonName = questdlg('Use custom projector setup?', ...
                     'Use custom projector setup?', ...
                     'Yes', 'No', 'Quit', 'Yes');
switch ButtonName
 case 'Yes'
    customFlag = 1;
    tableRectInfo = load('lastTableRectInfo.mat');
    tableRectInfo = tableRectInfo.tableRectInfo; 
 case 'No'
    customFlag = 0;
 case 'Quit'
    return;      
end % switch

natnetclient = natnet;

fprintf( 'Connecting to the server\n' )
natnetclient.HostIP = ip;
natnetclient.ClientIP = ip;
natnetclient.ConnectionType = 'Multicast';
natnetclient.connect;
if ( natnetclient.IsConnected == 0 )
    fprintf( 'Client failed to connect\n' )
    fprintf( '\tMake sure the host is connected to the network\n' )
    fprintf( '\tand that the host and client IP addresses are correct\n\n' ) 
    return
end

reply = 'N';
while ~strcmpi(reply,'Y')
    
    answer = {};
    while isempty(answer)        
        prompt={'Pixel Coords: '};
        name='Lower Left Corner';
        numlines=[1,35]; %this width allows for title to be seen
        if customFlag
            defaultanswer={['[' int2str(tableRectInfo.fullRect(1)) ' ' int2str(tableRectInfo.fullRect(4)) ']']};
        else
            defaultanswer={'[0 768]'};
        end
        %defaultanswer={'[0 1080]'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        %convert from string to number data for output variables
        if ~isempty(answer)
            OriginPixelCoords = str2num(answer{1});
        end
    end
    
    markers = natnetclient.getFrame.LabeledMarkers;
    pDataDest = [markers(1).x markers(1).y markers(1).z];
    
    Question = {'LOWER p.LEFT pre coordinate transform:'...
        ''...
        'Marker 1: ' num2str(pDataDest(1:3))...
        ''...
        'Accept?'...
        ''};
    ButtonName = questdlg(Question, 'Data Check', 'Yes', 'No', 'Quit', 'Yes');

    switch ButtonName
        case 'Yes'
            orig_pos = pDataDest;
            reply = 'Y';
        case 'No'
            reply = 'N';
        case 'Quit'
            %quit opto too?
            %need to pass quit flag so this actually works?
            transform_info = [];
            clear all; close all; Screen('CloseAll'); 
            disp('*** Exiting Program ***');
            return
    end

end

%take a point on +ve x axis
reply='N';
while ~strcmpi(reply,'Y')

    answer = {};
    while isempty(answer)        
        prompt={'Pixel Coords: '};
        name='Lower Right Corner';
        numlines=[1,35]; %this width allows for title to be seen
        %defaultanswer={'[1920 1080]'};
        
        if customFlag
            defaultanswer={['[' int2str(tableRectInfo.fullRect(3)) ' ' int2str(tableRectInfo.fullRect(4)) ']']};
        else
            defaultanswer={'[1024 768]'};
        end
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        %convert from string to number data for output variables
        if ~isempty(answer)
            XAxisPixelCoords = str2num(answer{1});
        end
    end


    markers = natnetclient.getFrame.LabeledMarkers;
    pDataDest = [markers(1).x markers(1).y markers(1).z];
    
    Question = {'LOWER p.RIGHT pre coordinate transform:'...
        ''...
        'Marker 1: ' num2str(pDataDest(1:3))...
        ''...
        'Accept?'...
        ''};
    ButtonName = questdlg(Question, 'Data Check', 'Yes', 'No', 'Quit', 'Yes');

    switch ButtonName
        case 'Yes'
            x_axis = pDataDest;
            reply = 'Y';
        case 'No'
            reply = 'N';
        case 'Quit'
            %quit opto too?
            %need to pass quit flag so this actually works?
            clear all; close all; Screen('CloseAll'); 
            disp('*** Exiting Program ***');
            return
    end
end

% point on the xy plane
reply='N';
while ~strcmpi(reply,'Y')

    answer = {};
    while isempty(answer)        
        prompt={'Pixel Coords: '};
        name='Upper Left Corner';
        numlines=[1,35]; %this width allows for title to be seen
        if customFlag
            defaultanswer={['[' int2str(tableRectInfo.fullRect(1)) ' ' int2str(tableRectInfo.fullRect(2)) ']']};
        else
            defaultanswer={'[0 0]'};
        end
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        %convert from string to number data for output variables
        if ~isempty(answer)
            YAxisPixelCoords = str2num(answer{1});
        end
    end

    markers = natnetclient.getFrame.LabeledMarkers;
    pDataDest = [markers(1).x markers(1).y markers(1).z];
    
    Question = {'UPPER p.LEFT pre coordinate transform:'...
        ''...
        'Marker 1: ' num2str(pDataDest(1:3))...
        ''...
        'Accept?'...
        ''};
    ButtonName = questdlg(Question, 'Data Check', 'Yes', 'No', 'Quit', 'Yes');

    switch ButtonName
        case 'Yes'
            y_axis = pDataDest;
            reply = 'Y';
        case 'No'
            reply = 'N';
        case 'Quit'
            %quit opto too?
            %need to pass quit flag so this actually works?
            clear all; close all; Screen('CloseAll'); 
            disp('*** Exiting Program ***');
            return
    end
end

% finish the screen rect (event though this is redundant for establishing
% the plane)
reply='N';
while ~strcmpi(reply,'Y')

    answer = {};
    while isempty(answer)        
        prompt={'Pixel Coords: '};
        name='Upper Right Corner';
        numlines=[1,35]; %this width allows for title to be seen
        if customFlag
            defaultanswer={['[' int2str(tableRectInfo.fullRect(3)) ' ' int2str(tableRectInfo.fullRect(2)) ']']};
        else
            defaultanswer={'[1024 0]'};
        end
        %defaultanswer={'[1920 0]'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        %convert from string to number data for output variables
        if ~isempty(answer)
            OppCornerPixelCoords = str2num(answer{1});
        end
    end

    markers = natnetclient.getFrame.LabeledMarkers;
    pDataDest = [markers(1).x markers(1).y markers(1).z];
    
    Question = {'UPPER p.RIGHT pre coordinate transform:'...
        ''...
        'Marker 1: ' num2str(pDataDest(1:3))...
        ''...
        'Accept?'...
        ''};
    ButtonName = questdlg(Question, 'Data Check', 'Yes', 'No', 'Quit', 'Yes');

    switch ButtonName
        case 'Yes'
            opp_corner = pDataDest;
            reply = 'Y';
        case 'No'
            reply = 'N';
        case 'Quit'
            %quit opto too?
            %need to pass quit flag so this actually works?
            clear all; close all; Screen('CloseAll'); 
            disp('*** Exiting Program ***');
            return
    end
end

%Create the Coordinate Systesm
[T_opto_plane,T_plane_opto]=MakeCoordSystem(orig_pos,x_axis,y_axis);

%Display the new transformed coordinate system
disp('Points in Local Coordinate System are:')
[new_orig]=transform4(T_opto_plane, orig_pos)
[new_x_axis]=transform4(T_opto_plane, x_axis)
[new_y_axis]=transform4(T_opto_plane, y_axis)
[new_opp_corner]=transform4(T_opto_plane, opp_corner)

touch_plane_info.T_opto_plane = double(T_opto_plane);
touch_plane_info.T_plane_opto = double(T_plane_opto); 
touch_plane_info.opto_rect = double([new_orig; new_x_axis; new_y_axis; new_opp_corner]);
touch_plane_info.pixel_rect = double([OriginPixelCoords; XAxisPixelCoords; YAxisPixelCoords; OppCornerPixelCoords]);
touch_plane_info.old_opto_rect = double([orig_pos; x_axis; y_axis; opp_corner]);

%calculate the pixel to opto conversion
mm1 = double((new_x_axis(1) - new_orig(1))/(XAxisPixelCoords(1) - OriginPixelCoords(1)) * 1000);
mm2 = double((new_opp_corner(1) - new_y_axis(1))/(OppCornerPixelCoords(1) - YAxisPixelCoords(1)) * 1000);
mm3 = double(-(new_orig(2) - new_y_axis(2))/(OriginPixelCoords(2) - YAxisPixelCoords(2)) * 1000);
mm4 = double(-(new_x_axis(2) - new_opp_corner(2))/(XAxisPixelCoords(2) - OppCornerPixelCoords(2)) * 1000);
touch_plane_info.mmPerPixel = mean ([mm1 mm2 mm3 mm4]);

%save to file in main Matlab folder
curDir = cd;
cd('C:\Users\cooplab\Documents\MATLAB');
save lastTouchInfo.mat touch_plane_info 
cd(curDir);

