function [handles] = subf_pushbutton_make_environments_Callback(handles, gui, to_do)
%UNTITLED19 Summary of this function goes here
%   Detailed explanation goes here

filename_censored_data=make_filename_censored_data(handles);
handles.env.group=filename_censored_data;
make_file_censored_data(handles);


handles.save_raw_timecourses_flag=ask_save_raw_timecourses(to_do);
if handles.env.flag(1)
    %make_std_env(handles, gui);
    make_bids_env(handles, gui);
    disp ('Done calculating correlation matrices!');
end

if handles.env.flag(2)
    make_no_autocorrelation_env(handles);
    disp ('Done calculating correlation matrices with no autocorrelation!');
end

if or(handles.env.flag(3),handles.env.flag(4))
    make_model_based_env(handles);
end

disp ('Thank you for using BICEPS to calculate connectivity matrices!');

end