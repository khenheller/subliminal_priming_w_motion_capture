clc
clear all
close all
%addpath([path, '\beeswarm_plot']);
% data:
data = {[randn(1,10)],[randn(1,10)]};
% plot colors:
c1 = [0 1 0];
c2 = [0 0 1];
% plot:
figure()
i = get(gcf,'Number');
h = plotSpread(data,'xNames', {'Dataset 1','Dataset 2'},'distributionMarkers', {'o', 'o'},'categoryColors',{'r','b'},'spreadWidth',4,'xMode','manual','xValues',[1 4])%, 'showMM', 4)
set(h{1,1}(1,1),'color','g','MarkerFaceColor',c1,'MarkerEdgeColor','k');
hold on
set(findall(i,'type','line','color','b'),'MarkerFaceColor',c1, 'MarkerEdgeColor','k', 'markersize', 8)
set(findall(i,'type','line','color','g'),'MarkerFaceColor',c2, 'MarkerEdgeColor','k', 'markersize', 8)
plot([0 2],[nanmean(data{1,1},2) nanmean(data{1,1},2)],'Color',[0,0,0],'markersize', 18,'LineWidth',1.5)
plot([3 5],[nanmean(data{1,2},2) nanmean(data{1,2},2)],'Color',[0,0,0],'markersize', 18,'LineWidth',1.5)
ax = gca; % current axes
ax.XTick = [1 4];
ax = gca; % current axes
ax.XAxis.FontSize = 16; 
ay = gca; % current axes
ay.YAxis.FontSize = 16; 
set(gcf,'color','w');
% statistical analysis:
[h,p,ci,stats] = ttest2(data{1,1},data{1,2},'Vartype','unequal')

