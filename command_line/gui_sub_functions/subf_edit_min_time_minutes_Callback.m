function [handles] = subf_edit_min_time_minutes_Callback(handles,minutes)

temp=minutes;
if temp<0
    temp=0;
end

handles.mc.min_time_minutes=temp;
handles.mc.min_frames=floor(handles.mc.min_time_minutes*60/handles.mc.TR);

handles=count_remaining_frames(handles);
end