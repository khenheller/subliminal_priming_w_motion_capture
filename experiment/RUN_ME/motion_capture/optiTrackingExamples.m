%SETUP OPTITRAK
%ask whether to collect new touch_plane_info or use saved
ButtonName = questdlg('Perform calibraion?', ...
                     'New Calibration or load', ...
                     'New Calibration', 'Load Calibration', 'Quit', 'New Calibration');
switch ButtonName,
 case 'New Calibration',
    [touch_plane_info, client] = opti_setup_touch_plane_new('142.244.234.122');    
 case 'Load Calibration',
    [touch_plane_info, client] = use_last_touch_plane('142.244.234.122');
 case 'Quit',
    client.Uninitialize;
    Screen('closeAll');
    return;      
end % switch

%data = client.GetLastFrameOfData;
%markers = data.OtherMarkers;
markers = client.getFrame.LabeledMarker;
transform_info = touch_plane_info;
distToTouch = -15/1000; 
T_glob_loc = touch_plane_info.T_opto_plane;
mmPerPixel = touch_plane_info.mmPerPixel;


%EXAMPLE 1 of how to get a fixed position for referencing later in the
%experiment (e.g. in this case, a start position that they come back to
%each trial)

%get info about the start position - participants will have to be within
%5cm of this point to start the first trial
reply='N';
while ~strcmpi(reply,'Y')

    uiwait(msgbox('Press OK to collect initial start pos data','Collect?','modal'));
    
    pDataDest = [markers(1).x markers(1).z markers(1).y];

    [new_startPos]=transform4(T_glob_loc, pDataDest(1:3));

    Question = {'Start pos data:'...
        ''...
        'Marker 1: ' num2str(new_startPos)...
        ''...
        'Accept?'...
        ''};
    ButtonName = questdlg(Question, 'Start Pos Check', 'Yes', 'No', 'Quit', 'Yes');

    switch ButtonName
        case 'Yes'
            reply = 'Y';
            startPos = new_startPos;
        case 'No'
            reply = 'N';
        case 'Quit'
            client.Uninitialize;
            clear all; close all; Screen('CloseAll'); 
            disp('*** Exiting Program ***');
            return
    end
end
matData.startPos{1} = startPos;


%EXAMPLE 2 - looking for the marker to be within range of the start position
%wait for IR1 to be within startPos range
inRange = 0.02; %say 20mm in 3D distance is within range
inRangeFlag = 0;
while ~inRangeFlag

    curLocation = [markers(1).x markers(1).z markers(1).y];
    curLocation=transform4(T_glob_loc, curLocation);
    curRange = sqrt(sum((curLocation-matData.startPos{1}).^2));

    if curRange < inRange
        inRangeFlag = 1;
    end

    %slows it down and refreshes Screen (prevent blanking?)
    Screen('Flip',mainWin,0,1);

    [touch,secs,keyCode] = KbCheck;

    if find(keyCode) == 27 %ESCAPE
        client.Uninitialize;
        clear all; close all; Screen('CloseAll'); 
        disp('*** Exiting Program ***');
        return
    end
end

%EXAMPLE 3 - how we start recording data (here, using the monitor flips to
%maintain 60Hz sampling)

%start recording optitrak (always with beep?)
%initialize first
optiRaw = [];
optiTime = [];
optiCtr = 0;
optiStartTime = GetSecs;
optiCtr = optiCtr+1;
optiRaw(optiCtr,:) = [markers(1).x markers(1).z markers(1).y];
optiTime(optiCtr) = GetSecs-optiStartTime;

Screen('Flip',mainWin,0,1);

%basically after every Screen flip, we record a new hand position -
%this should mean we get trajectory data at approx the frameRate
optiCtr = optiCtr+1;
optiRaw(optiCtr,:) = [markers(1).x markers(1).z markers(1).y];      
optiTime(optiCtr) = GetSecs-optiStartTime;


%EXAMPLE 4 - Looking in real time for velocity onset while also recording
%data...note this first bit is also looking for a displacement signal as
%indicative that they left too early

%replicating detectVelOnset code here so as to avoid having to
%track raw opti data in a new functions.  ALSO this allows us to
%insert cue onset at the different delays
velOnsetFlag = 0;

posVector = nan(3,4); %using 3d velocity over 4 time points to define reach onset
position = nan(1,3); %initialize position in case of error


curLocation=optiRaw(optiCtr,:); %get most recent opti position
curLocation=transform4(T_glob_loc, curLocation); %transform to our coordinate frame

curRange = sqrt(sum((curLocation-startPos).^2));

if curRange > inRange+0.01 %if they are outside of 2cm from startPos indicate that they went tooEarly (determined by position only)
    tooEarlyFlag = 1;
end


while GetSecs-targetOnTime<rxnTimeLimit & ~velOnsetFlag & ~tooEarlyFlag

    curLocation=optiRaw(optiCtr,:); %get most recent opti position
    curLocation=transform4(T_glob_loc, curLocation); %transform to our coordinate frame

    posVector(:,1:3) = posVector(:,2:4);
    posVector(:,4) = curLocation';

    velVector = gradient(posVector)/(1/frameRate);
    tangVelVector = sqrt(velVector(1,:).^2+velVector(2,:).^2+velVector(3,:).^2);

    %once you have 4 pts
    if ~any(isnan(tangVelVector))

        if tangVelVector(4) > 0.05 & tangVelVector(4)-tangVelVector(1) > 0.05 

            velOnsetFlag = 1;
            position = curLocation;

            optiCtr = optiCtr+1;
            optiRaw(optiCtr,:) = [markers(1).x markers(1).z markers(1).y];
            optiTime(optiCtr) = GetSecs-optiStartTime;

            break

        end
    end

    Screen('Flip',mainWin,0,1); %flip to preserve approximate opti collection frequency and refresh
    optiCtr = optiCtr+1;
    optiRaw(optiCtr,:) = [markers(1).x markers(1).z markers(1).y];
    optiTime(optiCtr) = GetSecs-optiStartTime;
end

reachOnset = GetSecs;
reachStartedFlag = velOnsetFlag;
reachOnsetPos = position;
reachOnsetFrame = optiCtr;

%EXAMPLE 5 waiting for a touch 
%now we will wait for one of the objects to be touched
touchTime = GetSecs;
touchFlag = 0;
touchFrame = 0;
selectedBox = 0;
tooSlowFlag = 0;
endPos = [0 0];
endPix = [0 0];
LHit = 0;
RHit = 0;
curLDist = 0;
curRDist = 0;
drawEndCol = [255 0 0]; %red for miss

while ~touchFlag & ~tooEarlyFlag & velOnsetFlag

    if GetSecs - reachOnset > mvmtTimeLimit
        tooSlowFlag = 1;
        %break;
    end

    curLocation = [markers(1).x markers(1).z markers(1).y];
    curLocation=transform4(touch_plane_info.T_opto_plane, curLocation);
    curLocPix = double(round(curLocation/mmPerPixel*1000));
    curLocPix(2) = mainRect(4)-curLocPix(2);

    %if they are close enough to be called a touch record where they
    %hit
    if curLocation(3) > distToTouch 

        touchFlag = 1;
        touchTime = GetSecs;
        touchFrame = optiCtr;
        endPos = curLocation(1:2);
        endPix = curLocPix(1:2);

        %check if we are within left
        curLDist = sqrt( (curLocPix(1)-posStruct.LhexCentX)^2 + (curLocPix(2)-posStruct.LhexCentY)^2 );
        curRDist = sqrt( (curLocPix(1)-posStruct.RhexCentX)^2 + (curLocPix(2)-posStruct.RhexCentY)^2 );

        drawEndCol = [255 0 0]; %red for miss

        if curLDist < curSizeLeft %HIT L
            LHit = 1;
            drawEndCol = [0 255 0]; %green for hit
            pointsMultiplier = curTargLeft;
        end

        if curRDist < curSizeRight %HIT R
            RHit = 1;
            drawEndCol = [0 255 0]; %green for hit
            pointsMultiplier = curTargRight;
        end

    end

    %update Screen, record hand position
    Screen('Flip',mainWin,0,1);
    optiCtr = optiCtr+1;
    optiRaw(optiCtr,:) = [markers(1).x markers(1).z markers(1).y];
    optiTime(optiCtr) = GetSecs-optiStartTime;          


end