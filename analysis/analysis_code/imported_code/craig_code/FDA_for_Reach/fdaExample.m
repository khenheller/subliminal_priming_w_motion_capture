%script showing how to use the fanovan function to run functional ANOVAs

%the sample data comes from a recent experiment we conducted (Chapman,
%Gallivan et al, Cognition 116 (2): 168-176) where particpants perform a
%rapid reach toward a single target OR toward two targets. With two
%targets, the final target position is selected only AFTER movement onset.
load sampleFDAData

%the loaded variables are fdaMat and group.  fdaMat is a struct with fields
%x, y and z containing the normalized (to y-distance) reach trajectories in
%the three cardinal dimensions.  Each row within one component of the
%struct (e.g. fdaMat.x) represents the normalized trajectory from one
%trial.  The "n"th column represents the position (e.g. x position) of the
%movement at the n/200 percentage of y movement.
%
%group is a cell array containing your grouping factors (or independant
%variables).  In this example there are two grouping factors the first
%(contained in group{1}) is condition (of which there was 16)and the second
%(contained in group{2} is subject (of which this sample includes 4).  NOTE
%the code used below AlWAYS assumes that subject is coded in the FINAl
%grouping factor.  SO, if you had 3 indendent variables then the code for
%subject would be in group{4}.

%STEP 1
%identify the trials that you want to analyze.  In this case, we want to
%compare trials where there was only one target in the top left
%(condition 13) or top right (condition 14) to trials where there were two
%targets and the one in the top left (condition 1) or top right (condition
%2) was cued.

%get the index of the trials that match what you want
idx = find(group{1}==1 | group{1}==2 | group{1}==13 |group{1}==14); % He only wants to compare these 4 conditions.

%STEP 2
%for the dimesion along which you want to make a comparison, for repeated
%measures, you need to get each subjects mean for each condition of
%interest.  
%
%to get the repeated measures mean, use the included function getrmmeans,
%which takes data and grouping factors as input (NOTE again this function
%assumes the final grouping factor (or group{end}) will code subject) and
%returns a new data matrix and grouping variable corresponding the mean
%data.  For this example, we will look at the x-dimension for our 4
%subjects across the above mentioned 4 conditions.  Thus, we expect to get
%a total of 16 means (4 subs, 4 conditions each)
[meansx,newGroupx] = getRMMeans(fdaMat.x(idx,:),{group{1}(idx) group{2}(idx)});

%STEP 3
%run fanova
%for running repeated measures, you pass the output of the getrmmeans
%function (note it has renumbered your conditions, but that doesn't
%matter).  You specify that you want the full model (all main effects and
%interactions) that the second grouping factor is random (your subjects
%factor is random, making this a repeated measures design) and then you can
%assign names to your grouping factors
%
%This returns a pvalue over time, a corrected pvalue over time (greenhouse
%geisser corrected) the disabled (and thus useless) ANOVA table and statx,
%a struct containing many different variables
[px,corrPx,tx,statsx] = fanovan(meansx, newGroupx, 'model','full', 'random',length(newGroupx),'varnames',{'condition' 'subject'});

%STEP 4
%you can plot the corrected pvalue over the function of x (in this case
%over percent y distance, divided into 200 slices).  Add in a line at a
%conventional alpha (0.05). lable the axis, put units into something more
%identifiable (i.e percent from 0-100, not 0-200...do this by changing the 
% x argument to the plot command)
plot((1:200)/2,corrPx(1,:),'linewidth',2);
line([0 100],[0.05 0.05],'color','r','linewidth',2);
ylim([0 1]);
xlabel('Percent Y Distance');
ylabel('p-value of X deviation');
title('Overall ANOVA, top l and R');

%STEP 5 (which really just repeats steps 1-4)
%for doing follow ups, you can just define a new index, identifying only
%the 2 conditions you want, then proceed with the same steps as above

%index of the two two-target conditions only
idx = find(group{1}==1 | group{1}==2);

%get the means for only those two groups
[meansx,newGroupx] = getRMMeans(fdaMat.x(idx,:),{group{1}(idx) group{2}(idx)});

%run the ANOVA (an ANOVA with 2 levels is equivalent to a t-test)
[px,corrPx,tx,statsx] = fanovan(meansx, newGroupx, 'model','full', 'random',2,'varnames',{'condition' 'subject'});

%plot the results
figure;
plot((1:200)/2,corrPx(1,:),'linewidth',2);
line([0 100],[0.05 0.05],'color','r','linewidth',2);
ylim([0 1]);
xlabel('Percent Y Distance');
ylabel('p-value of X deviation');
title('Follow up ANOVA 2-target l vs 2-target R');


%compare that against the follow up comparing a two-target trial that ended
%left versus a single target trial to the left
%index of the two two-target conditions only
idx = find(group{1}==1 | group{1}==13);

%get the means for only those two groups
[meansx,newGroupx] = getRMMeans(fdaMat.x(idx,:),{group{1}(idx) group{2}(idx)});

%run the ANOVA (an ANOVA with 2 levels is equivalent to a t-test)
[px,corrPx,tx,statsx] = fanovan(meansx, newGroupx, 'model','full', 'random',2,'varnames',{'condition' 'subject'});

%plot the results
figure;
plot((1:200)/2,corrPx(1,:),'linewidth',2);
line([0 100],[0.05 0.05],'color','r','linewidth',2);
ylim([0 1]);
xlabel('Percent Y Distance');
ylabel('p-value of X deviation');
title('Follow up ANOVA 1-target l vs 2-target l');


%to plot the actual trajectories, you can use the same logic as above.
%Remember that with repeated measures there will be a difference between
%plotting the grand average in a condition versus plotting the average of
%subject averages in each condition.  The average of averages is the
%appropriate plot for repeated measures statistics (since this is what is
%actually being compared.  Here these two different plots are almost
%identical, but if the number of trials being contributed by each subject
%differs in a given condition, the difference between these two plot types
%will be magnified
%
%to plot the grand average:

%get the appropriate indexes for each condition
idx1topl = find(group{1}==13); %this will be green
idx1topR = find(group{1}==14); %this will be black
idx2topl = find(group{1}==1); %this will be blue
idx2topR = find(group{1}==2); %this will be red

%plot in 3D - add in labels and titles
figure; hold on;
plot3(mean(fdaMat.x(idx1topl,:)),mean(fdaMat.y(idx1topl,:)),mean(fdaMat.z(idx1topl,:)),'g','linewidth',2);
plot3(mean(fdaMat.x(idx1topR,:)),mean(fdaMat.y(idx1topl,:)),mean(fdaMat.z(idx1topl,:)),'k','linewidth',2);
plot3(mean(fdaMat.x(idx2topl,:)),mean(fdaMat.y(idx1topl,:)),mean(fdaMat.z(idx1topl,:)),'b','linewidth',2);
plot3(mean(fdaMat.x(idx2topR,:)),mean(fdaMat.y(idx1topl,:)),mean(fdaMat.z(idx1topl,:)),'r','linewidth',2);
view(3);
title('Grand mean average trajectories top l and R')
xlabel('lateral deviation');
ylabel('Reach distance');
zlabel('Reach height');


%to plot the average of subject averages:

%get subject averages (as above when doing FANOVA) but do so for each
%dimension.  Note all the newGroup will be identical
idx = find(group{1}==1 | group{1}==2 | group{1}==13 |group{1}==14);
[meansx,newGroupx] = getRMMeans(fdaMat.x(idx,:),{group{1}(idx) group{2}(idx)});
[meansy,newGroupy] = getRMMeans(fdaMat.y(idx,:),{group{1}(idx) group{2}(idx)});
[meansz,newGroupz] = getRMMeans(fdaMat.z(idx,:),{group{1}(idx) group{2}(idx)});

%get the appropriate indexes for each condition.  Recall that the
%getRMMeans function renumbers your conditions (assings 1 through the
%number of unique conditions, in this case 4)
idx1topl = find(newGroupx{1}==3); %this will be green
idx1topR = find(newGroupx{1}==4); %this will be black
idx2topl = find(newGroupx{1}==1); %this will be blue
idx2topR = find(newGroupx{1}==2); %this will be red

%plot in 3D - add in labels and titles
figure; hold on;
plot3(mean(meansx(idx1topl,:)),mean(meansy(idx1topl,:)),mean(meansz(idx1topl,:)),'g','linewidth',2);
plot3(mean(meansx(idx1topR,:)),mean(meansy(idx1topl,:)),mean(meansz(idx1topl,:)),'k','linewidth',2);
plot3(mean(meansx(idx2topl,:)),mean(meansy(idx1topl,:)),mean(meansz(idx1topl,:)),'b','linewidth',2);
plot3(mean(meansx(idx2topR,:)),mean(meansy(idx1topl,:)),mean(meansz(idx1topl,:)),'r','linewidth',2);

view(3);
title('Average of subject average trajectories top l and R')
xlabel('lateral deviation');
ylabel('Reach distance');
zlabel('Reach height');

