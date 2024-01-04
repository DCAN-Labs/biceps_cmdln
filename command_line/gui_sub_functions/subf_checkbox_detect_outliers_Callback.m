function [handles] = subf_checkbox_detect_outliers_Callback(handles, gui)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
handles=count_remaining_frames(handles);
handles.mc.orig_surv_std=handles.mc.surv_std;
handles.mc.orig_surv_mb=handles.mc.surv_mb;

if gui == 0
    handles = setfield(handles, 'checkbox_detect_outliers','Value',handles.cmdln.detect_outliers);
end

if handles.checkbox_detect_outliers.Value
    for i=1:handles.participants.N
        handles.mc.surv_std{i} = handles.mc.orig_surv_std{i} .* handles.mc.outlier_mask_std{i}==1;
        handles.mc.surv_mb{i} = handles.mc.orig_surv_mb{i} .* handles.mc.outlier_mask_mb{i}==1;
        handles.mc.n_surv_frames(i,1)=sum(handles.mc.surv_std{i});
        handles.mc.n_surv_frames(i,2)=sum(handles.mc.surv_mb{i});
        
    end
else
    for i=1:handles.participants.N
        handles.mc.surv_std{i} = handles.mc.orig_surv_std{i};
        handles.mc.surv_mb{i} = handles.mc.orig_surv_mb{i};
        handles.mc.n_surv_frames(i,1)=sum(handles.mc.surv_std{i});
        handles.mc.n_surv_frames(i,2)=sum(handles.mc.surv_mb{i});
    end
end
handles.mc.surv_ix=handles.mc.n_surv_frames>handles.mc.min_frames;

end