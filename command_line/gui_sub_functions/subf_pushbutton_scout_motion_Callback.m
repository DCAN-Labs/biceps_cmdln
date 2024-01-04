function [handles] = subf_pushbutton_scout_motion_Callback(handles, gui)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% flag to keep track of the motion censoring methods to be used
motions(1)=handles.read_none;
motions(2)=handles.read_FD;
motions(3)=handles.read_power_2014_FD_only;
motions(4)=handles.read_power_2014_motion;
handles.mc.motions=motions;

n=handles.participants.N; % count the individual studies
ticks=handles.mc.ticks; %read the brakes in FD from the settings
n_ticks=length(ticks);% count the possible number of FD's, 0: 0.01: 0.5
full_path=handles.participants.full_path;
frames=cell(n,1);
fs=filesep;
frame_removal=cell(n,1);
has_variance_flag=zeros(n,1);

% Start reading the total number of frames per study
for i=1:n
    disp(['Reading frames count for participant ' num2str(i) ' out of ' num2str(n)])
    load(handles.paths.motion_masks{i});
    frames{i} = motion_data{1,1}.total_frame_count;
    
    % check if variance file exist
    has_variance_flag(i) = has_variance_file(handles.paths.motion_masks{i});
    
end
handles.mc.frames=frames;
disp('Done reading frames count')
disp(' ')

% Preallocate memory to read the motion censored frames
TR=zeros(n,1);
if motions(2)
    FD=zeros(n,n_ticks);
    FD_TR=zeros(n,1);
    cat_FD=cell(n,1);
end

if motions(3)
    FD_power_2014_FD_only=zeros(n,n_ticks);
    FD_power_2014_FD_only_TR=zeros(n,1);
    cat_FD_power_2014_FD_only=cell(n,1);
end

if motions(4)
    FD_power_2014_motion=zeros(n,n_ticks);
    FD_power_2014_motion_TR=zeros(n,1);
    cat_FD_power_2014_motion=cell(n,1);
end

motion_found=zeros(n,3); % to keep track of guys without a particular motion censoring dataset

% Read the motion numbers
tic
for i=1:n
    %path_to_motion = [strtrim(full_path(i,:)) fs handles.paths.append_path_motion_numbers];
    path_to_motion = [strtrim(full_path(i,:)) fs 'func'];
    disp(['Reading motion numbers from participant ' num2str(i) ' out of ' num2str(n)])
    filename=handles.paths.motion_masks{i};
    load(filename);
    frames{i} = motion_data{1,1}.total_frame_count;
    
    if motions(3)
        %filename = [strtrim(full_path(i,:)) fs handles.paths.matlab_code_with_EPI];
        %filename = [strtrim(full_path(i,:)) fs handles.paths.matlab_code_with_EPI];
        %TR(i) = read_TR_MC_none(filename);frame_removal
        TR(i) = motion_data{1,1}.epi_TR;
        [FD_power_2014_FD_only(i,:) cat_FD_power_2014_FD_only{i} TR(i) frame_removal{i}]=read_motion_data(filename,n_ticks);
        motion_found(i,2)=1;
    end
    
    
end
handles.mc.frame_removal=frame_removal;

disp(['Done'])
toc


uTRs=unique(TR);
nTRs=length(uTRs);
if nTRs==1
    handles.mc.TR=uTRs;
else
    disp(['you are combining data with ' num2str(nTRs) ' distinct TR''s: '])
end
for i=1:nTRs
    disp(['TR ' num2str(i) ' = ' num2str(uTRs(i),'%4.4f') ' seconds, present in ' num2str(sum(TR==uTRs(i))) ' participants'])
end

if sum(uTRs==0)>0
    temp_ix=find(TR==0);
    n_temp_ix=length(temp_ix);
    disp ('Indices of participants with TR = 0')
    disp(temp_ix)
end

tick=find(ticks>=handles.mc.FD_th,1);
handles.mc.tick=tick;
handles=count_remaining_frames(handles);

% save FD
handles.mc.orig_surv_std=handles.mc.surv_std;
handles.mc.orig_surv_mb=handles.mc.surv_mb;

% calculate outliers
handles.mc.outlier_mask_std=cell(handles.participants.N,1);
handles.mc.outlier_mask_mb=cell(handles.participants.N,1);
if (gui == 1) || strcmp(handles.alternative_path_variances, '')
    alternative_path_variances=ask_for_alternative_path_variance(has_variance_flag, gui, handles);
    handles.alternative_path_variances=alternative_path_variances;
end
handles = make_outliers_mask(handles);


end