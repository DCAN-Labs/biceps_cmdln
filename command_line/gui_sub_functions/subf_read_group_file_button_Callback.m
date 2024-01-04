function [handles] = subf_read_group_file_button_Callback(handles, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 1
    [FileName,handles.paths.group_file,FilterIndex] = uigetfile(...
        {'*.txt', 'Text file (*.txt)';...
        '*.*',  'All Files (*.*)'}, ...
        'Pick your group file');
    handles.groupFile=[handles.paths.group_file FileName];
else
    handles.groupFile = varargin{1};
end


[paths, ids, visit_folder, pipeline, full_path] = read_participants_and_paths(handles.groupFile);
handles.participants.N=length(ids);
handles.participants.paths=paths;
handles.participants.ids=ids;
handles.participants.visit_folder=visit_folder;
handles.participants.pipeline=pipeline;
handles.participants.full_path=full_path;
handles.participants.unique_ids=length(unique(ids));
handles.participants.unique_pipelines=length(unique(pipeline));
handles.text_after_reading_path=text_after_reading_path(handles);

% check if paths exist for all subjects and reset if they do not.
n=handles.participants.N; % count the individual studies
full_path=handles.participants.full_path;
fs=filesep;
motion_masks=cell(n,1);
for i=1:n
    
    opt=cell(5,1);
    opt{1} = strjoin([strtrim(full_path(i,:)) fs 'func' fs ids(i,:) '_' visit_folder(i,:) '_task-rest_motion_mask.mat'],'');
    opt{2} = strjoin([strtrim(full_path(i,:)) fs 'func' fs ids(i,:) '_' visit_folder(i,:) '_task-rest_bold_mask.mat'],'');
    opt{3} = strjoin([strtrim(full_path(i,:)) fs 'func' fs ids(i,:) '_' visit_folder(i,:) '_task-rest_desc-filtered_motion_mask.mat'],'');
    opt{4} = strjoin([strtrim(full_path(i,:)) fs 'func' fs ids(i,:) '_' visit_folder(i,:) '_task-rest_desc-filteredwithoutliers_motion_mask.mat'],'');
    opt{5} = strjoin([strtrim(full_path(i,:)) fs 'func' fs ids(i,:) '_' visit_folder(i,:) '_task-rest_acq-PrismaSingleBand_motion_mask.mat'],'');
    
    
    local_ix=find(isfile(opt));
    if isempty(local_ix)
        path_dot_mat_file=strtrim(ls([strjoin([strtrim(full_path(i,:)) fs 'func' fs ids(i,:) '_' visit_folder(i,:) '_task*rest*mask.mat'],'')]));
        motion_masks{i}=path_dot_mat_file;
    else
        motion_masks{i}=opt{local_ix(1)};
    end

end
handles.paths.motion_masks = motion_masks;
end
