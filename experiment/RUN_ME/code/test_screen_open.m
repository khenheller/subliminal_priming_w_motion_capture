clear all;
clc;
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 0)
Screen('Preference', 'VisualDebugLevel', 4);
screens         =   Screen('Screens');
screenNumber  =   max(screens);
gray          =   128 * [1 1 1 1];
[w, wRect]  =  Screen('OpenWindow',screenNumber, gray);
pause(2);
sca;