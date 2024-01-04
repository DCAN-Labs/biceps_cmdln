function [handles] = subf_pushbutton_set_path_gagui_Callback(handles, output_path)
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here

[d1, d2, d3] = fileparts(handles.groupFile);
handles.env.path_group_list=d1;
handles.env.original_filename=d2;
handles.env.original_filename_ext=d3;

handles.env.path_gagui=output_path;

end