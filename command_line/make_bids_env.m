function make_bids_env(handles, gui)

%% Internal variables
fs=filesep;
env_folder=[handles.env.path_gagui fs ...,
    handles.env.name{1} fs,...
    handles.func_data_name fs,...
    handles.env.group];
if ~isfolder(env_folder)
    mkdir(env_folder);
end
change_permissions(handles,env_folder)
n_parcel=length(handles.mc.surv_parcels);


% Identify participants surviving motion censoring
surv=handles.mc.surv_ix;
% surv(:,1)=[]; %first column refers to standard, second one to model based
surv(:,2)=[]; %first column refers to standard, second one to model based
n_surv=sum(surv);
ix=find(surv);


n_frames = floor(handles.mc.min_frames);% identify the min frames set in th
n_surv_frames=handles.mc.n_surv_frames;
n_surv_frames=n_surv_frames(ix,:);
n_frames2= min(n_surv_frames);% identify the min number of frames after censoring (this number must be equal or larger that the previous one)
n_frames2(2:end)=[];

%% read mask
mask=cell(n_surv,3);
for i=1:n_surv
    mask{i,1}=handles.mc.surv_std{ix(i)};
    % get indices of remaining frames and randomly select n numder of
    % remaining frames where n is the minimum number of frames after
    % censoring
    mask{i,2}=zeros(length(handles.mc.surv_std{ix(i)}),1);
    if sum(handles.mc.surv_std{ix(i)}) >= n_frames2
        inc_frames_idx=find(handles.mc.surv_std{ix(i)}==1);
        sample_inc_frames_idx=datasample(inc_frames_idx, n_frames2,'Replace',false);
        mask{i,2}(sample_inc_frames_idx)=1;
    end
    mask{i,3}=zeros(length(handles.mc.surv_std{ix(i)}),1);
    if sum(handles.mc.surv_std{ix(i)}) >= n_frames
        inc_frames_idx=find(handles.mc.surv_std{ix(i)}==1);
        sample_inc_frames_idx=datasample(inc_frames_idx, n_frames,'Replace',false);
        mask{i,3}(sample_inc_frames_idx)=1;
    end
end


mask_file=[env_folder fs handles.env.std_mask_name];
save_planB(mask_file,mask);%n_frames

%% Read parcellated data
full_filenames_first_parc = {}; %later in the script this will help us find
                                %dtseries files if needed
for i=1:n_parcel
    
    % Identify parcel and preallocate memory
    if gui > 0
        j=strcmp(cat(1,{handles.cbh.String}'),strtrim(char(handles.mc.surv_parcels{i})));
        if handles.cbh(find(j)).Value == 0
            continue
        end
    end

    parcel_folder=[env_folder fs strtrim(char(handles.mc.surv_parcels{i}))];
    if ~isfolder(parcel_folder)
        mkdir(parcel_folder)
    end
    change_permissions(handles,parcel_folder)
    if handles.save_raw_timecourses_flag
        raw_tc=cell(n_surv,1);
    end

    handles.mc.min_frames;
    % read the first participant to preallocate memory for fconn
    j=1;
    %disp(['Processing participant ' num2str(j) ' out of ' num2str(n_surv) ' in parcel ' handles.mc.surv_parcels{i} ' (' num2str(i) ' out of ' num2str(n_parcel) '), standard']);
    path_to_nii=[strtrim(handles.participants.full_path(ix(j),:)) fs 'func'];

    try
        filename=strjoin([handles.participants.ids(ix(j),:) '_' handles.participants.visit_folder(ix(j),:) '*-rest*bold_atlas-' handles.mc.surv_parcels{i} '.nii'],'');
        local_filename=strtrim(ls([path_to_nii fs filename]));
    catch
        filename=strjoin([handles.participants.ids(ix(j),:) '_' handles.participants.visit_folder(ix(j),:) '*-rest*bold*-' handles.mc.surv_parcels{i} '.nii'],'');
        local_filename=strtrim(ls([path_to_nii fs filename]));
    end
    
    [group_folder,~,~] = fileparts(handles.groupFile);
    TEMP_RAW = read_cifti_via_csv (local_filename,quotes_if_space(handles.paths.wb_command), group_folder);
    
    temp_raw_masked=TEMP_RAW(:,mask{j,1});% mask raw timecourses
    if handles.save_raw_timecourses_flag
        raw_tc{j}=TEMP_RAW;
    end

    n_rois=size(TEMP_RAW,1);
    fconn=zeros(n_rois,n_rois,n_surv);
    
    file_names = {};
    for j=1:n_surv
        disp(['Processing participant ' num2str(j) ' out of ' num2str(n_surv) ' in parcel ' handles.mc.surv_parcels{i} ' (' num2str(i) ' out of ' num2str(n_parcel) '), standard']);
        path_to_nii=[strtrim(handles.participants.full_path(ix(j),:)) fs 'func'];
        filename=strjoin([handles.participants.ids(ix(j),:) '_' handles.participants.visit_folder(ix(j),:) '*-rest*bold_atlas-' handles.mc.surv_parcels{i} '.nii'],'');
        try
            filename=strjoin([handles.participants.ids(ix(j),:) '_' handles.participants.visit_folder(ix(j),:) '*-rest*bold_atlas-' handles.mc.surv_parcels{i} '.nii'],'');
            local_filename=strtrim(ls([path_to_nii fs filename]));
        catch
            filename=strjoin([handles.participants.ids(ix(j),:) '_' handles.participants.visit_folder(ix(j),:) '*-rest*bold*-' handles.mc.surv_parcels{i} '.nii'],'');
            local_filename=strtrim(ls([path_to_nii fs filename]));
        end

        %Grab the filename for later in case we want to use it to find
        %dense tseries files.
        if i == 1
            full_filenames_first_parc{j} = local_filename;
        end
        
        TEMP_RAW=read_cifti_via_csv(local_filename,quotes_if_space(handles.paths.wb_command), group_folder);
        raw_tc{j}=TEMP_RAW;

        [~, b, ~] = fileparts(local_filename);
        b_split = split(b, '.');
        file_names{j} = [b_split{1} '.mat'];


    end

    %NEW Part 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for j=1:n_surv
        fconn(:,:,j)=corr(raw_tc{j}(:,mask{j,1}==1).');
    end
    file_fconn='fconn_all_surv_frames.mat';
    %file_fconn=['fconn_' num2str(n_frames) '_frames.mat'];
    save_planB([parcel_folder fs file_fconn],fconn);

    if handles.save_bids
        
        clear standard_struct;
        standard_struct.fd_thresh_mm = handles.cmdln.fd_thresh;
        standard_struct.time_thresh_min = handles.cmdln.time_thresh_min;
        standard_struct.detect_outliers = handles.cmdln.detect_outliers;
        standard_struct.n_skip_vols = handles.cmdln.n_skip_vols;
        standard_struct.workbench_path = handles.cmdln.wb_command_path;
        standard_struct.validate_frame_counts = handles.cmdln.validate_frame_counts;
        
        
        
        for j = 1 : n_surv
            generic_name = file_names{j};
            if (contains(generic_name, '_bold') == false)
                error('Error BIDS output only supported for files with _bold in their name')
            end
    
            %Make output folder for given subject/session combo if it doesnt
            %exist
            output_folder = fullfile(handles.env.path_gagui, 'bids', handles.participants.ids{ix(j)}, handles.participants.visit_folder{ix(j)}, 'func');
            if ~exist(output_folder, 'dir')
                mkdir(output_folder);
            end

            %Save conn mat for minimum number of volumes
            temp_name = strrep(generic_name, '_bold', '_frames-MaxIndividual_bold');
            temp_name = strrep(temp_name, '.mat', '_desc-conn.mat');
            output_path = fullfile(output_folder, temp_name);
            ind_fconn = squeeze(fconn(:,:,j));
            save(output_path, 'ind_fconn');
            
            %Specific information for JSON file%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear conn_mat_struct;
            conn_mat_struct.subject = handles.participants.ids{ix(j)};
            conn_mat_struct.session = handles.participants.visit_folder{ix(j)};
            conn_mat_struct.good_frames_inds = int8(mask{j,1});
            conn_mat_struct.num_included_frames = sum(mask{j,1});
            conn_mat_struct.num_excluded_frames = length(mask{j,1}) - sum(mask{j,1});
            clear full_struct;
            full_struct.conn_mat_struct = conn_mat_struct;
            full_struct.standard_struct = standard_struct;
            json_content = jsonencode(full_struct, PrettyPrint=true);
            json_path = [output_path(1:end-3) 'json'];
            fid = fopen(json_path,'w'); 
            fprintf(fid,'%s',json_content);
            fclose(fid);
            
            if handles.cmdln.attempt_pconn > 0
                try
                    out_pconn = [output_path(1:end-3) 'pconn.nii'];
                    mat2cifti_2(ind_fconn, out_pconn, [], handles.paths.wb_command);
                catch
                    disp(['Unable to find candidate pconn template for conn. output: ' output_path]);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %NEW Part 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:n_surv
        fconn(:,:,j)=corr(raw_tc{j}(:,mask{j,2}==1).');
    end
    file_fconn=['fconn_' num2str(n_frames2) '_frames.mat'];
    save_planB([parcel_folder fs file_fconn],fconn);

    if handles.save_bids
        for j = 1 : n_surv
            generic_name = file_names{j};

            %Save conn mat for maximum number of volumes (same across
            %subjects)
            temp_name = strrep(generic_name, '_bold', '_frames-MaxGroup_bold');
            temp_name = strrep(temp_name, '.mat', '_desc-conn.mat');
            output_folder = fullfile(handles.env.path_gagui, 'bids', handles.participants.ids{ix(j)}, handles.participants.visit_folder{ix(j)}, 'func');
            output_path = fullfile(output_folder, temp_name);
            ind_fconn = squeeze(fconn(:,:,j));
            save(output_path, 'ind_fconn');
            
            %Specific information for JSON file%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear conn_mat_struct;
            conn_mat_struct.subject = handles.participants.ids{ix(j)};
            conn_mat_struct.session = handles.participants.visit_folder{ix(j)};
            conn_mat_struct.good_frames_inds = int8(mask{j,2});
            conn_mat_struct.num_included_frames = sum(mask{j,2});
            conn_mat_struct.num_excluded_frames = length(mask{j,2}) - sum(mask{j,2});
            clear full_struct;
            full_struct.conn_mat_struct = conn_mat_struct;
            full_struct.standard_struct = standard_struct;
            json_content = jsonencode(full_struct, PrettyPrint=true);
            json_path = [output_path(1:end-3) 'json'];
            fid = fopen(json_path,'w'); 
            fprintf(fid,'%s',json_content);
            fclose(fid);
            
            if handles.cmdln.attempt_pconn > 0
                try
                    out_pconn = [output_path(1:end-3) 'pconn.nii'];
                    mat2cifti_2(ind_fconn, out_pconn, [], handles.paths.wb_command);
                catch
                    disp(['Unable to find candidate pconn template for conn. output: ' output_path]);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %NEW Part 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:n_surv
        fconn(:,:,j)=corr(raw_tc{j}(:,mask{j,3}==1).');
    end
    %file_fconn='fconn_all_surv_frames.mat';
    file_fconn=['fconn_' num2str(n_frames) '_frames.mat'];
    save_planB([parcel_folder fs file_fconn],fconn);

    if handles.save_bids
        for j = 1 : n_surv
            generic_name = file_names{j};

            %Save conn mat for maximum number of volumes (different across
            %subjects)
            temp_name = strrep(generic_name, '_bold', '_frames-MinGroup_bold');
            temp_name = strrep(temp_name, '.mat', '_desc-conn.mat');
            output_folder = fullfile(handles.env.path_gagui, 'bids', handles.participants.ids{ix(j)}, handles.participants.visit_folder{ix(j)}, 'func');
            output_path = fullfile(output_folder, temp_name);
            ind_fconn = squeeze(fconn(:,:,j));
            save(output_path, 'ind_fconn');
            
            %Specific information for JSON file%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear conn_mat_struct;
            conn_mat_struct.subject = handles.participants.ids{ix(j)};
            conn_mat_struct.session = handles.participants.visit_folder{ix(j)};
            conn_mat_struct.good_frames_inds = int8(mask{j,3});
            conn_mat_struct.num_included_frames = sum(mask{j,3});
            conn_mat_struct.num_excluded_frames = length(mask{j,3}) - sum(mask{j,3});
            clear full_struct;
            full_struct.conn_mat_struct = conn_mat_struct;
            full_struct.standard_struct = standard_struct;
            json_content = jsonencode(full_struct, PrettyPrint=true);
            json_path = [output_path(1:end-3) 'json'];
            fid = fopen(json_path,'w'); 
            fprintf(fid,'%s',json_content);
            fclose(fid);
            
            if handles.cmdln.attempt_pconn > 0
                try
                    out_pconn = [output_path(1:end-3) 'pconn.nii'];
                    mat2cifti_2(ind_fconn, out_pconn, [], handles.paths.wb_command);
                catch
                    disp(['Unable to find candidate pconn template for conn. output: ' output_path]);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp(['Saving data from parcel ' handles.mc.surv_parcels{i} ' (' num2str(i) ' out of ' num2str(n_parcel) ')']);
    if handles.save_raw_timecourses_flag
        save_planB([parcel_folder fs handles.env.raw_tc],raw_tc);
    end

    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Code for dtseries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(handles, 'calc_dense_conns') > 0

    %% Read dense data
    for i = 1:length(full_filenames_first_parc)
        temp_parcellated = full_filenames_first_parc{i};
        file_ending = strfind(temp_parcellated, '_bold');
        partial_name = temp_parcellated(1:file_ending(end));
        search_criteria = [partial_name '*dtseries.nii'];

        %Need to use this to find the name of the input dtseries,
        %then find path for output dtseries, and pass along skip vols
        %to the right function...
        matching_files = dir(search_criteria);
        if length(matching_files) ~= 1
            error(['Error: exactly one file must be found for matching pattern following: ' search_criteria]);
        end

        input_folder = matching_files(1).folder;
        input_filename = matching_files(1).name; %this will be the only matching file
        output_folder = fullfile(handles.env.path_gagui, 'bids', handles.participants.ids{ix(i)}, handles.participants.visit_folder{ix(i)}, 'func');
        subject_masks = mask(i,:);
        mask_descriptions = {'frames-MaxIndividual', 'frames-MaxGroup', 'frames-MinGroup'};
        make_dense_conns(input_folder, input_filename, output_folder, subject_masks, mask_descriptions, ...
                         handles.dtseries_smoothing_kernel, handles.left_hem_for_smoothing, handles.right_hem_for_smoothing, handles.paths.wb_command)

        %Specific information for JSON file%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%THIS IS COPIED FROM AN ABOVE SECTION AND HASNT BEEN
        %ADAPTED FOR THIS PART OF THE CODE YET... KEEPING THIS
        %COMMENTED SECTION BELOW FOR REFERENCE
        %clear conn_mat_struct;
        %conn_mat_struct.subject = handles.participants.ids{ix(j)};
        %conn_mat_struct.session = handles.participants.visit_folder{ix(j)};
        %conn_mat_struct.good_frames_inds = int8(mask{j,2});
        %conn_mat_struct.num_included_frames = sum(mask{j,2});
        %conn_mat_struct.num_excluded_frames = length(mask{j,2}) - sum(mask{j,2});
        %clear full_struct;
        %full_struct.conn_mat_struct = conn_mat_struct;
        %full_struct.standard_struct = standard_struct;
        %json_content = jsonencode(full_struct, PrettyPrint=true);
        %json_path = [output_path(1:end-3) 'json'];
        %fid = fopen(json_path,'w'); 
        %fprintf(fid,'%s',json_content);
        %fclose(fid);

    end
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%