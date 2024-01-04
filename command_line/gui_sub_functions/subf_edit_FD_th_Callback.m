function [handles] = subf_edit_FD_th_Callback(handles, fd_thresh)

temp=fd_thresh;
if temp<0
    temp=0;
end
if temp>0.5
    temp=.5;
end
handles.mc.FD_th=round(temp,2);
handles.mc.tick=find(handles.mc.ticks>=handles.mc.FD_th,1);
handles=count_remaining_frames(handles);

end