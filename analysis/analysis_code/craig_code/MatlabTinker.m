%Scripts, debugging
a=1:10;
for i = 1:length(a)+1
	a(i)
end

%MatLab - Matrix Laboratory
load('sampleFDAData.mat')

%Structs. (dot operator)
help struct

allData.fdaMat = fdaMat;
allData.group = group;
allData.rxnTime = rxnTime;

%{Cell array} (curly brackets)
testCell{1} = 'This is a string'
testCell{2} = 5
testCell{3} = person
testCell{4} = rxnTime

%[Matrix] (square brackets)
a=[1 2 3];
b=[4 8 248];
c=[1 2 3; 4 5 6];
d=[4 5 6; 8 9];

e=[a b]
f = [a;b]

    %Compare:
a=['hi']
a(1)
b={'hi'}
b{1}

%The colon operator (:)
a=1:10

a=1:2:10

a=10:-1:0

%Other Matrix making functions
linspace(1,10,10)
    % 	-help
    % 	-doc

m=10;n=10;int=3;
nan(m,n)
zeros(m,n)
ones(m,n)
ones(m,n)*int

help repmat

%Indexing – into a vector
rxnTime(1)

rxnTime(2)

rxnTime(1:10)

rxnTime(end)

%Indexing into a 2D matrix
fdaMat.x(1,10)

fdaMat.x(10,1)

fdaMat.x(:,1)

fdaMat.x(1,:)

fdaMat.x(:,end)

scatter(fdaMat.x(:,end),fdaMat.y(:,end))

%“find”ing yourself
hist(rxnTime)

    %…want to remove everything less than 200 ms (0.2)

fastTrials = find(rxnTime<0.2)
rxnTime(fastTrials) = [];


    %reload rxnTime
clear rxnTime
load('sampleFDAData.mat')


    %…want to remove everything less than 200 ms (0.2) and everything greater than 400 ms (0.4)

badTrials = find(rxnTime<0.2 | rxnTime>0.4)
rxnTime(badTrials) = [];

    %Logical operators: &, |, ~, 

    %reload rxnTime
clear rxnTime
load('sampleFDAData.mat')
    
%Find with functional data
group{1} %(conditions)
group{2} %(subject number)

unique(group{1})

help unique %(look at related functions)

    %All subject 1 trials
sub1=find(group{end}==1)
plot(fdaMat.x(sub1,:)',fdaMat.y(sub1,:)')

    %All condition 1 trials
cond1=find(group{1}==1)
plot(fdaMat.x(cond1,:)',fdaMat.y(cond1,:)')

    %All subject 1 trials, condition 1 trials
sub1c1=find(group{1}==1 & group{end}==1)

plot(fdaMat.x(sub1c1,:)',fdaMat.y(sub1c1,:)')

plot(mean(fdaMat.x(sub1c1,:)),mean(fdaMat.y(sub1c1,:)))

%Between subjects
help ttest

help ttest2

cond1=find(group{1}==1);
cond13=find(group{1}==13);
ttest2(rxnTime(cond1),rxnTime(cond13))

[H,P,CI,STATS] = ttest2(rxnTime(cond1),rxnTime(cond13))

mean(rxnTime(cond1))
mean(rxnTime(cond13))

    %…and what tool do we use to look for differences between more than two groups?

help anova
    %…maybe right, but today we’ll use anovan
help anovan

idx = find(group{1}==1 | group{1}==2 | group{1}==13 |group{1}==14);

anovan(rxnTime(idx),{group{1}(idx)})

[P,T,STATS,TERMS] = anovan(rxnTime(idx),{group{1}(idx)})

multcompare(STATS)

%Repeated measures
    %What type of data does a repeated measures design (anova) want?

    %…subject averages

edit getRMMeans

    %*edit is a great command for seeing how ANY function is producing its result

idx = find(group{1}==1 | group{1}==2 | group{1}==13 |group{1}==14);

[meansRT,newGroupRT] = getRMMeans(rxnTime(idx),{group{1}(idx) group{2}(idx)});

%Repeated measures (t-test)
matMeansRT = reshape(meansRT,4,4)'

[h,p,ci,stats] = ttest(matMeansRT(:,1),matMeansRT(:,3))

meanDif = matMeansRT(:,1)-matMeansRT(:,3)

[h,p,ci,stats] = ttest(meanDif)

%Repeated measures (anova)
anovan(meansRT, newGroupRT, 'model','full', 'random',length(newGroupRT),'varnames',{'condition' 'subject'})

%Repeated measures (funcitonal data)
[meansx,newGroupx] = getRMMeans(fdaMat.x(idx,:),{group{1}(idx) group{2}(idx)});

[meansy,newGroupy] = getRMMeans(fdaMat.y(idx,:),{group{1}(idx) group{2}(idx)});

%Repeated measures (funcitonal data) t-test
c1 = find(newGroupx{1}==1)
c3 = find(newGroupx{1}==3)
meanDifx=mean(meansx(c1,:)-meansx(c3,:))
stdDifx=std(meansx(c1,:)-meansx(c3,:))
numSubs = 4
difCI = tinv(0.975,(numSubs-1))*stdDifx/sqrt(numSubs)
plot(meanDifx)
hold on
plot(meanDifx + difCI)
plot(meanDifx - difCI)

%Repeated measures (functional data) anova (fanovan)
[px,corrPx,tx,statsx] = fanovan(meansx, newGroupx, 'model','full', 'random',length(newGroupx),'varnames',{'condition' 'subject'});
    %fanovan available from my website
plot((1:200)/2,corrPx(1,:),'linewidth',2);
line([0 100],[0.05 0.05],'color','r','linewidth',2);
ylim([0 1]);
xlabel('Percent Y Distance');
ylabel('p-value of X deviation');
title('Overall ANOVA, top L and R');

%Visualizing
figHandle = figure

get(figHandle)
set(figHandle)

plotHandle = plot(1:10)
hold on
plotHandle2 = plot(10:-1:1)

    %Click on figure element
gco

close all

bar(matMeansRT)
	%-grouped vs stacked, colormap (custom)
bar(mean(matMeansRT))

    %enables individual bar colors
for i = 1:size(matMeansRT,2)
	bar(i,mean(matMeansRT(:,i)))
	hold on
end

difCI = tinv(0.975,(4-1))*std(matMeansRT)/sqrt(4)
errorbar(1:4,mean(matMeansRT),difCI)

scatter(fdaMat.x(:,end),rxnTime)

    %Use tools basic fitting

uistack(gco,'bottom')

    %File generate code

%Visualizing 2D trajectories
plot(fdaMat.x(cond1,:)',fdaMat.y(cond1,:)','k');
hold on;
plot(mean(fdaMat.x(cond1,:))',mean(fdaMat.y(cond1,:))','r')
	%-discuss colors
plot(fdaMat.x(cond1,:)',fdaMat.y(cond1,:)','linewidth',2,'color',[0.8 0.8 0.8]);
hold on;
plot(mean(fdaMat.x(cond1,:))',mean(fdaMat.y(cond1,:))','linewidth',10,'color',[1 0 0])
	
xlim([-110 110])
ylim([-40 400])
axis square

    %-axis scaling (equal, data aspect ratio, plot box aspect ratio)

%Visualzing areas
    %repeated from before
c1 = find(newGroupx{1}==1)
c3 = find(newGroupx{1}==3)
meanDifx=mean(meansx(c1,:)-meansx(c3,:))
stdDifx=std(meansx(c1,:)-meansx(c3,:))
numSubs = 4
difCI = tinv(0.975,(numSubs-1))*stdDifx/sqrt(numSubs)

figure; hold on;
mmeansy = mean(meansy);
for ii = 1:length(meanDifx)-1
    fillHandle = fill([mmeansy(ii) mmeansy(ii) mmeansy(ii+1) mmeansy(ii+1)],[meanDifx(ii)+difCI(ii) meanDifx(ii)-difCI(ii) meanDifx(ii+1)-difCI(ii+1) meanDifx(ii+1)+difCI(ii+1)],[1 0.5 0.5]);                                
    set(fillHandle,'FaceAlpha',0.5);
    set(fillHandle,'lineStyle','none');
end

plot(mmeansy, meanDifx,'r')
plot(mmeansy, meanDifx + difCI,'r--')
plot(mmeansy, meanDifx - difCI,'r--')

    %calculate a new difference
c2 = find(newGroupx{1}==2)
c4 = find(newGroupx{1}==4)
meanDifx=mean(meansx(c2,:)-meansx(c4,:))
stdDifx=std(meansx(c2,:)-meansx(c4,:))
numSubs = 4
difCI = tinv(0.975,(numSubs-1))*stdDifx/sqrt(numSubs)

for ii = 1:length(meanDifx)-1
    fillHandle = fill([mmeansy(ii) mmeansy(ii) mmeansy(ii+1) mmeansy(ii+1)],[meanDifx(ii)+difCI(ii) meanDifx(ii)-difCI(ii) meanDifx(ii+1)-difCI(ii+1) meanDifx(ii+1)+difCI(ii+1)],[0.5 0.5 1]);                                
    set(fillHandle,'FaceAlpha',0.5);
    set(fillHandle,'lineStyle','none');
end

plot(mmeansy, meanDifx,'b')
plot(mmeansy, meanDifx + difCI,'b--')
plot(mmeansy, meanDifx - difCI,'b--')

line([0 400],[0 0])

%Visualizing 3D
plot3(mean(fdaMat.x(cond1,:))',mean(fdaMat.y(cond1,:))', mean(fdaMat.z(cond1,:))', 'linewidth',10,'color',[1 0 0])
view(2)
view(3)
view([0,0])
view([90,0])
view([0,90])
view(3);view %returns position matrix
	%-discuss grid, box
drawTableAndScreen

%Useful functions
% fliplr / flipud
% sort
% cftool
% corr
% corrcoeff
% subplot
% colormapeditor
% ellipsoid

%Matlab file exchange
	%-export_fig, inpaint_nans



