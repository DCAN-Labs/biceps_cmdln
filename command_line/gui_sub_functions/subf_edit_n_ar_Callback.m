function [handles] = subf_edit_n_ar_Callback(handles, n_ar)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
temp = n_ar;
if temp<0
    temp=handles.connectotyping_settings.n_ar;
end

handles.connectotyping_settings.n_ar=temp;
handles=count_remaining_frames(handles);
end