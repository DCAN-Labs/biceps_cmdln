function [handles] = subf_edit_min_frames_Callback(handles, min_frames)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

temp = min_frames;
if temp<handles.mc.min_frames
    temp=handles.mc.min_frames;
end
handles.connectotyping_settings.default_frames=temp;

end