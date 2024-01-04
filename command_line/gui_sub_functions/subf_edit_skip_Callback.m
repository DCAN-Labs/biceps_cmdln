function handles = subf_edit_skip_Callback(handles, skip)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if skip<0
    skip=handles.mc.skip;
    disp('Skip Vols found was invalid, resetting to default.')
end

handles.mc.skip=skip;
handles=count_remaining_frames(handles);
end