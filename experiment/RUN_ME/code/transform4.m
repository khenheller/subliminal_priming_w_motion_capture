function [OUT]=transform4(T4,Data);

% This is a generic function which transforms a set of n x 3 vectors (Data)
% using a standard 4 x 4 transformation matrix.

% Input:
% T4 --> 4 x 4 transformation matrix to go from coordinate system A to
% coordinate system B
% Data --> n x 3 list of vectors in coordinate system A

% Output:
% OUT --> n x 3 list of vectors in coordinate system B

% Created: Jan 19/05 by J. Lanovaz
% Updated: Jan 19/05
% *******************

T = T4(1:3,1:3);
d = T4(1:3,4);

OUT = ((T*Data') + repmat(d,1,size(Data,1)))';