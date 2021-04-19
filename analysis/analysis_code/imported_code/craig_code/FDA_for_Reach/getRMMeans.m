function [means,newGroup] = getRMMeans(dv,group)

%assume dv is a column vector of a single dv OR a matrix for a functional
%dv where each row is one trial and each column is a time point 
%group is a cell array containing one vector for each of you factors, coded
%for each corresponding trial in the dv.  The last grouping factor is
%assumed to be the one coding subject

%returns means: an array (or fda matrix) for each of the combinations of
%factors
%returns newGroup: the appropriate cell array that has the
%coding corresponding to the newly created means data structure

%assume subject is coded in last vector of group
subs = unique(group{end});
numSubs = length(subs);

numFactors = length(group)-1;

%build an array that stores the numLevels of each factor
factorLevels = [];
for i = 1:numFactors
    %factorLevels = [factorLevels (max(group{i})-min(group{i})+1)];
    factorLevels = [factorLevels length(unique(group{i}))]
end

curNewGroup = [];
means = [];

for s = 1:numSubs
    sub = subs(s)
	allCrossed = fullfact(factorLevels);
    subCode = ones(size(allCrossed,1),1) * sub;
    curNewGroup = [curNewGroup; allCrossed subCode];
    curMeans = [];
	%for as many permutations of all of the factors
	for i = 1:size(allCrossed,1)
        subIdx = find(group{end} == sub);
        lastIdx = subIdx;
        curCross = allCrossed(i,:);
        
        for ii = 1:numFactors
            curFactLevel = curCross(ii);
            curFactValues = unique(group{ii});
            curFactValue = curFactValues(curFactLevel);%curFactLevel+min(group{ii})-1;
            curIdx = find(group{ii}(lastIdx)==curFactValue);
            lastIdx = lastIdx(curIdx);
        end
        
        curMean = mean(dv(lastIdx,:),1);
        %curMean = mean(dv(lastIdx)); %for non-fnc data
        curMeans = [curMeans;curMean];
	end
    means = [means; curMeans];
end

newGroup = mat2cell(curNewGroup,size(curNewGroup,1),ones(1,size(curNewGroup,2)));