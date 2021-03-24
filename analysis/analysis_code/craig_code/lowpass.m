function [newdata, success] = lowpass(data,samprate,cutoff,order,direction)

% newdata = lowpass(data,samprate,cutoff,order)
%
% performs a lowpass filtering of the input data
% using an nth order zero phase lag butterworth filter
%
% given -> data (data)
%	-> samprate (Hz)
%	-> cutoff freq (Hz)
%	-> order of filter (optional: default 2nd order)
%
% returns -> filtered data

if nargin==4
	direction=2;
end;
if nargin==3 order=2; direction=2;end; % default to 2nd order

newdata = data;
success = 0;

% get filter paramters A and B
[B,A] = butter(order,cutoff/(samprate/2));
% perform filtering only when data long enough
% length restraint defined in filtfilt func.
if length(data) > 3 * max(length(B)-1,length(A)-1)
    if direction==2
        newdata = filtfilt(B,A,data);
        success = 1;
    else
        newdata = filter(B,A,data);
        newdata(1:50)=0;
        success = 1;
    end
end