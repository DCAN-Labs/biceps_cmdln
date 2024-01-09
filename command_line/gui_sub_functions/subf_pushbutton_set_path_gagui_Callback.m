function [handles] = subf_pushbutton_set_path_gagui_Callback(handles, output_path)
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here

[d1, d2, d3] = fileparts(handles.groupFile);
%if error comes from this function, then uncomment the
%next line...
%handles.env.path_group_list=d1;
handles.env.path_group_list=output_path;
handles.env.original_filename=d2;
handles.env.original_filename_ext=d3;

handles.env.path_gagui=output_path;

end