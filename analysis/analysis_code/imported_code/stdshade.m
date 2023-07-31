function [lineOut, fillOut] = stdshade(amatrix,alpha,acolor,F,smth,depend_y, type, a_val, linewidth)
% usage: stdshading(amatrix,alpha,acolor,F,smth)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 
% - F assignes the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% - depend_y plot dependent var on x axis (0) or on y axis (1).
% 19/05/21 Khen: type - want to draw 'std' / 'se' (standard error) / 'ci' (Coinfidence interval).
%               a_val - alpha value when drawing CI. This isn't the transperency.
% smusall 2010/4/23
if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end
if exist('F','var')==0 || isempty(F)
    F=1:size(amatrix,2);
end
if exist('smth','var'); if isempty(smth); smth=1; end
else smth=1; %no smoothing by default
end  
if ne(size(F,1),1)
    F=F';
end
amean = nanmean(amatrix,1); %get man over first dimension
if smth > 1
    amean = boxFilter(nanmean(amatrix,1),smth); %use boxfilter to smooth data
end
% 19/05/21 Khen: Turns STD to SE (standtard error of the sample). 
astd = nanstd(amatrix,[],1); % to get std shading
switch type
    case 'std'
    case 'se'
        astd = astd / sqrt(size(amatrix,1));
    case 'ci'
        df = size(amatrix,1) - 1;
        t_val = tinv(a_val/2, df);
        astd =  t_val * astd / sqrt(size(amatrix,1));
    otherwise
        error('Wrong input, has to be: std/se/ci');
end

% astd = nanstd(amatrix,[],1)/sqrt(size(amatrix,1)); % to get sem shading
if depend_y
    std_x = [F fliplr(F)];
    std_y = [amean+astd fliplr(amean-astd)];
    mean_x = F;
    mean_y = amean;
else
    std_x = [amean+astd fliplr(amean-astd)];
    std_y = [F fliplr(F)];
    mean_x = amean;
    mean_y = F;
end
if exist('alpha','var')==0 || isempty(alpha) 
    fillOut = fill(std_x,std_y,acolor,'linestyle','none');
    acolor='k';
else
    fillOut = fill(std_x,std_y,acolor, 'FaceAlpha', alpha,'linestyle','none');
end
if ishold==0
    check=true; else check=false;
end
hold on;
lineOut = plot(mean_x,mean_y, 'color', acolor,'linewidth',linewidth); %% change color or linewidth to adjust mean line
if check
    hold off;
end
end
function dataOut = boxFilter(dataIn, fWidth)
% apply 1-D boxcar filter for smoothing
fWidth = fWidth - 1 + mod(fWidth,2); %make sure filter length is odd
dataStart = cumsum(dataIn(1:fWidth-2),2);
dataStart = dataStart(1:2:end) ./ (1:2:(fWidth-2));
dataEnd = cumsum(dataIn(length(dataIn):-1:length(dataIn)-fWidth+3),2);
dataEnd = dataEnd(end:-2:1) ./ (fWidth-2:-2:1);
dataOut = conv(dataIn,ones(fWidth,1)/fWidth,'full');
dataOut = [dataStart,dataOut(fWidth:end-fWidth+1),dataEnd];
end
