function [FD,missingXs,gcvs] = smoothFDA(x,y,lambda,knotRatio,landmarks,chunkSize,chunkOverlap)
% [FD,missingXs,gcvs] = smoothFDA(x,y,lambda,knotRatio,landmarks,chunkSize,chunkOverlap)
%
% performs FDA smoothing with an option to presever kinematic landmarks, and
% returns a structure of smoothed data.
%
% INPUT
% x,y       ... data arrays to be fitted. x usually time in seconds, y any
%               unit. When missing data is included (NaN), they will be
%               interpolated using cubic functions.
% lambda    ... smoothing parameter determining the roughness penalty
%               (default: '10^-18')
% knotRatio ... number of data points per knot (e.g., a knot every 5 data
%               points, thus every 20 ms at a motion SR of 250Hz)
% landmarks ... onset times of the kinematic landmarks to be preserverd
%               across smoothing
% chunkSize ... size of FDA fit (calcs a lot faster) in knots. If you
%               prefer one fit on the entire data, set this parameter to
%               the # of knots
% chunkOverlap .......
%
% OUTPUT
% FD        ... a functional data object that contains the basis and the
%               coefficients for the entire data array
% missingXs ... onset times of missing data ('NaN's) in the original data
% gcvs      ... generalized cross validation measure returned by the
%               smooth_basis function. In the likely case of chunking, a
%               value for each fit will be returned.
%
% Werner Goebl, 22 April 2008, http://www.mcgill.ca/spl/
%
%ccEdit line 161 to interface with new smooth_basis
debug = false;
startTime = now;
if nargin < 2
    error('Data input required.');
end
if length(x) ~= length(y)
    error('x and y data arrays must have same length.');
end
if nargin < 3
    lambda = '10^-18'; % smoothing parameter (roughness penalty)
end
if nargin < 4
    knotRatio = 4; % how many data samples per knot
end
if nargin < 5
    landmarks = []; % onset times in seconds of kinematic landmarks to be
end %                 preserved
if nargin < 6
    chunkSize = 35; % # of basis functions at which it starts processing it
    %                 chunkwise (esp. important for processing speed).
end
if nargin < 7
    chunkOverlap = 15;
end
chunkOverlap = min(chunkSize-1, chunkOverlap);
norder = 6; % (fixed) bspline order, good for mocap data, when you're
%             interested in POS-VEL-ACC.

if size(y,1) < size(y,2) % make sure data is in right format
    y = y';
end
if size(x,1) < size(x,2)
    x = x';
end

sr = round(1/mode(diff(x))); % determine sampling rate from x array

% interpolate data in case of missings
if isnan(y(1)); y(1) = 0; end
if isnan(y(end)); y(end) = 0; end
mxs = find(isnan(y));
missingXs = x(mxs); % remember missing time values and return them
x(mxs) = [];
y(mxs) = [];
nx = min(x):1/sr:max(x);
ny = interp1(x,y,nx,'v5cubic');
%

% determine knots and insert extra knots (if landmarks are provided)
% An additional knots too close or at the same location (mergingWindow)
% to a regular knot would cause a discontinuity in the 2nd derivative. The
% following section takes care of that.
xknots = nx(1:knotRatio:end); % in seconds
if max(xknots) ~= max(x)
    xknots(end+1) = max(x);
end
if ~isempty(landmarks)
    mergingWindow = knotRatio/sr/2; %
    tobeadded = [];
    for i = 1:length(landmarks) % go through landmarks array and add knots
        idxLeft  = min(find(xknots >= landmarks(i) - mergingWindow));
        idxRight = max(find(xknots <= landmarks(i) + mergingWindow));
        if isempty(idxLeft) || isempty(idxRight);
            continue;
        end
        % remove any knots closer than merginWindow to landmarks(i)
        if landmarks(i) - xknots(idxLeft) < mergingWindow
            xknots(idxLeft) = [];
        elseif xknots(idxRight) - landmarks(i) < mergingWindow
            xknots(idxRight) = [];
        end
        tobeadded = [tobeadded landmarks(i) landmarks(i) landmarks(i)];
    end
    xknots = sort([xknots tobeadded]);
    if max(xknots) < max(nx)
        xknots = [xknots nx(end)];
    elseif max(xknots) > max(nx)
        xknots(find(xknots==max(xknots))) = max(nx);
    end
    if xknots(1) > nx(1)
        xknots = [nx(1) xknots];
    end
end

% fitting by small chunks (a lot faster!)
lxk = length(xknots);
gcvs = [];
nochunks = floor(lxk/chunkSize);
coefOverlap = chunkOverlap + (norder - 2) / 2; %
coefs = []; % container of coefficients

if debug
    newSR = 1000; % Hz
    cutTimes = round([min(xknots) (xknots((1:nochunks-1)*chunkSize)) ...
        max(xknots)]*newSR)/newSR; % cut times in s of output trajectories
    figure(100); clf; hold on;
    cm = colormap;
end

for n = 1:nochunks
    fit1 = max(1, (n-1)*chunkSize-chunkOverlap); % knot indices
    if n==nochunks
        fit2 = lxk;
    else
        fit2 = min(lxk, n * chunkSize+chunkOverlap); % knot indices
    end
    beginCorr = 0;
    while xknots(fit1)==xknots(fit1+beginCorr+1) % remove identical knots at beginning
        beginCorr = beginCorr + 1;
    end
    fit1 = fit1 + beginCorr;
    endCorr = 0;
    while xknots(fit2)==xknots(fit2-endCorr-1); % remove identical knots at end
        endCorr = endCorr + 1;
    end
    fit2 = fit2 - endCorr;
    kno = xknots(fit1:fit2); % knots to be fitted

    nbasis = length(kno) + norder - 2; % number of basis functions

    ybasis = create_bspline_basis([min(kno) max(kno)], ...
        nbasis, norder, kno);

    fpo = fdPar(ybasis, int2Lfd(norder-2), eval(lambda));

    idx = find(nx>=kno(1) & nx<=kno(end)); % data excerpt to be fitted

    [chunkFD, df, gcv] = smooth_basis(nx(idx), ny(idx), fpo);
    coef = getcoef(chunkFD);

    gcvs = [gcvs gcv]; % collect gcv values

    if debug
        if n~=1 && n~=nochunks
            line([kno(coefOverlap+1) kno(coefOverlap+1)],get(gca,'ylim'),'color',[.8 .8 .8])
        end
        pause(.1)
        plot(kno,coef(3:end-2),'.-','color',cm(round(rand * length(cm)),:));
        if n==1
            xxxs  = [kno(1) kno(1) kno(1:end-chunkOverlap-1+endCorr)];
        elseif n==nochunks
            xxxs  = [xxxs kno(chunkOverlap+1-beginCorr:end) kno(end) kno(end)];
        else
            xxxs  = [xxxs kno(chunkOverlap+1-beginCorr:end-chunkOverlap-1+endCorr)];
        end
    end

    if nochunks == 1
        coefs = coef;
    elseif n==1 % collect coefficients
        coefs = coef(1:end-coefOverlap-1+endCorr);
    elseif n==nochunks
        coefs = [coefs; coef(coefOverlap+1-beginCorr:end)];
    else
        coefs = [coefs; coef(coefOverlap+1-beginCorr:end-coefOverlap-1+endCorr)];
    end

    if debug
        xcrpt = cutTimes(n):1/newSR:cutTimes(n+1);
        pos = eval_fd(xcrpt,chunkFD,int2Lfd(0)); % POSITION
        vel = eval_fd(xcrpt,chunkFD,int2Lfd(1)); % VELOCITY
        acc = eval_fd(xcrpt,chunkFD,int2Lfd(2)); % ACCELERATION
        if n == 1
            ndata.POS = pos;
            ndata.VEL = vel;
            ndata.ACC = acc;
        else
            ndata.POS = [ndata.POS; pos(2:end)];
            ndata.VEL = [ndata.VEL; vel(2:end)];
            ndata.ACC = [ndata.ACC; acc(2:end)];
        end
    end
end


% create FD object of entire data
nbasis = length(xknots) + norder - 2;
fullBasis = create_bspline_basis([min(xknots) max(xknots)], nbasis, norder, xknots);
FD = fd(coefs, fullBasis);


if debug
    for n = 1:nochunks
        xcrpt = cutTimes(n):1/newSR:cutTimes(n+1);
        pos = eval_fd(xcrpt,FD,int2Lfd(0)); % POSITION
        vel = eval_fd(xcrpt,FD,int2Lfd(1)); % VELOCITY
        acc = eval_fd(xcrpt,FD,int2Lfd(2)); % ACCELERATION
        if n == 1
            data.POS = pos;
            data.VEL = vel;
            data.ACC = acc;
        else
            data.POS = [data.POS; pos(2:end)];
            data.VEL = [data.VEL; vel(2:end)];
            data.ACC = [data.ACC; acc(2:end)];
        end
    end
    data.timeAxis = cutTimes(1):1/newSR:cutTimes(end);

    figure(100);
    hold on; plot(xxxs,coefs-.01,'k.-'); pause(1)

    figure(3); clf
    ax = plotPVA(y,x); hold on;
    subplot(ax(1))
    plot(data.timeAxis,data.POS,'g','linewidth',1);
    plot(data.timeAxis,ndata.POS,'r.-','linewidth',1);
    subplot(ax(2))
    plot(data.timeAxis,data.VEL,'g','linewidth',1);
    plot(data.timeAxis,ndata.VEL,'r.-','linewidth',1);
    subplot(ax(3))
    plot(data.timeAxis,data.ACC,'g','linewidth',1);
    plot(data.timeAxis,ndata.ACC,'r.-','linewidth',1);

end

%fprintf('%7.3f;\n',(now-startTime)*24*60*60);
%fprintf('smoothFDA:\tcalc time %s\n',datestr(now-startTime,13));

% for i = [20:5:1200]; fprintf('%3d\t',i); [data,missingXs,gcv] = smoothFDA(TIME,POS,lambda,knotRatio,landmarks,1000,i); end