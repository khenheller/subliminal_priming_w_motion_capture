function  [normalizedReach, newTimes] = normalizeFDA(data,toNormalize,normalizeFrames,normalizeType,frameRate)

%data = cell array where each cell holds the x,y,z (as columns) position
%data for each IR (or tracked marker)

%toNormalize = a list of IRs (Motive motion tracking markers) that you want to normalize - this refers to
%the indexes of the data cell array

%normalizeFrames = number of frames you want for your normalized
%trajectories

%normalizeType
%1 = to time
%2 = to x distance
%3 = to y distance
%4 = to z distance

%frameRate = the frame rate of data collection

meanYdifs = [];
maxYdifs = [];

for numReachIRs = 1:length(toNormalize)
    
    %get the x,y,z components of the reach
    IR1x = data{toNormalize(numReachIRs)}(:,1);
    IR1y = data{toNormalize(numReachIRs)}(:,2);
    IR1z = data{toNormalize(numReachIRs)}(:,3);
    
    reachLength = length(IR1x);
    
    %based on the frameRate, calculate the time of each point
    time = 0:1/frameRate:(reachLength-1)/frameRate;
    
    if normalizeType == 1 %time normalization
        
        %do normalize to mvmt time FDA
        
        %do x
        [FD,missingXs,gcvs] = smoothFDA(time,IR1x,'10^-18',1,[],reachLength);
        curRange = getbasisrange(getbasis(FD));
        newTimes = curRange(1):range(curRange)/(normalizeFrames-1):curRange(2);

        newX = eval_fd(newTimes, FD, int2Lfd(0) );
        velX = [];
        velX = eval_fd(newTimes, FD, int2Lfd(1) );

        %do y
        [FD,missingXs,gcvs] = smoothFDA(time,IR1y,'10^-18',1,[],reachLength);
        
        newY = eval_fd(newTimes, FD, int2Lfd(0) );
        velY = [];
        velY = eval_fd(newTimes, FD, int2Lfd(1) );
        
        %do z
        [FD,missingXs,gcvs] = smoothFDA(time,IR1z,'10^-18',1,[],reachLength);
        curRange = getbasisrange(getbasis(FD));

        newZ = eval_fd(newTimes, FD, int2Lfd(0) );
        velZ = [];
        velZ = eval_fd(newTimes, FD, int2Lfd(1) );
       
    else %we are doing spatial normalization
        
        %determine which dimension we are normalizing to
        switch normalizeType
            case 2 % x-distance normalization
                normalizeTo = IR1x;
            case 3 % y-distance
                normalizeTo = IR1y;
            case 4 % z-distance
                normalizeTo = IR1z;
        end
    
    
        %STEP 1: Fit basis functions (i.e. create functional data object) 
        %to the component of the trajectory that you are going to normalize to.
        [FD,missingXs,gcvs] = smoothFDA(time,normalizeTo,'10^-18',1,[],reachLength);

        %STEP 2: From that newly defined functional data object (FD) get a high
        %resolution representation of that curve.  Now that it is
        %mathematically defined, you can use any scale you want.  I have
        %arbitrarily chosen 10x the frameRate.  The higher the resolution, 
        %the more precisely you'll be able to extract points that exactly
        %correspond to percentages of whatever distance you are normalizing to.
        %If the multiplier of frameRate doesn't work, then just hard code this
        %in (I've used 2000 for quite a few studies collected at 100-200hz)
        highResPoints = frameRate*10;
        curRange = getbasisrange(getbasis(FD));
        newNormalizeToData = evalFDA(FD,highResPoints,curRange);

        %STEP 3: From the new normalized trajectory, we want to find the points
        %in TIME that correspond to equal points in distance.
        %Since it is possible that the position of the trajectory you are normalizing to 
        %could go backwards (which messes up the calculation of the times below)
        %we need to evaluate each same-direction chuck of of the newNormal
        %trajectory separately.  Note, the new FD object has fields for POS and
        %VEL and ACC (i.e. derivatives of POS) created from analyzing the
        %mathematical curve.

        %first identify find if there are any crossings in vel which means
        %you went backward - this code snippet was borrowed from a
        %zero-crossing script I found online
        sig = newNormalizeToData.VEL;
        thresh = 0; %crossing threshold
        N = length(sig);
        zc = (sig >= thresh) - (sig < thresh);
        idx = find((zc(1:N-1) - zc(2:N)) ~= 0);
        idxPrcnt = idx/highResPoints;
        idxVal = newNormalizeToData.POS(idx);

        idx(2:end+1) = idx;
        idxVal(2:end+1) = idxVal;
        idxPrcnt(2:end+1) = idxPrcnt;

        idx(1) = 1;
        idxVal(1) = newNormalizeToData.POS(1);
        idxPrcnt(1) = 0;

        if idx(end) ~= highResPoints
            idx(end+1) = highResPoints;
            idxVal(end+1) = newNormalizeToData.POS(end);
            idxPrcnt(end+1) = 1;
        end

        idxPrcntDif = idxPrcnt(2:end)-idxPrcnt(1:end-1);

        normalizedTimes = [];
        vals = [];

        for i = 1:length(idx)-1
            newDataRange = [idxVal(i) idxVal(i+1)];
            curPrcnt = idxPrcnt(i+1)-idxPrcnt(i);

            if i~=1
                curNumPoints = ceil(idxPrcntDif(i)*normalizeFrames)+1;
            else
                curNumPoints = ceil(idxPrcntDif(i)*normalizeFrames);
            end


            if curNumPoints > 0 & length(normalizedTimes)<normalizeFrames 


                if curNumPoints == 1
                    newDataSteps = newDataRange;
                else
                    newDataSteps = newDataRange(1):(newDataRange(2)-newDataRange(1))/(curNumPoints-1):newDataRange(2);
                end

                if i ~= 1
                    newDataSteps = newDataSteps(2:end);
                end

                newDataPos = newNormalizeToData.POS(idx(i):idx(i+1));

                for ii = 1:length(newDataSteps)
                    if length(normalizedTimes) == normalizeFrames
                        break
                    end
                    [val,curTime] = min(abs(newDataPos - newDataSteps(ii)));
                    normalizedTimes(end+1) = curTime(1) + idx(i) - 1;
                    vals(end+1) = val;
                end
            end

        end

        %If you want, you can check to see how well your extracted time points
        %actually fit the data.  Since you are unlikely to actually have a data
        %point at exactly 1/normalizedFrames of a movement the vals array above tells you how close
        %there was an ACTUAL data point in the newNormalizedToData.  You can
        %use the variable below to set some threshold for acceptable difference 
        %between where you are pulling the times from and the actual data at 
        %that point.  I've used these more to figure out what I should set my
        %highResPoints variable at, then stuck with something that works.
        meanYdifs = mean(vals);
        maxYdifs = max(vals);


        %STEP 4: Use the new time array (which represents the times at which
        %you moved 1/normalizeFrames along the normalizeTo trajectory) to
        %define your new normalized data in all dimensions
        newTimes = newNormalizeToData.TIME(normalizedTimes);

        switch normalizeType
            case 2 % x-distance normalization
                %as a check, if you plot the new POS at normalizedTimes, it
                %should give a straight line, since we are sampling at equal
                %distances along thins new normalized trajectory
                newX = newNormalizeToData.POS(normalizedTimes)';
                velX = [];
                velX = newNormalizeToData.VEL(normalizedTimes)';

                %do y
                [FD,missingXs,gcvs] = smoothFDA(time,IR1y,'10^-18',1,[],reachLength);
                curRange = getbasisrange(getbasis(FD));

                newY = eval_fd(newTimes, FD, int2Lfd(0) );
                velY = [];
                velY = eval_fd(newTimes, FD, int2Lfd(1) );

                %do z
                [FD,missingXs,gcvs] = smoothFDA(time,IR1z,'10^-18',1,[],reachLength);
                curRange = getbasisrange(getbasis(FD));

                newZ = eval_fd(newTimes, FD, int2Lfd(0) );
                velZ = [];
                velZ = eval_fd(newTimes, FD, int2Lfd(1) );

            case 3 % y-distance
                newY = newNormalizeToData.POS(normalizedTimes)';
                velY = [];
                velY = newNormalizeToData.VEL(normalizedTimes)';

                %do x
                [FD,missingXs,gcvs] = smoothFDA(time,IR1x,'10^-18',1,[],reachLength);
                curRange = getbasisrange(getbasis(FD));

                newX = eval_fd(newTimes, FD, int2Lfd(0) );
                velX = [];
                velX = eval_fd(newTimes, FD, int2Lfd(1) );

                %do z
                [FD,missingXs,gcvs] = smoothFDA(time,IR1z,'10^-18',1,[],reachLength);
                curRange = getbasisrange(getbasis(FD));

                newZ = eval_fd(newTimes, FD, int2Lfd(0) );
                velZ = [];
                velZ = eval_fd(newTimes, FD, int2Lfd(1) );

            case 4 % z-distance
                newZ = newNormalizeToData.POS(normalizedTimes)';
                velZ = [];
                velZ = newNormalizeToData.VEL(normalizedTimes)';

                %do x
                [FD,missingXs,gcvs] = smoothFDA(time,IR1x,'10^-18',1,[],reachLength);
                curRange = getbasisrange(getbasis(FD));

                newX = eval_fd(newTimes, FD, int2Lfd(0) );
                velX = [];
                velX = eval_fd(newTimes, FD, int2Lfd(1) );

                %do y
                [FD,missingXs,gcvs] = smoothFDA(time,IR1y,'10^-18',1,[],reachLength);
                curRange = getbasisrange(getbasis(FD));

                newY = eval_fd(newTimes, FD, int2Lfd(0) );
                velY = [];
                velY = eval_fd(newTimes, FD, int2Lfd(1) );
        end
    end


    normalizedReach{numReachIRs} = [newX newY newZ velX velY velZ];

end

 


        
        