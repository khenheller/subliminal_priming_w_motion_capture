hold on;

set(gca,'xLim',[-110 110])
set(gca,'yLim',[-20 420])
set(gca,'zLim',[-20 420])

%make a table with no color (could be black etc)
patch([-100 100 100 -100]',[-10 -10 400 400]',[0 0 0 0]','FaceColor','none','LineWidth',2);

hold on;
%add in a black start button (could be red etc)
%create ellipse shape, think about scaling of axis
[x,y,z] = ellipsoid(0,0,0,5,10,0,20);
x = x(11,:);
x = [x;x];
y = y(11,:);
y = [y;y];
y = y+10;
buttonHeight = 10;
z = [];
z(1,:) = zeros(1,length(x(1,:)));
z(2,:) = ones(1,length(x(1,:)))*buttonHeight;
surf(x,y,z,'meshStyle','row','faceColor','k','edgeColor','w')

%with a top
[xt,yt,zt] = ellipsoid(0,0,10,5,10,0);
yt = yt+10;
surf(xt,yt,zt,'edgeColor','none','faceColor','k');

%add in touchscreen
patch([-100 100 100 -100]',[400 400 400 400]',[400 400 100 100]',[0.94 0.94 0.94])%back
patch([-100 100 100 -100]',[395 395 395 395]',[400 400 100 100]',[0.94 0.94 0.94])%front
patch([-100 100 100 -100]',[395 395 400 400]',[400 400 400 400]','k')%top
patch([-100 -100 -100 -100]',[395 400 400 395]',[400 400 100 100]','k')%sideL
patch([100 100 100 100]',[395 400 400 395]',[400 400 100 100]','k')%sideR

set(gca,'plotboxaspectratio',[1 1 1]);
view(3)

set(gca,'fontSize',30)
set(gca,'xTick',[-100 0 100])
set(gca,'yTick',[0 100 200 300 400])
set(gca,'zTick',[0 100 200 300 400])