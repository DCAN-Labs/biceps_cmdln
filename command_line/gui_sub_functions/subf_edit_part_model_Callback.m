function [handles] = subf_edit_part_model_Callback(handles,partition_model)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here

temp = partition_model;
if temp<0
    temp=0;
end
if temp>99
    temp=99;
end
handles.connectotyping_settings.partition_model=temp;

end