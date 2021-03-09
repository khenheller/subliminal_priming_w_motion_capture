% Convert NatNet data to format Matlab can save to file.
% notice: since I can't seem to find a way to get the count of
%       rigid bodies or markers in the frame, we'll have to change
%       the size of the struct dynamically. Optimally, we'll have a
%       natNetObj.numRigidBodies property to rely on.
function outStruct = exportNatNetObjDataAsStruct()
    global p.NATNETCLIENT

    outStruct.frameNum = -1; % This as a default value

    % Iterate over all rigid bodies in the frame:
    outStruct.RB = {};
    iRigidBody = 1;
    currBody = p.NATNETCLIENT.RigidBody(iRigidBody);
    while(~isempty(currBody))
        RBstruct.x = currBody.x;
        RBstruct.y = currBody.y;
        RBstruct.z = currBody.z;
        outStruct.RB{iRigidBody} = RBstruct;

        iRigidBody = iRigidBody+1;
        currBody = p.NATNETCLIENT.RigidBody(iRigidBody);
    end

    % Iterate over all the markers in the frame:
    outStruct.Ms = {};
    iMarker = 1;
    currMarker = p.NATNETCLIENT.LabeledMarker(iMarker);
    while(~isempty(currMarker))
        Mstruct.x = currMarker.x;
        Mstruct.y = currMarker.y;
        Mstruct.z = currMarker.z;
        outStruct.Ms{iMarker} = Mstruct ;

        iMarker = iMarker+1;
        currMarker = p.NATNETCLIENT.LabeledMarker(iMarker);
    end
end