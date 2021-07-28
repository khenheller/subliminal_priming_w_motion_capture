function [Tout]=inv4x4(Tin)

% Utility function to get inverse of standard 4x4 transformation matrix.

% Tin must have the form:
% R11 R12 R13 d1
% R21 R22 R23 d2
% R31 R32 R33 d3
%   0   0   0  1

% Created: July 26/04 by J. Lanovaz
% Updated: July 26/04
% *******************

T = Tin(1:3,1:3);
d = Tin(1:3,4);
d2 = T'*(-d);
Tout = [T' d2;[0 0 0 1]];
