function insideFlag = checkRectBounds(position,boundingRegion)

%position = 2 element array, [x,y] coords
%bounding region = rect like argument from psych toolbox [x1,y1,x2,y2]

insideFlag = 0;

if position(1) >= boundingRegion(1) && position(1) <= boundingRegion(3) && position(2) >= boundingRegion(2) && position(2) <= boundingRegion(4)
    insideFlag = 1;
end