%  Add paths to data and functions

addpath ('c:\Program Files\Matlab\fdaM')
addpath ('c:\Program Files\Matlab\fdaM\examples\growth')

%  Last modified 16 January 2009

%  -----------------------------------------------------------------------
%                    Berkeley Growth Data
%  -----------------------------------------------------------------------

%  load previously computed results if applicable

load growth

%  ------------------------  input the data  -----------------------

ncasem = 39;
ncasef = 54;
nage   = 31;

fid = fopen('hgtm.dat','rt');
hgtmmat = reshape(fscanf(fid,'%f'),[nage,ncasem]);

fid = fopen('hgtf.dat','rt');
hgtfmat = reshape(fscanf(fid,'%f'),[nage,ncasef]);

age = [ 1:0.25:2, 3:8, 8.5:0.5:18 ]';
rng = [1,18];

%  --------------  Smooth the data non-monotonically  --------------
%  This smooth uses the usual smoothing methods to smooth the data,
%  but is not guaranteed to produce a monotone fit.  This may not
%  matter much for the estimate of the height function, but it can
%  have much more serious consequences for the velocity and
%  accelerations.  See the monotone smoothing method below for a
%  better solution, but one with a much heavier calculation overhead.

%  -----------  Create fd objects   ----------------------------

%  A B-spline basis with knots at age values and order 6 is used

knots    = age;
norder   = 6;
nbasis   = length(knots) + norder - 2;
hgtbasis = create_bspline_basis(rng, nbasis, norder, knots);

%  --- Smooth these objects, penalizing the 4th derivative  --
%  This gives a smoother estimate of the acceleration functions

%  set up roughness penalty smoothing function smooth_basis

Lfdobj   = int2Lfd(4);
lambda   = 1e-1;
hgtfdPar = fdPar(hgtbasis, Lfdobj, lambda);

%  smooth the data

hgtmfd = smooth_basis(age, hgtmmat, hgtfdPar);
hgtffd = smooth_basis(age, hgtfmat, hgtfdPar);

%  plot the data and the smooth

plotfit_fd(hgtmmat, age, hgtmfd)
plotfit_fd(hgtfmat, age, hgtffd)

%  ---------------------------------------------------------------
%         Find minimum GCV value of lambda
%  ---------------------------------------------------------------

lnlam   = -6:0.25:0;
gcvsave = zeros(length(lnlam),1);
dfsave  = gcvsave;
for i=1:length(lnlam)
  hgtfdPari = fdPar(hgtbasis, Lfdobj, 10^lnlam(i));
  [hgtfdi, dfi, gcvi] = smooth_basis(age, hgtfmat,...
                                     hgtfdPari);
  gcvsave(i) = sum(gcvi);
  dfsave(i)  = dfi;
end

%  plot the results

phdl = plot(lnlam, gcvsave, 'k-o');
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{13} log_{10}(\lambda)')
ylabel('\fontsize{13} GCV(\lambda)')

%  ---------------  plot the first 10 female data  ---------------

%  Height

agefine = linspace(1,18,101)';
hgtfmatfine = eval_fd(agefine, hgtffd(1:10));

phdl = plot(agefine, hgtfmatfine, '-');
set(phdl, 'LineWidth', 2)
hold on
plot(age, hgtfmat(:,1:10), 'o')
hold off
xlabel('\fontsize{19} Age')
ylabel('\fontsize{19} Height (cm)')
axis([1,18,60,200])

%  Velocity

velfmatfine = eval_fd(agefine, hgtffd(1:10), 1);

phdl = plot(agefine, velfmatfine, '-');
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{19} Age')
ylabel('\fontsize{19} Height Velocity (cm/yr)')
axis([1,18,0,20])

%  Acceleration

accfmatfine = eval_fd(agefine, hgtffd(1:10), 2);

phdl = plot(agefine, accfmatfine, '-', ...
            [1,18], [0,0], 'r:');
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{19} Age')
ylabel('\fontsize{19} Height Acceleration (cm/yr/yr)')
axis([1,18,-4,2])

%  height, velocity and acceleration

i=5;
subplot(3,1,1)
phdl = plot(agefine, hgtfmatfine(:,i), '-');
set(phdl, 'LineWidth', 2)
ylabel('\fontsize{13} Height')
axis([1,18,60,200])
subplot(3,1,2)
phdl = plot(agefine, velfmatfine(:,i), '-');
set(phdl, 'LineWidth', 2)
ylabel('\fontsize{13} Velocity')
axis([1,18,0,20])
subplot(3,1,3)
phdl = plot(agefine, accfmatfine(:,i), '-', ...
            [1,18], [0,0], 'r:');
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{13} Age')
ylabel('\fontsize{13} Acceleration')
axis([1,18,-4,2])


%  plot velocities with knots at each age

plot((1:10),1)
xlabel('\fontsize{16} Age')
ylabel('\fontsize{16} Velocity (cm/yr)')

%  plot velocities with 12 basis functions

hgtbasis = create_bspline_basis(rng, 12, norder);
hgtffd   = smooth_basis(age, hgtfmat, hgtbasis);

plot((1:10),1)
xlabel('\fontsize{16} Age')
ylabel('\fontsize{16} Velocity (cm/yr)')

%  plot accelerations with 12 basis functions

plot((1:10),2)
xlabel('\fontsize{16} Age')
ylabel('\fontsize{16} Acceleration (cm/yr^2)')

%  plot acceleration curves for the first 10 girls
%  estimated both by 12 basis
%  functions and by spline smoothing.

hgtbasis1 = create_bspline_basis(rng, 12, norder);
hgtffd1   = smooth_basis(age, hgtfmat, hgtbasis1);

subplot(1,2,1)
hgtfmat1 = eval_fd(agefine, hgtffd1(1:10), 2);
plot(agefine, hgtfmat1, 'k-')
xlabel('\fontsize{12} Age')
ylabel('\fontsize{12} Acceleration (cm/yr^2)')
axis([1,18,-40,10])
axis('square')

hgtbasis2 = create_bspline_basis(rng, 35, 6, age);
hgtfdPar2 = fdPar(hgtbasis2, 4, lambda);
hgtffd2   = smooth_basis(age, hgtfmat, hgtfdPar2);

subplot(1,2,2)
hgtfmat2 = eval_fd(agefine, hgtffd2(1:10), 2);
plot(agefine, hgtfmat2, 'k-')
xlabel('\fontsize{12} Age')
ylabel('\fontsize{12} Acceleration (cm/yr^2)')
axis([1,18,-12,2])
axis('square')

print -dps2 'c:/MyFiles/fdabook1/figs.dir/twoaccelplots.ps'

subplot(1,1,1)
hgtfmat2 = eval_fd(agefine, hgtffd2(1:10), 2);
phdl = plot(agefine, hgtfmat2, 'k-', [1,18], [0,0], 'k:');
set(phdl, 'LineWidth', 1)
lhdl = line(agefine, mean(hgtfmat2,2));
set(lhdl, 'LineStyle', '--')
xlabel('\fontsize{13} Age')
ylabel('\fontsize{13} Acceleration (cm/yr^2)')
axis([1,18,-4,2])

%  ----------------------------------------------------------
%  Estimate standard error of measurement for velocity and 
%    acceleration, re-smooth using the reciprocal of variance
%    of estimate as a weight, and display results
%  ----------------------------------------------------------

%  set up function smooth_pos

norderse = 3;
nbasisse = nage + norderse - 2;
stderrbasis = create_bspline_basis([1,18], nbasisse, norderse, age);
Wfd0   = fd(zeros(nbasisse,1),stderrbasis);  %  initial value for Wfd

%  Males

hgtmfit      = eval_fd(age, hgtmfd);
hgtmres      = hgtmmat - hgtmfit;   %  residuals
hgtmresmnsqr = mean(hgtmres.^2,2);  %  mean squared residuals

%  positively smooth the mean squared residuals

Lfdobj = 1;             %  smooth toward a constant
lambda = 1e-3;          %  smoothing parameter
hgtfdPar = fdPar(Wfd0, Lfdobj, lambda);

Wfd = smooth_pos(age, hgtmresmnsqr, hgtfdPar);

%  compute the variance and standard error of measurements

hgtmvar = eval_pos(age, Wfd);
hgtmstd = sqrt(hgtmvar);

subplot(1,1,1)
plot(age, sqrt(hgtmresmnsqr), 'o', age, hgtmstd, 'b-')

%  update weight vector for smoothing data

wtvec = 1./hgtmvar;
wtvec = wtvec./mean(wtvec);

%  set up new smooth of the data using this weight vector

Lfdobj   = int2Lfd(4);
lambda   = 1e-2;
hgtfdpar = fdPar(hgtbasis, Lfdobj, lambda);

%  smooth the data again

[hgtmfd, df, gcv, coef, SSE, penmat, y2cMap] = ...
    smooth_basis(age, hgtmmat, hgtfdpar, wtvec);

%  display the results

growthdisplay(age, hgtmmat, hgtmfd, hgtmstd, y2cMap, 'male')

%  Females

hgtffit      = eval_fd(age, hgtffd);
hgtfres      = hgtfmat - hgtffit;   %  residuals
hgtfresmnsqr = mean(hgtfres.^2,2);  %  mean squared residuals

%  positively smooth the mean squared residuals

Wfd = smooth_pos(age, hgtfresmnsqr, hgtfdPar);

%  compute the variance and standard error of measurements

hgtfvar = eval_pos(age, Wfd);
hgtfstd = sqrt(hgtfvar);

subplot(1,1,1)
plot(age, hgtfresmnsqr, 'o', age, hgtfvar, 'b-')
plot(age, sqrt(hgtfresmnsqr), 'o', age, hgtfstd, 'b-')

plot(age, hgtfresmnsqr, 'ko', age, hgtfvar, 'k-')
xlabel('\fontsize{16} Age')
ylabel('\fontsize{16} Variance of Measurement')

print -dps2 'c:/MyFiles/fdabook1/figs.dir/growthvariance.ps'

%  update weight vector for smoothing data

wtvec = 1./hgtfvar;
wtvec = wtvec./mean(wtvec);

%  set up new smooth of the data using this weight vector

Lfdobj   = int2Lfd(4);
lambda   = 1e-1;
hgtfdPar = fdPar(hgtbasis, Lfdobj, lambda);

%  smooth the data again

[hgtffd, df, gcv, coef, SSE, penmat, y2cMap] = ...
    smooth_basis(age, hgtfmat, hgtfdPar, wtvec);

accffd = deriv(hgtffd,2);
accmat = eval_fd(agefine, accffd);
accmn  = mean(accmat(:,1:10),2);

plot(agefine, accmat(:,1:10), '-', [1,18], [0,0], 'r:')
lhdl = line(agefine, accmn);
set(lhdl, 'LineWidth', 2, 'LineStyle', '--', 'color', 'b')
xlabel('\fontsize{19} Age')
ylabel('\fontsize{19} Height Acceleration(cm/year/year)')
axis([1,18,-4,2])

%  display the results

growthdisplay(age, hgtfmat, hgtffd, hgtfstd, y2cMap, 'female')

%  plot accelerations against velocity for first 10 girls

D0hgtfmat = eval_fd(agefine, hgtffd(1:10));
D1hgtfmat = eval_fd(agefine, hgtffd(1:10), 1);
D2hgtfmat = eval_fd(agefine, hgtffd(1:10), 2);

ahdl = axes('Box', 'on');
set(ahdl, 'FontSize', 16)
set(ahdl, 'Xlim', [0,15]);
set(ahdl, 'Ylim', [-6,2]);
set(ahdl, 'Xtick', 0:3:15);
set(ahdl, 'Ytick', -6:2:2);
xlabel('Velocity (cm/yr)', 'FontSize', 13);
ylabel('Acceleration (cm/yr^2)', 'FontSize', 13);
hold on
for i=1:10
lhdl = line(D1hgtfmat, D2hgtfmat);
set(lhdl, 'LineWidth', 1, 'color', 'k')
end
lhdl = line([0,15], [0,0]);
set(lhdl, 'LineWidth', 1, 'LineStyle', ':', 'color', 'k')

%  plot accelerations against position for first 10 girls

ahdl = axes('Box', 'on');
set(ahdl, 'FontSize', 16)
set(ahdl, 'Xlim', [65,200]);
set(ahdl, 'Ylim', [-6,2]);
set(ahdl, 'Xtick', 60:20:200);
set(ahdl, 'Ytick', -6:2:2);
xlabel('Position (cm)', 'FontSize', 13);
ylabel('Acceleration (cm/yr^2)', 'FontSize', 13);
hold on
for i=1:10
lhdl = line(D0hgtfmat, D2hgtfmat);
set(lhdl, 'LineWidth', 1, 'color', 'k')
end
lhdl = line([0,15], [0,0]);
set(lhdl, 'LineWidth', 1, 'LineStyle', ':', 'color', 'k')

%  regression of acceleration on position

D0hgtfmat = eval_fd(agefine, hgtffd);
D1hgtfmat = eval_fd(agefine, hgtffd, 1);
D2hgtfmat = eval_fd(agefine, hgtffd, 2);

D0hgtffd = smooth_basis(agefine, D0hgtfmat, hgtbasis);
D1hgtffd = smooth_basis(agefine, D1hgtfmat, hgtbasis);
D2hgtffd = smooth_basis(agefine, D2hgtfmat, hgtbasis);

conbasis = create_constant_basis(rng);

xfdcell    = cell(2,1);
xfdcell{1} = fd(ones(1,ncasef), conbasis);
xfdcell{2} = D0hgtffd;

betabasis = create_bspline_basis(rng,10);
betafdPar = fdPar(betabasis);

betacell = cell(2,1);
betacell{1} = fdPar(create_constant_basis(rng));
betacell{2} = betafdPar;

fRegressCell = fRegress(D2hgtffd, xfdcell, betacell);

betaestcell = fRegressCell{4};

beta1fd = getfd(betaestcell{1});
beta2fd = getfd(betaestcell{2});

subplot(2,1,1)
plot(beta1fd)
subplot(2,1,2)
plot(beta2fd)

D2hgtfhatfd = fRegressCell{5};

subplot(1,1,1)
plot(D2hgtfhatfd)

%  ----------------------------------------------------------
%          Compute monotone smooths of the data  
%  ----------------------------------------------------------

%  These analyses use a function written entirely in S-PLUS called
%  smooth.monotone that fits the data with a function of the form
%                   f(x) = b_0 + b_1 D^{-1} exp W(x)
%     where  W  is a function defined over the same range as X,
%                 W + ln b_1 = log Df and w = D W = D^2f/Df.
%  The constant term b_0 in turn can be a linear combinations of covariates:
%                         b_0 = zmat * c.
%  The fitting criterion is penalized mean squared error:
%    PENSSE(lambda) = \sum [y_i - f(x_i)]^2 +
%                     \lambda * \int [L W(x)]^2 dx
%  where L is a linear differential operator defined in argument LFD.
%  The function W(x) is expanded by the basis in functional data object
%  Because the fit must be calculated iteratively, and because S-PLUS
%  is so slow with loopy calculations, these fits are VERY slow.  But
%  they are best quality fits that I and my colleagues, notably
%  R. D. Bock, have been able to achieve to date.
%  The Matlab version of this function is much faster.

%  ------  First set up a basis for monotone smooth   --------
%  We use b-spline basis functions of order 6
%  Knots are positioned at the ages of observation.

norder = 6;
nbasis = nage + norder - 2;
wbasis = create_bspline_basis(rng, nbasis, norder, knots);

%  starting values for coefficient

cvec0 = zeros(nbasis,1);
Wfd0  = fd(cvec0, wbasis);

Lfdobj   = int2Lfd(3);  %  penalize curvature of velocity
lambda   = 10^(-1.5);   %  smoothing parameter
hgtfdPar = fdPar(Wfd0, Lfdobj, lambda);

% -----------------  Male data  --------------------

cvecm = zeros(nbasis, ncasem);
betam = zeros(2,      ncasem);
RMSEm = zeros(1,      ncasem);

index = 1:ncasem;

for icase=index
  hgt = hgtmmat(:,icase);
  [Wfd, beta] = smooth_monotone(age, hgt, hgtfdPar);
  cvecm(:,icase) = getcoef(Wfd);
  betam(:,icase) = beta;
  hgthat = beta(1) + beta(2).*monfn(age, Wfd);
  RMSEm(icase) = sqrt(mean((hgt - hgthat).^2));
  fprintf('\n%5.f %10.4f\n', [icase, RMSEm(icase)])
end

% -----------------  Female data  --------------------

cvecf = zeros(nbasis, ncasef);
betaf = zeros(2,      ncasef);
RMSEf = zeros(1,      ncasef);
resf  = zeros(nage,   ncasef);

index = 1:ncasef;

for icase=index
  hgt = hgtfmat(:,icase);
  [Wfd, beta] = smooth_monotone(age, hgt, hgtfdPar);
  cvecf(:,icase) = getcoef(Wfd);
  betaf(:,icase) = beta;
  hgthat = beta(1) + beta(2).*monfn(age, Wfd);
  resf(:,icase) = hgt - hgthat;
  RMSEf(icase) = sqrt(mean((hgt - hgthat).^2));
  fprintf('\n%5.f %10.4f\n', [icase, RMSEf(icase)])
end

%  histograms of residuals

for icase=1:ncasef
    hist(resf(:,icase))
    pause
end

resfvec = reshape(resf, ncasef*nage,1);
hist(resfvec)

resftrim = resf;
for icase=1:ncasef
    index = resf(:,icase) < -1;
    resftrim(index,icase) = -1;  
    index = resf(:,icase) >  1;
    resftrim(index,icase) =  1;  
end

nWbasis = 13;
Wbasis  = create_bspline_basis([-1, 1], nWbasis);
Wfd0    = fd(zeros(nWbasis,1), Wbasis);

Lfdobj = int2Lfd(2);
lambda = 1e-3;
WfdPar = fdPar(Wfd0, Lfdobj, lambda);

[Wfdobj, C] =  density_fd(resfvec, WfdPar);

resfine  = linspace(-1,1,51);
densfine = eval_pos(resfine, Wfdobj)./C;

plot(resfine, densfine)

denssave = zeros(51,nage);
for iage=1:nage
    [Wfdi, C] = density_fd(resftrim(iage,:)', WfdPar, 1e-4, 20, 0);
    denssave(:,iage) = eval_pos(resfine, Wfdi)./C;
end
 
contour(age, resfine, denssave)

save growthdensity

%  plot data and smooth, residuals, velocity, and acceleration

%  Males:

index = 1:ncasem;
for i = index
  Wfd  = fd(cvecm(:,i),wbasis);
  beta = betam(:,i);
  hgtmhat   = beta(1) + beta(2).*monfn(age, Wfd);
  Dhgtmhat  = beta(2).*eval_mon(age, Wfd, 1);
  D2hgtmhat = beta(2).*eval_mon(age, Wfd, 2);
  subplot(2,2,1)
  plot(age, hgtmmat(:,i), 'go', age, hgtmhat, '-')
  axis([1, 18, 60, 200]);
  xlabel('Years');  title(['Height for male ',num2str(i)])
  resi = hgtmmat(:,i) - hgtmhat;
  subplot(2,2,2)
  plot(age, resi, '-o',     [1,18], [0,0], 'r--')
  axis([1,18,-1,1]);
  xlabel('Years');  title('Residuals')
  subplot(2,2,3)
  plot(age, Dhgtmhat, '-',  [1,18], [0,0], 'r--')
  axis([1,18,0,15]);
  xlabel('Years');  title('Velocity')
  subplot(2,2,4)
  plot(age, D2hgtmhat, '-')
  axis([1,18,-6,6]);
  xlabel('Years') ;  title('Acceleration')
  pause;
end

% Females:

index = 1:ncasef;
for i = index
  Wfd  = fd(cvecf(:,i),wbasis);
  beta = betaf(:,i);
  hgtfhat   = beta(1) + beta(2).*monfn(age, Wfd);
  Dhgtfhat  = beta(2).*eval_mon(age, Wfd, 1);
  D2hgtfhat = beta(2).*eval_mon(age, Wfd, 2);
  subplot(2,2,1)
  plot(age, hgtfmat(:,i), 'go', age, hgtfhat, '-')
  axis([1, 18, 60, 200]);
  xlabel('Years');  title(['Height for female ',num2str(i)])
  resi = hgtfmat(:,i) - hgtfhat;
  subplot(2,2,2)
  plot(age, resi, '-o',     [1,18], [0,0], 'r--')
  axis([1,18,-1,1]);
  xlabel('Years');  title('Residuals')
  subplot(2,2,3)
  plot(age, Dhgtfhat, '-')
  axis([1,18,0,15]);
  xlabel('Years');  title('Velocity')
  subplot(2,2,4)
  plot(age, D2hgtfhat, '-',  [1,18], [0,0], 'r--')
  axis([1,18,-6,6]);
  xlabel('Years') ;  title('Acceleration')
  pause;
end

%  Compute velocity functions over a fine mesh

velfmatfine = zeros(101,ncasef);
for i = 1:ncasef
  Wfd  = fd(cvecf(:,i),wbasis);
  beta = betaf(:,i);
  velfmatfine(:,i) = beta(2).*eval_mon(agefine, Wfd, 1);
end

%  Compute acceleration functions over a fine mesh

accfmatfine = zeros(101,ncasef);
for i = 1:ncasef
  Wfd  = fd(cvecf(:,i),wbasis);
  beta = betaf(:,i);
  accfmatfine(:,i) = beta(2).*eval_mon(agefine, Wfd, 2);
end

%  Plot the results for the first 10 girls

subplot(1,1,1)
index = 1:10;
accfmeanfine = mean(accfmatfine(:,index),2);
phdl = plot(agefine, accfmatfine(:,index), 'b-', ...
            [1,18], [0,0], 'b:');
set(phdl, 'LineWidth', 1)
lhdl = line(agefine, accfmeanfine);
set(lhdl, 'LineWidth', 2, 'LineStyle', '--')
xlabel('\fontsize{16} Age')
ylabel('\fontsize{16} Acceleration (cm/yr^2)')
axis([1,18,-4,2])

%  Phase-plane plot for the first 10 girls, 
%  Figure growloops in R-book

subplot(1,1,1)
index = 1:10;
phdl = plot(velfmatfine(:,index), accfmatfine(:,index), 'k-', ...
            [1,18], [0,0], 'k:');
set(phdl, 'LineWidth', 1)
hold on
phdl = plot(velfmatfine(:,6), accfmatfine(:,6), 'k--', ...
            [0,12], [0,0], 'k:');
set(phdl, 'LineWidth', 2)
phdl=plot(velfmatfine(64,index), accfmatfine(64,index), 'ko');
set(phdl, 'LineWidth', 2)
hold off
xlabel('\fontsize{13} Velocity (cm/yr)')
ylabel('\fontsize{13} Acceleration (cm/yr^2)')
axis([0,12,-5,2])


%  ---------------------------------------------------------------------
%            Register the velocity curves for the girls using
%                     landmark registration
%  ---------------------------------------------------------------------

%  Define the mid-spurt as the single landmark by manually
%    clicking on the zero crossing

index = 1:ncasef;
midspurtsave = zeros(length(index),2);
D2hgtfmat    = zeros(ncasef, length(agefine));
subplot(1,1,1)
for i = index
  Wfd  = fd(cvecf(:,i),wbasis);
  beta = betaf(:,i);
  D2hgtfmat(i,:) = beta(2).*eval_mon(agefine, Wfd, 2);
  plot(agefine, D2hgtfmat(i,:), '-', [1,18], [0,0], 'r:')
  axis([1,18,-6,6]);
  xlabel('Years') ;  
  title(['Acceleration for record ',num2str(i)])
  midspurtsave(i,:) = ginput(1);
  pause;
end

midspurt = midspurtsave(:,1);
midspurtmean = mean(midspurt);

%  compute the second derivative curve values over a fine mesh

Wfd = fd(cvecf, wbasis);
D2hgtfmat = (ones(101,1)*betaf(2,:)).*eval_mon(agefine, Wfd, 2);

%  smooth these with a large basis to get a functional data object

D2hgtbasis = create_bspline_basis([1,18], 31);
D2hgtfdPar = fdPar(D2hgtbasis, 2, 1e-10);
D2hgtffd   = smooth_basis(agefine, D2hgtfmat, D2hgtfdPar);

%  Set up a simply monomial basis for landmark registration
%  This will compute warping functions that interpolate the
%  single landmark time

landmarkwbasis = create_monomial_basis([1,18], 3); 

%  carry out the landmark registration

[D2hgtfregfd, D2hgtfwarpfd, D2hgtfWfd] = ...
       landmarkreg(D2hgtffd, midspurt, midspurtmean, landmarkwbasis, 1);
   
D2hgtfregmat  = eval_fd(agefine, D2hgtfregfd);
D2hgtfwarpmat = eval_fd(agefine, D2hgtfwarpfd);

%  plot registered accelerations along with warping functions

for i=1:ncasef
    subplot(1,2,1)
    plot(agefine, D2hgtfregmat(:,i), 'b-', ...
         agefine, D2hgtfmat(:,i), 'b--',...
         [1,18], [0,0], 'b:', ...
         [11.52,11.52], [-6,4], 'b:')
    axis([1,18,-6,4]);
    xlabel('Years')
    ylabel('Registered acceleration')
    axis('square')
    subplot(1,2,2)
    plot(agefine, D2hgtfwarpmat(:,i), 'b-', ...
         [1,18], [1,18], 'b--', ...
         11.52, midspurt(i), 'o')
    axis([1,18,1,18]);
    xlabel('Years')
    title(['Case ',num2str(i)])
    axis('square')
    pause
end

%  plot accelerations and warping functions for cases 3 and 7

m = 0;
for i=[3,7]
    m = m + 1;
    subplot(2,2,m)
    phdl=plot(agefine, D2hgtfmat(:,i), 'b-',...
         [1,18], [0,0], 'b:', ...
         [11.52,11.52], [-6,4], 'b--');
    set(phdl, 'LineWidth', 2)
    axis([1,18,-6,4]);
    m = m + 1;
    subplot(2,2,m)
    phdl=plot(agefine, D2hgtfwarpmat(:,i), 'b-', ...
         [1,18], [1,18], 'b--', ...
         11.52, midspurt(i), 'o', ...
         [11.5,11.5], [1,18], 'b--');
    set(phdl, 'LineWidth', 2)
    axis([1,18,1,18]);
end

%  plot registered accelerations for first 10 girls

figure(1)

%  plot the unregistered and registered results for the first 10 girls

subplot(2,1,1)
lhdl = plot(agefine, D2hgtfmat(:,1:10), '-', [1,18], [0,0], 'k:');
set(lhdl, 'LineWidth', 1)
lhdl = line(agefine, mean(D2hgtfmat(:,1:10),2));
set(lhdl, 'LineWidth', 2, 'LineStyle', '--')
ylabel('Accel. (cm/yr^2)', 'FontSize', 13);
axis([1,18,-4,2])

subplot(2,1,2)
lhdl = plot(agefine, D2hgtfregmat(:,1:10), '-', [1,18], [0,0], 'k:');
set(lhdl, 'LineWidth', 1)
lhdl = line(agefine, mean(D2hgtfregmat(:,1:10),2));
set(lhdl, 'LineWidth', 2, 'LineStyle', '--')
xlabel('Age (years)', 'FontSize', 13);
ylabel('Accel. (cm/yr^2)', 'FontSize', 13);
axis([1,18,-4,2])

%  plot the warping functions for the first 10 girls

subplot(1,1,1)
lhdl = plot(agefine, D2hgtfwarpmat(:,1:10), '-', [1,18], [1,18], 'k:');
set(lhdl, 'LineWidth', 2)
xlabel('\fontsize{13} Age (clock time)')
ylabel('\fontsize{13} Age (growth time)')
axis([1,18,1,18])

%  ---------------------------------------------------------------------
%            Register the velocity curves for the girls using
%                     continuous registration
%  ---------------------------------------------------------------------

index = 1:ncasef;

agefine = linspace(1, 18, 101)';

%  set up a basis for the functions W(t) that define the warping
%  functions

nbasisw = 15;
norder  = 5;
basisw  = create_bspline_basis([1,18], nbasisw, norder);

%  define the target function for registration, as well as the
%  curves to be registered. 

Dhgtfmeanfd = deriv(mean(hgtffd), 1);
Dhgtffd     = deriv(hgtffd(index), 1);

%  define the functional parameter object for the W functions

coef0 = zeros(nbasisw,length(index));
Wfd0  = fd(coef0, basisw);

Lfdobj = int2Lfd(2);
lambda = 1;

WfdPar = fdPar(Wfd0, Lfdobj, lambda);

%  register the curves

[Dhgtfregfd, Wfd] = registerfd(Dhgtfmeanfd, Dhgtffd, WfdPar);

%  set up values for plotting

Dhgtfregmat  = eval_fd(Dhgtfregfd,  agefine);
Dhgtfmeanvec = eval_fd(Dhgtfmeanfd, agefine);
Dhgtfvec     = eval_fd(Dhgtffd,     agefine);

%  set up values of the warping functions

warpmat = zeros(101, ncasef);
for i=1:ncasef
    warpmat(:,i) = monfn(agefine, Wfd(i));
    warpmat(:,i) = 1 + 17.*warpmat(:,i)./warpmat(101,i);
end

%  plot each curve

for i = 1:length(index)
   subplot(1,2,1)
   phdl = plot(agefine, Dhgtfvec(:,i),    '-',  ...
               agefine, Dhgtfmeanvec,     '--', ...
               agefine, Dhgtfregmat(:,i), '-',  ...
               [11.5, 11.5], [0,20], ':');
   set(phdl, 'LineWidth', 2)
   xlabel('\fontsize{13} Age (years)')
   ylabel('\fontsize{13} Growth velocity (cm/yr)')
   axis([1,18,0,20])
   axis('square')
   title(['\fontsize{13} Case ',num2str(i)])
   legend('\fontsize{12} Unregistered', ...
          '\fontsize{12} Target', ...
          '\fontsize{12} Registered')
   subplot(1,2,2)
   phdl = plot(agefine, warpmat(:,i), '-', agefine, agefine, '--');
   set(phdl, 'LineWidth', 2)
   xlabel('\fontsize{13} Growth age (years)')
   ylabel('\fontsize{13} Clock age (years)')
   axis([1,18,1,18])
   axis('square')
   pause
end

%  plot the warping functions for the first 10 girls

subplot(1,1,1)
lhdl = plot(agefine, warpmat(:,1:10), '-', [1,18], [1,18], 'k:');
set(lhdl, 'LineWidth', 2)
xlabel('\fontsize{13} Age (clock time)')
ylabel('\fontsize{13} Age (growth time)')
axis([1,18,1,18])


%  ---------------------------------------------------------------------
%   Register the landmark registered  acceleration curves for the girls 
%                     using continuous registration
%  ---------------------------------------------------------------------

%  set up a basis for the functions W(t) that define the warping
%  functions

nbasisw = 15;
norder  = 5;
basisw  = create_bspline_basis([1,18], nbasisw, norder);

%  define the target function for registration, as well as the
%  curves to be registered. 

D2hgtfmeanfd = mean(D2hgtfregfd);
D2hgtffd     = D2hgtfregfd;

%  define the functional parameter object for the W functions

coef0 = zeros(nbasisw,length(index));
Wfd0  = fd(coef0, basisw);

Lfdobj = int2Lfd(3);
lambda = 1;

WfdPar = fdPar(Wfd0, Lfdobj, lambda);

%  register the curves

[D2hgtfregfd, Wfd] = registerfd(D2hgtfmeanfd, D2hgtffd, WfdPar);

%  set up values for plotting

D2hgtfregmat  = eval_fd(D2hgtfregfd,  agefine);
D2hgtfmeanvec = eval_fd(D2hgtfmeanfd, agefine);
D2hgtfvec     = eval_fd(D2hgtffd,     agefine);

%  set up values of the warping functions

warpmat = zeros(101, ncasef);
for i=1:ncasef
    warpmat(:,i) = monfn(agefine, Wfd(i));
    warpmat(:,i) = 1 + 17.*warpmat(:,i)./warpmat(101,i);
end

%  plot each curve

for i = 1:length(index)
   subplot(1,2,1)
   phdl = plot(agefine, D2hgtfvec(:,i),    '-',  ...
               agefine, D2hgtfmeanvec,     '--', ...
               agefine, D2hgtfregmat(:,i), '-',  ...
               [11.5, 11.5], [-6,4], ':');
   set(phdl, 'LineWidth', 2)
   xlabel('\fontsize{13} Age (years)')
   ylabel('\fontsize{13} Growth acceleration (cm/yr^2)')
   axis([1,18,-6,4])
   axis('square')
   title(['\fontsize{13} Case ',num2str(i)])
   legend('\fontsize{12} Unregistered', ...
          '\fontsize{12} Target', ...
          '\fontsize{12} Registered')
   subplot(1,2,2)
   phdl = plot(agefine, warpmat(:,i), '-', agefine, agefine, '--');
   set(phdl, 'LineWidth', 2)
   xlabel('\fontsize{13} Growth age (years)')
   ylabel('\fontsize{13} Clock age (years)')
   axis([1,18,1,18])
   axis('square')
   pause
end

subplot(1,1,1)
lhdl = plot(agefine, Dhgtfregmat(:,1:10), 'k-', [1,18], [0,0], 'k:');
set(lhdl, 'LineWidth', 1)
lhdl = line(agefine, mean(Dhgtfregmat(:,1:10),2));
set(lhdl, 'LineWidth', 2, 'LineStyle', '--', 'color', 'k')
xlabel('Age (years)', 'FontSize', 13);
ylabel('Accel. (cm/yr^2)', 'FontSize', 13);
axis([1,18,0, 20])

save growth

%  ---------------------------------------------------------------------
%        Monotone smooth of short term height measurements
%  ---------------------------------------------------------------------

%  ---------------- input the data  ----------------------------------

clear;

fid  = fopen('onechild.dat','rt');
temp = fscanf(fid,'%f');
n    = 83;
data = reshape(temp, [n, 2]);
day  = data(:,1);
hgt  = data(:,2);
rng  = [day(1), day(n)];
wgt  = ones(n,1);
zmat = wgt;

%  set up the basis

nbasis   = 43;
norder   = 4;
hgtbasis = create_bspline_basis(rng, nbasis, norder);

%  set parameters for the monotone smooth

Lfdobj   = int2Lfd(2);
lambda   = 1;
hgtfdPar = fdPar(hgtbasis, Lfdobj, lambda);

%  carry out the monotone smooth

[Wfd, beta, Fstr, iternum, iterhist] = ...
    smooth_monotone(day, hgt, hgtfdPar);

%  plot the function W = log Dh

subplot(1,1,1)
plot(Wfd);

%  plot the data plus smooth

dayfine  = linspace(day(1),day(n),151)';
yhat     = beta(1) + beta(2).*eval_mon(day, Wfd);
yhatfine = beta(1) + beta(2).*eval_mon(dayfine, Wfd);
phdl = plot(day, hgt, 'o', dayfine, yhatfine, 'b-');
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{19} Day')
ylabel('\fontsize{19} Height (cm)')
axis([0,312,123,131])

%  plot growth velocity

Dhgt = beta(2).*eval_mon(dayfine, Wfd, 1);
phdl = plot(dayfine, Dhgt);
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{19} Days')
ylabel('\fontsize{19} Velocity (cm/day)')
axis([0,312,0,.06])

%  plot growth acceleration

D2hgt = beta(2).*eval_mon(dayfine, Wfd, 2);
phdl = plot(dayfine, D2hgt, [0,312], [0,0], 'r:');
set(phdl, 'LineWidth', 2)
xlabel('\fontsize{19} Days')
ylabel('\fontsize{19} Velocity (cm/day/day)')
axis([0,312,-.003,.004])
