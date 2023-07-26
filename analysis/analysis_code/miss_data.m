function varargout = miss_data(varargin)
% MISS_DATA MATLAB code for miss_data.fig
%      MISS_DATA, by itself, creates a new MISS_DATA or raises the existing
%      singleton*.
%
%      H = MISS_DATA returns the handle to a new MISS_DATA or the handle to
%      the existing singleton*.
%
%      MISS_DATA('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in MISS_DATA.M with the given input arguments.
%
%      MISS_DATA('Property','Value',...) creates a new MISS_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before miss_data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to miss_data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help miss_data

% Last Modified by GUIDE v2.5 18-Aug-2021 16:50:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @miss_data_OpeningFcn, ...
                   'gui_OutputFcn',  @miss_data_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before miss_data is made visible.
function miss_data_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
% varargin   command line arguments to miss_data (see VARARGIN)

% Storing inputs.
h.p = varargin{1};
% Take only x traj variable name.
x_traj_name = [varargin{2}{:,:}];
x_traj_name = reshape(x_traj_name, [], length(varargin{2}));
x_traj_name = x_traj_name(1,:);
h.x_traj_name = x_traj_name;
% Setting vars.
h.vars.String = x_traj_name;

% Choose default command line output for miss_data
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes miss_data wait for user response (see UIRESUME)
% uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = miss_data_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from h structure
varargout{1} = h.output;



function sub_Callback(hObject, eventdata, h)
% Hints: get(hObject,'String') returns contents of sub as text
%        str2double(get(hObject,'String')) returns contents of sub as a double


% --- Executes during object creation, after setting all properties.
function sub_CreateFcn(hObject, eventdata, h)
% hObject    handle to sub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_miss_data.
function Load_miss_data_Callback(hObject, eventdata, h)
% Get sub data.
real_traj_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_traj.mat']);  real_traj_table = real_traj_table.reach_traj_table;
proc_traj_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_traj_proc.mat']);  proc_traj_table = proc_traj_table.reach_traj_table;
data_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_data_proc.mat']);  data_table = data_table.reach_data_table;
% Remove practice
real_traj_table(real_traj_table.practice > 0, :) = [];
proc_traj_table(proc_traj_table.practice > 0, :) = [];
data_table(data_table.practice > 0, :) = [];
h.real_traj_table = real_traj_table;
h.proc_traj_table = proc_traj_table;
h.data_table = data_table;
% Get missing data trials.
var_names = real_traj_table.Properties.VariableNames;
miss_data = load([h.p.TESTS_FOLDER '/sub' h.sub.String{:} h.p.DAY '.mat']);  miss_data = miss_data.reach_test_res.miss_data;
% Keep only trajectories.
miss_data = miss_data(:, contains(var_names, ["_x_" "_y_" "_z_"]));
% Select one traj, according to selected var.
xyz_index = (h.vars.Value-1)*3 + 1 : h.vars.Value*3;
% Get missing trials nums.
h.trials.String = [' '; string(find(miss_data(:, xyz_index(1))))];
% Stores updated h.
guidata(hObject, h);



% --- Executes on selection change in vars.
function vars_Callback(hObject, eventdata, h)
% Hints: contents = cellstr(get(hObject,'String')) returns vars contents as cell array
%        contents{get(hObject,'Value')} returns selected item from vars

% --- Executes during object creation, after setting all properties.
function vars_CreateFcn(hObject, eventdata, h)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in trials.
function trials_Callback(hObject, eventdata, h)
% Hints: contents = cellstr(get(hObject,'String')) returns trials contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trials


% --- Executes during object creation, after setting all properties.
function trials_CreateFcn(hObject, eventdata, h)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, h)
real_color = 'or';
pre_norm_color = 'og';
proc_color = [0 0.4470 0.7410];
nans_color = '-c';
target_color = 'bo';
% Find selected var and trial.
selected_var = h.vars.String{h.vars.Value};
selected_trial = str2num(h.trials.String{h.trials.Value});
% Find the columns of traj, onset, offset.
traj_col = find(contains(h.real_traj_table.Properties.VariableNames, selected_var));
% Get traj.
real = h.real_traj_table{h.real_traj_table.iTrial==selected_trial, traj_col : traj_col+2};
pre_norm = h.pre_norm_traj_table{h.pre_norm_traj_table.iTrial==selected_trial, traj_col : traj_col+2};
proc = h.proc_traj_table{h.proc_traj_table.iTrial==selected_trial, traj_col : traj_col+2};
% Set first sample of 'real' as it's axis origin.
real = real - real(1,:);

% Flip
real(:,3) = real(:,3) * -1;
pre_norm(:,3) = pre_norm(:,3) * -1;

% Clear previous plots.
cla reset
% Plot real
hold on;
yyaxis right
plot(real(:,1),real(:,3), real_color, 'LineWidth',1);
plot(pre_norm(:,1),pre_norm(:,3), pre_norm_color, 'LineWidth',1);
% Plot proc
hold on;
yyaxis left;
plot(proc(:,1),proc(:,3)*100, 'Color', proc_color, 'LineWidth',2);

% Draw Nan area.
while ~isempty(real)
    first_nan = find(isnan(real(:,1)), 1, 'first');
    if isempty(first_nan)
        break;
    elseif first_nan == 1
        start = 1;
    else
        % Finds Point in proc closest to nans begining in real.
        start = min_dist(real(first_nan-1,:), proc);
    end
    real = real(first_nan : end, :);
    proc = proc(start : end, :);
    % Find first num after nans.
    first_num = find(~isnan(real(:,1)), 1, 'first');
    if isempty(first_num)
        break;
    else
        % Finds Point in proc closest to nans ending in real.
        finish = min_dist(real(first_num,:), proc);
    end
    plot(proc(1:finish, 1), proc(1:finish, 3), nans_color, 'LineWidth',2); 
    real = real(first_num : end, :);
    proc = proc(finish : end, :);
end
% Plot Target.
target_pos = h.p.DIST_BETWEEN_TARGETS/2;
plot([-target_pos target_pos], [100 100], target_color, 'LineWidth',6);
% Descriptors.
limx = target_pos + target_pos/4;
xlim([-limx  limx]);
ylim([-100 100]);
ylabel("% Path_z traveled")
yyaxis right
ylim([-h.p.SCREEN_DIST h.p.SCREEN_DIST]);
ylabel("Dist from starting point (on Z axis)")
title(['Sub ' h.sub.String{:} ', Trial: ' h.trials.String{h.trials.Value} ', Var: ' h.vars.String{h.vars.Value}]);
h1 = plot(NaN, NaN, real_color);
h2 = plot(NaN, NaN, pre_norm_color);
h3 = plot(NaN, NaN, '-', 'Color',proc_color, 'LineWidth',2);
h4 = plot(NaN, NaN, nans_color, 'LineWidth',2);
h5 = plot(NaN, NaN, target_color, 'LineWidth',6);
legend([h1, h2, h3, h4, h5], {'original', 'pre norm', 'proc', 'nans', 'Target'}, 'Location','northeastoutside');
set(gca,'FontSize',14);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

% Finds the point in 'traj' closest to 'point'.
function min_dist_i = min_dist(point, traj)
    dist_vec = sqrt(sum((traj - point).^2, 2));
    [~, min_dist_i] = min(dist_vec);


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, h)
% Key's ASCII value.
esc = 27;
right = 29;
left = 28;
input = 0;
Plot_Callback(hObject, eventdata, h)
while true
    % Waits until right arrow / left arrow / esc are pressed.
    axes(gca);
    pause();
    key = get(gcf, 'CurrentCharacter');
    switch key
        % Next trial.
        case right
            % If last trial, wrap around.
            if h.trials.Value == length(h.trials.String)
                h.trials.Value = 2;
            else
                h.trials.Value = h.trials.Value + 1;
            end
        % Prev trial
        case left
            % If first trial, wrap around.
            if h.trials.Value <= 2
                h.trials.Value = length(h.trials.String);
            else
                h.trials.Value = h.trials.Value - 1;
            end
        case esc
            break;
    end
    Plot_Callback(hObject, eventdata, h)
end


% --- Executes on button press in Pause.
function Pause_Callback(hObject, eventdata, handles)
% hObject    handle to Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Load_all.
function Load_all_Callback(hObject, eventdata, h)
% Get sub data.
real_traj_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_traj.mat']);  real_traj_table = real_traj_table.reach_traj_table;
proc_traj_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_traj_proc.mat']);  proc_traj_table = proc_traj_table.reach_traj_table;
pre_norm_traj_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_pre_norm_traj.mat']);  pre_norm_traj_table = pre_norm_traj_table.reach_pre_norm_traj_table;
data_table = load(['../processed_data/sub' h.sub.String{:} h.p.DAY '_reach_data_proc.mat']);  data_table = data_table.reach_data_table;
% Remove practice
real_traj_table(real_traj_table.practice > 0, :) = [];
proc_traj_table(proc_traj_table.practice > 0, :) = [];
pre_norm_traj_table(pre_norm_traj_table.practice > 0, :) = [];
data_table(data_table.practice > 0, :) = [];
h.real_traj_table = real_traj_table;
h.proc_traj_table = proc_traj_table;
h.pre_norm_traj_table = pre_norm_traj_table;
h.data_table = data_table;
% Get trials nums.
h.trials.String = [' '; string(1:h.p.NUM_TRIALS)'];
% Stores updated h.
guidata(hObject, h);
