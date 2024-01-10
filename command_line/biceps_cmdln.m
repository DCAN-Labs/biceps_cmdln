function biceps_cmdln(varargin)
%BICEPS_CMDLN Command Line Interface for BICEPS
%   This function can be interacted with through either
%   a graphical user interface or through the command
%   line. To access the gui, simply run the biceps_cmdln
%   function without any arguments.
%
%   GUI example: >> biceps_cmdln
%
%   To interact with biceps through the command line,
%   the user must at least provide one input which is
%   either (1) a string pointing to the list of ptseries
%   files to be processed with biceps, or (2) a string
%   pointing to a BIDS directory with ptseries.nii files
%   having roi-XXX key value pair that will be aggregated
%   for processing. Beyond that, there are a series of 
%   arguments that can be entered as key/value
%   pairs, such that the key and value are entered as
%   sequential arguments to the biceps_cmdln function.
%   Some example usages are:
%
%   >> biceps_cmdln list_to_proc.txt
%
%   >> biceps_cmdln list_to_proc.txt -fd 0.5
%   or equivalently
%   >> biceps_cmdln('list_to_proc.txt', '-fd', 0.5)
%
%   The key/value pairs supported by biceps_cmdln are
%   as follows:
%
%   "-fd": float
%      The framewise displacement threshold in mm, default
%      value 0.2
%   "-minutes": float
%      The minimum amount of data a subject must have to be
%      included in processing, measured in minutes. Default
%      value = 8 min.
%   "-outlier": boolean
%      Whether to remove outliers, default true
%   "-out_dir" : string
%      Path to wher BICEPS output should be stored. Default option is
%      in current working directory.
%   "-save_bids" : int
%      Set to a positive number if you want the output to be saved in
%      BIDS on top of standard BICEPS output format. Default is to not
%      save in this way.
%   "-validate_frame_counts": int
%      Set to a positive number if you want to validate that all runs
%      have the same number of frames.
%   "-n_skip_vols": int
%      The number of frames to skip at the beginning of every scan. Default
%      is 5.
%   "-save_timeseries": int
%      Set to positive value if you want to save the timeseries.
%   "-wb_command_path": string
%      Set the path to wb_command from HCP. By default BICEPS will try
%      to find this path on its own.
%   "-make_dense_conns": int
%      Set to positive number to make dconn files from dtseries.
%   "-dtseries_smoothing": float
%      The amount of smoothing to use, for both surface and volume space,
%      in millimeters (sigma of gaussian kernel). This only is used if 
%      -make_dense_conns flag is activated.
%   "-left_hem_surface": string
%      The path to the left hemisphere to use for smoothing. If
%      -dtseries_smoothing > 0 and no input is provided here, smoothing
%      will use the default fslr midthicknes file stored in BICEPS. It is
%      better for this to point to the actual midthickness file for a given
%      subject. If that is the case, processing can only occur one subject
%      at a time since it is only possible to give inputs for one surface.
%   "-right_hem_surface": string
%      The path to the right hemisphere to use for smoothing. See
%      description from left_hem_surface for more info.
%   "-attempt_pconn": 0 or 1, default 0
%      Set to 1 if you want BICEPS to try making .pconn.nii files out
%      of the generated connectivity matrices. Default = 0
%   "-custom_dtvar_folder": string
%      If an empty string is provided (i.e. ''), BICEPS will produce look
%      for dtvariance files found next to the the ptseries files. If
%      dtvariance files are not found at this location, you can provide
%      the path to a folder where all dtvariance files are found directly
%      within the folder specified (i.e. NOT BIDS organized)
%
%
%   Debugging - if you are having issues related to wb_command,
%   be sure all the right files are on your path. 
%
%   Issues, validating frame count doesn't work (seems like an issue
%   with matlab symbolic links.
%
%   Remove autocorrelation function doesn't exist
%
%

disp('Starting up BICEPS!')

%Run via GUI
if nargin == 0
    biceps_subf_inserted;
%Run via Command Line
else
    [handles, ~] = subf_biceps_OpeningFcn();
    if mod(nargin,2) ~= 1
        error('Error: biceps_cmdln expects either zero arguments (for GUI) or an odd number of arguments (1 arg for subject info, and key/flag pairs for remaining arguments.')
    end

    allowed_arguments = {'-out_dir', '-fd', '-minutes', ...
        '-outlier', '-validate_frame_counts', '-custom_dtvar_folder', ...
        '-make_dense_conns', '-dtseries_smoothing', '-left_hem_surface', ...
        '-right_hem_surface', '-n_skip_vols', '-attempt_pconn', ...
        '-save_timeseries', '-wb_command_path', '-save_bids'};

    keys = {};
    values = {};
    iter = 1;
    for i = 2:2:nargin
        check_if_proper_key(varargin{i}, allowed_arguments);
        keys{iter} = varargin{i};
        values{iter} = varargin{i+1};
        iter = iter + 1;
        disp(varargin{i});
        disp(varargin{i+1});
    end

    %Set output path
    default_output = fullfile(pwd, 'biceps_fconn');
    output_path = grab_from_input(keys, values, '-out_dir', default_output);
    disp(output_path);
    if isdir(output_path) == 0
        mkdir(output_path)
    end

    %If the first argument is a directory, use it to make a file list,
    %otherwise accept it as the path to a file list
    subject_info = varargin{1}; %add support for either text file or bids dir
    if isfolder(subject_info)
        file_list_path = fullfile(output_path, 'biceps_file_list.txt');
        make_file_list(subject_info, file_list_path);
        subject_info = file_list_path;
    end

    %1. Input dir
    %2. fd
    %3. minutes
    %4. outlier
    %5. validate frames
    %6. parcellation name
    %7. save timeseries
    %wb_command_path
    %
    
    %Set value for framewise displacement
    fd_thresh = grab_from_input(keys, values, '-fd', 0.2);
    handles.cmdln.fd_thresh = fd_thresh;
    
    %Set minimum time threshold (in minutes)
    time_thresh = grab_from_input(keys, values, '-minutes', 8);
    handles.cmdln.time_thresh_min = time_thresh;
    
    %Set outlier flag
    handles.cmdln.detect_outliers = grab_from_input(keys, values, '-outlier', 1);
    %%double check why this output isn't used right now
    
    %Not applicable model based settings
    remove_autocorr = false; %don;t run model based
    ac_terms = 0; %don;t run model based
    mb_few_frames = 0; %don;t run model based
    mb_all_frames = 0; %don't run model based

    %Whether to validate frame counts (0 for skip, pos number for checking)
    validate_frame_counts = grab_from_input(keys, values, '-validate_frame_counts', 0);
    handles.cmdln.validate_frame_counts = validate_frame_counts;

    handles.alternative_path_variances = grab_from_input(keys, values, '-custom_dtvar_folder', '');

    %Calculate dense conns
    calc_dense_conns = grab_from_input(keys, values, '-make_dense_conns', 0);
    handles.cmdln.calc_dense_conns = calc_dense_conns;

    %Smoothing kernel for dense conns
    handles.dtseries_smoothing_kernel = grab_from_input(keys, values, '-dtseries_smoothing', 0);
    left_hem_for_smoothing = grab_from_input(keys, values, '-left_hem_surface', '');
    right_hem_for_smoothing = grab_from_input(keys, values, '-right_hem_surface', '');

    %n skip vols
    skip_vols = grab_from_input(keys, values, '-n_skip_vols', 5);
    handles.cmdln.n_skip_vols = skip_vols;
    
    handles.cmdln.attempt_pconn = grab_from_input(keys, values, '-attempt_pconn', 0);

    %Save timeseries
    save_ts = grab_from_input(keys, values, '-save_timeseries', 0);
    if save_ts == 0
        save_ts = -1;
    end

    %workbench command path
    wb_command_path = grab_from_input(keys, values, '-wb_command_path', '/wb_code/workbench/bin_linux64/wb_command');
    handles.cmdln.wb_command_path = wb_command_path;
    
    handles = setfield(handles, 'paths', 'wb_command', wb_command_path);
    handles.save_bids = grab_from_input(keys, values, '-save_bids', 0);

    %Figure out settings for computing dense connectivity matrices (if
    %applicable)
    if calc_dense_conns
        handles.calc_dense_conns = 1;
        if length(left_hem_for_smoothing) && length(right_hem_for_smoothing)
            handles.left_hem_for_smoothing = left_hem;
            handles.right_hem_for_smoothing = right_hem;
        else
            script_path = which('biceps_cmdln');
            split_spot = strfind(script_path, filesep);
            biceps_path = script_path(1:split_spot(end - 1))
            handles.left_hem_for_smoothing = [biceps_path 'data/fslr_surface/Q1-Q6_RelatedParcellation210.L.midthickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii'];
            handles.right_hem_for_smoothing = [biceps_path 'data/fslr_surface/Q1-Q6_RelatedParcellation210.R.midthickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii'];
            disp('Smoothing of dtseries will use fslr surface instead of native surface. This is not recommended. If you have a native space surface, you should use that instead!');
        end
    end

    %Run through the various elements of biceps that are normally
    %managed via the GUI.
    handles = subf_read_group_file_button_Callback(handles, subject_info);
    handles = subf_pushbutton_scout_motion_Callback(handles, 0);
    handles = subf_edit_FD_th_Callback(handles, fd_thresh);
    handles = subf_edit_min_time_minutes_Callback(handles, time_thresh);
    handles = subf_edit_skip_Callback(handles,skip_vols);
    handles = subf_edit_n_ar_Callback(handles, ac_terms);
    handles = subf_checkbox_detect_outliers_Callback(handles, 0);
    handles = find_parcellated_paths(handles, validate_frame_counts); %this is subfunc of subf_pushbutton_find_timecourses_Callback
    handles = subf_checkbox_no_auto_Callback(handles, remove_autocorr);
    handles = subf_checkbox_mb_all_Callback(handles,mb_all_frames);
    handles = subf_checkboxmb_few_frames_Callback(handles,mb_few_frames);
    handles = subf_pushbutton_set_path_gagui_Callback(handles, output_path);
    handles = subf_pushbutton_make_environments_Callback(handles, 0, save_ts);

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = grab_from_input(all_keys, all_values, key_to_check, default_value)
%GRAB_FROM_INPUT Internal function to help parse input
%   all_keys - cell array with all the keys from varargin
%   all_values - cell array with the corresponding values
%                from varargin
%   key_to_check - string to look for in all_keys. If the
%                  string is found 0 times, function will
%                  return nan. If the string is found once,
%                  the function will return the corresponding
%                  value from all_values. If the string is found
%                  twice, the function will raise an error.

key_inds = find(strcmp(all_keys, key_to_check));
if length(key_inds) < 1
    output = default_value;
elseif length(key_inds) == 1
    output = all_values{key_inds};
else
    error(['Error: key ' key_to_check ' was found more than once in the input.'])
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function check_if_proper_key(key, allowed_arguments)

key_allowed = 0;
for i = 1 : length(allowed_arguments)
    if strcmp(key, allowed_arguments{i})
        key_allowed = 1;
    end
end
if key_allowed == 0
    disp('One of the biceps_cmdln input arguments is not allowed: ')
    disp(key)
    disp('Allowable biceps_cmdln input arguments are listed below: ')
    disp(allowed_arguments)
    error('Error: unknown argument was passed, see above messages for details')
end
end