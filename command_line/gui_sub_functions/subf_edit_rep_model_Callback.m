function [handles] = subf_edit_rep_model_Callback(handles,repetitions)
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here
temp = repetitions;
if temp<1
    temp=1;
end
handles.connectotyping_settings.repetitions=temp;
end