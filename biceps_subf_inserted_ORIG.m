function varargout = biceps_subf_inserted(varargin)
% BICEPS MATLAB code for biceps.fig
%      BICEPS, by itself, creates a new BICEPS or raises the existing
%      singleton*.
%
%      H = BICEPS returns the handle to a new BICEPS or the handle to
%      the existing singleton*.
%
%      BICEPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BICEPS.M with the given input arguments.
%
%      BICEPS('Property','Value',...) creates a new BICEPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before biceps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to biceps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help biceps

% Last Modified by GUIDE v2.5 15-Feb-2021 12:03:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @biceps_OpeningFcn, ...
    'gui_OutputFcn',  @biceps_OutputFcn, ...
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


% --- Executes just before biceps is made visible.
function biceps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to biceps (see VARARGIN)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Merge the figure handles with the biceps presets %%%%%%%%%%%%%%%%
[handles_presets, fs] = subf_biceps_OpeningFcn();
f = fieldnames(handles_presets);
for i = 1:length(f)
    handles.(f{i}) = handles_presets.(f{i});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



set(handles.radiobutton_none,'Value',handles.read_none);
set(handles.radiobutton_FD,'Value',handles.read_FD);
set(handles.radiobutton_power_2014_FD_only,'Value',handles.read_power_2014_FD_only);
set(handles.radiobutton_power_2014_motion,'Value',handles.read_power_2014_motion);
set(handles.checkbox_detect_outliers,'Value',handles.detect_outliers);

set(handles.text_FD_th,'string',make_text_FD_th(handles));

set(handles.edit_FD_th,'string',num2str(handles.mc.FD_th,'%4.4f'));
set(handles.edit_min_time_minutes,'string',num2str(handles.mc.min_time_minutes,'%4.4f'));
set(handles.edit_skip,'string',num2str(handles.mc.skip,'%4.0f'));
set(handles.edit_n_ar,'string',num2str(handles.connectotyping_settings.n_ar,'%4.0f'));
set(handles.checkbox_std,'Value',handles.env.flag(1));
set(handles.checkbox_no_auto,'Value',handles.env.flag(2));
set(handles.checkbox_mb_all,'Value',handles.env.flag(3));
set(handles.checkboxmb_few_frames,'Value',handles.env.flag(4));

set(handles.edit_part_model,'string',num2str(handles.connectotyping_settings.partition_model,'%4.4f'));
set(handles.edit_rep_svd,'string',num2str(handles.connectotyping_settings.repetitions,'%4.0f'));

set(handles.edit_rep_model,'string',num2str(handles.connectotyping_settings.repetitions,'%4.0f'));
set(handles.edit_min_frames,'string',handles.mc.min_frames);

set(handles.uibutton_parcels,'visible','off')
set(handles.edit_min_frames,'enable','off')
set(handles.pushbutton_make_environments,'visible','off')

handles = validate_path_wb_command(handles);

handles.save_raw_timecourses_flag=1;
handles.save_raw_timecourses_flag=handles.save_raw_timecourses_flag==1;
% Choose default command line output for biceps
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes biceps wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = biceps_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in read_group_file_button.
function read_group_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to read_group_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = subf_read_group_file_button_Callback(handles);
handles.output = hObject;

% handles=update_paths(handles);
set(handles.path_group_file_text,'string',[handles.paths.group_file FileName]);
set(handles.text_content_group_file,'visible','on')
set(handles.text_content_group_file,'string',handles.text_after_reading_path);
set(handles.radiobutton_none,'visible','on')
set(handles.radiobutton_FD,'visible','on')
set(handles.radiobutton_power_2014_FD_only,'visible','on')
% set(handles.radiobutton_power_2014_motion,'visible','on')
set(handles.pushbutton_scout_motion,'visible','on');

guidata(hObject, handles);


% --- Executes on button press in pushbutton_scout_motion.
function pushbutton_scout_motion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scout_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% flag to keep track of the motion censoring methods to be used

handles = subf_pushbutton_scout_motion_Callback(handles, 1);

set(handles.text_FD_th,'string',make_text_FD_th(handles));

set(handles.text6,'visible','on')
set(handles.text_7,'visible','on')
set(handles.text8,'visible','on')
set(handles.text12,'visible','on')

set(handles.edit_FD_th,'visible','on')
set(handles.edit_min_time_minutes,'visible','on')
set(handles.edit_skip,'visible','on')
set(handles.edit_n_ar,'visible','on')

set(handles.checkbox_detect_outliers,'visible','on');

set(handles.text9,'visible','on')
set(handles.text_FD_th,'string',make_text_FD_th(handles));
set(handles.text_FD_th,'visible','on')

set(handles.text10,'visible','on')
set(handles.text_survivors,'string',make_text_survivors(handles));
set(handles.text_survivors,'visible','on')

set(handles.pushbutton_show_histogram,'visible','on')
set(handles.pushbutton_find_timecourses,'visible','on')



handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in radiobutton_none.
function radiobutton_none_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_none
handles.read_none=get(handles.radiobutton_none,'Value');
if handles.read_none
    handles.read_FD=0;
    handles.read_power_2014_FD_only=0;
    handles.read_power_2014_motion=0;
end
set(handles.radiobutton_none,'Value',handles.read_none);
set(handles.radiobutton_FD,'Value',handles.read_FD);
set(handles.radiobutton_power_2014_FD_only,'Value',handles.read_power_2014_FD_only);
set(handles.radiobutton_power_2014_motion,'Value',handles.read_power_2014_motion);


handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in radiobutton_FD.
function radiobutton_FD_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_FD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_FD
handles.read_FD=get(handles.radiobutton_FD,'Value');
if handles.read_FD
    handles.read_none=0;
    handles.read_power_2014_FD_only=0;
    handles.read_power_2014_motion=0;
    
end
set(handles.radiobutton_none,'Value',handles.read_none);
set(handles.radiobutton_FD,'Value',handles.read_FD);
set(handles.radiobutton_power_2014_FD_only,'Value',handles.read_power_2014_FD_only);
set(handles.radiobutton_power_2014_motion,'Value',handles.read_power_2014_motion);

handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in radiobutton_power_2014_FD_only.
function radiobutton_power_2014_FD_only_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_power_2014_FD_only (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.read_power_2014_FD_only=get(handles.radiobutton_power_2014_FD_only,'Value');
if handles.read_power_2014_FD_only
    handles.read_none=0;
    handles.read_FD=0;
    handles.read_power_2014_motion=0;
end
set(handles.radiobutton_none,'Value',handles.read_none);
set(handles.radiobutton_FD,'Value',handles.read_FD);
set(handles.radiobutton_power_2014_FD_only,'Value',handles.read_power_2014_FD_only);
set(handles.radiobutton_power_2014_motion,'Value',handles.read_power_2014_motion);

handles.output = hObject;
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton_power_2014_FD_only


% --- Executes on button press in radiobutton_power_2014_motion.
function radiobutton_power_2014_motion_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_power_2014_motion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.read_power_2014_motion=get(handles.radiobutton_power_2014_motion,'Value');

if handles.read_power_2014_motion
    handles.read_none=0;
    handles.read_FD=0;
    handles.read_power_2014_FD_only=0;
end

set(handles.radiobutton_none,'Value',handles.read_none);
set(handles.radiobutton_FD,'Value',handles.read_FD);
set(handles.radiobutton_power_2014_FD_only,'Value',handles.read_power_2014_FD_only);
set(handles.radiobutton_power_2014_motion,'Value',handles.read_power_2014_motion);
handles.output = hObject;
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton_power_2014_motion



function edit_FD_th_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FD_th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp=str2double(get(hObject,'String'));
handles = subf_edit_FD_th_Callback(handles, temp);


set(hObject,'String',num2str(temp,'%4.2f'))
set(handles.text_FD_th,'string',make_text_FD_th(handles));
set(handles.text_FD_th,'visible','on')

set(handles.checkbox_detect_outliers,'value',0.0);
set(handles.text_survivors,'string',make_text_survivors(handles));

handles.output = hObject;
guidata(hObject, handles);


% Hints: get(hObject,'String') returns contents of edit_FD_th as text
%        str2double(get(hObject,'String')) returns contents of edit_FD_th as a double


% --- Executes during object creation, after setting all properties.
function edit_FD_th_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FD_th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_min_time_minutes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min_time_minutes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min_time_minutes as text
%        str2double(get(hObject,'String')) returns contents of edit_min_time_minutes as a double
temp=str2double(get(hObject,'String'));
subf_edit_min_time_minutes_Callback(handles, temp);


set(hObject,'String',num2str(temp,'%4.4f'))
set(handles.text_FD_th,'string',make_text_FD_th(handles));
set(handles.text_FD_th,'visible','on')

set(handles.text_survivors,'string',make_text_survivors(handles));
set(handles.checkbox_detect_outliers,'value',0.0);
handles.output = hObject;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_min_time_minutes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_time_minutes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_show_histogram.
function pushbutton_show_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_show_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
make_hist_surv(handles);


function edit_skip_Callback(hObject, eventdata, handles)
% hObject    handle to edit_skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_skip as text
%        str2double(get(hObject,'String')) returns contents of edit_skip as a double
temp=str2double(get(hObject,'String'));

set(hObject,'String',num2str(temp,'%4.0f'))
set(handles.text_FD_th,'string',make_text_FD_th(handles));
set(handles.text_FD_th,'visible','on')
set(handles.text_survivors,'string',make_text_survivors(handles));
set(handles.checkbox_detect_outliers,'value',0.0);
handles.output = hObject;
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit_skip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_n_ar_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n_ar as text
%        str2double(get(hObject,'String')) returns contents of edit_n_ar as a double
temp=str2double(get(hObject,'String'));
handles = subf_edit_n_ar_Callback(handles, temp);

set(hObject,'String',num2str(temp,'%4.0f'))
set(handles.text_FD_th,'string',make_text_FD_th(handles));
set(handles.text_FD_th,'visible','on')
set(handles.text_survivors,'string',make_text_survivors(handles));
set(handles.checkbox_detect_outliers,'value',0.0);
handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_n_ar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n_ar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_detect_outliers.
function checkbox_detect_outliers_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_detect_outliers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_detect_outliers
handles = subf_checkbox_detect_outliers_Callback(handles);
set(handles.text_survivors,'string',make_text_survivors(handles));
handles.output = hObject;
guidata(hObject, handles);




% --- Executes on button press in pushbutton_find_timecourses.
function pushbutton_find_timecourses_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_find_timecourses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = subf_pushbutton_find_timecourses_Callback(handles);


set(handles.uibutton_parcels,'visible','on')
set(handles.uipanel_connectotype,'visible','off')
set(handles.uibuttongroup_env,'visible','on')
n=length(handles.mc.surv_parcels);
%%
for i=1:n
    handles.cbh(i) =uicontrol(handles.uibutton_parcels,'Style','checkbox',...
        'String',handles.mc.surv_parcels{i},...
        'Value',0,'Position',[20 15*i 130 20]);
end

% handles.checkboxmb_few_frames
set(handles.edit_min_frames,'string',handles.mc.min_frames);
set(handles.pushbutton_set_path_gagui,'visible','on')


handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in checkbox_std.
function checkbox_std_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_std


% --- Executes on button press in checkbox_no_auto.
function checkbox_no_auto_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_no_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.env.flag(2)=get(hObject,'Value');
handles = subf_checkbox_no_auto_Callback(handles, handles.env.flag(2));
handles.output = hObject;
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_no_auto


% --- Executes on button press in checkbox_mb_all.
function checkbox_mb_all_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mb_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp=get(hObject,'Value');
handles = subf_checkbox_mb_all_Callback(handles,temp);

if sum(handles.env.flag(3:4))>0
    set(handles.uipanel_connectotype,'visible','on')
else
    set(handles.uipanel_connectotype,'visible','off')
end

handles.output = hObject;
guidata(hObject, handles);


% Hint: get(hObject,'Value') returns toggle state of checkbox_mb_all


% --- Executes on button press in checkboxmb_few_frames.
function checkboxmb_few_frames_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxmb_few_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxmb_few_frames
temp=get(hObject,'Value');
handles = subf_checkboxmb_few_frames_Callback(handles,temp);


if get(hObject,'Value')
    set(handles.text13,'visible','on');
    set(handles.text17,'visible','on');
    set(handles.edit_min_frames,'visible','on');
    set(handles.edit_rep_model,'visible','on');
    set(handles.edit_min_frames,'string',handles.mc.min_frames);
    set(handles.edit_rep_model,'string',handles.connectotyping_settings.repetitions);
    handles.env.name{4}=['connectotyping_' num2str(handles.connectotyping_settings.default_frames) '_frames'];
else
    set(handles.text13,'visible','off');
    set(handles.text17,'visible','off');
    set(handles.edit_min_frames,'visible','off');
    set(handles.edit_rep_model,'visible','off');
end

if sum(handles.env.flag(3:4))>0
    set(handles.uipanel_connectotype,'visible','on')
else
    set(handles.uipanel_connectotype,'visible','off')
end

handles.output = hObject;
guidata(hObject, handles);

if get(hObject,'Value')
end



function edit_min_frames_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min_frames as text
%        str2double(get(hObject,'String')) returns contents of edit_min_frames as a double
temp=str2double(get(hObject,'String'));
handles = subf_edit_min_frames_Callback(handles, temp);
set(handles.edit_min_frames,'string',num2str(handles.connectotyping_settings.default_frames,'%4.0f'));
handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_min_frames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_frames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% handles.env.name{4}=['connectotyping_' num2str(handles.connectotyping_settings.default_frames) '_frames'];
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_part_model_Callback(hObject, eventdata, handles)
% hObject    handle to edit_part_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_part_model as text
%        str2double(get(hObject,'String')) returns contents of edit_part_model as a double
temp=str2double(get(hObject,'String'));
handles = subf_edit_part_model_Callback(handles, partition_model);
set(hObject,'String',num2str(temp,'%4.2f'))

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_part_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_part_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rep_svd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rep_svd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rep_svd as text
%        str2double(get(hObject,'String')) returns contents of edit_rep_svd as a double
temp=str2double(get(hObject,'String'));
handles = subf_edit_rep_svd_Callback(handles, temp);
set(hObject,'String',num2str(temp,'%4.2f'))

handles.output = hObject;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_rep_svd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rep_svd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rep_model_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rep_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rep_model as text
%        str2double(get(hObject,'String')) returns contents of edit_rep_model as a double
temp=str2double(get(hObject,'String'));
handles = subf_edit_rep_model_Callback(handles, temp);
set(handles.edit_rep_model,'string',num2str(handles.connectotyping_settings.repetitions,'%4.0f'));
handles.output = hObject;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_rep_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rep_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_set_path_gagui.
function pushbutton_set_path_gagui_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_set_path_gagui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[d1, d2, d3] = fileparts(handles.groupFile);
temp=uigetdir(d1,'Path to save connectivity matrices');
[handles] = subf_pushbutton_set_path_gagui_Callback(handles, temp);
set(handles.pushbutton_make_environments,'visible','on');
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_make_environments.
function pushbutton_make_environments_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_make_environments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = subf_pushbutton_make_environments_Callback(handles);
handles.output = hObject;
guidata(hObject, handles);
