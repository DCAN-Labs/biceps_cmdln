function success=check_and_patch_variance(input_folder)
% CHECK_AND_PATCH_VARIANCE Check for variance files in func folders and patch if missing
%
% success==0 when the patches need to be run
% success==1 when the directory is complete
% Assumes structure like: input_folder/sub-XX/ses-XX/func/*timeseries*variance*.txt

    pattern = '*timeseries*variance*.txt';
    max_depth = 2;  % Looks for func folders at this depth

    % Find all func directories
    func_dirs = get_path_to_file(input_folder, max_depth, 'func');
    
    missing_flag = false;

    % Check each func directory for matching file
    for i = 1:numel(func_dirs)
        variance_files = get_path_to_file(func_dirs{i}, 0, pattern);
        if isempty(variance_files)
            missing_flag = true;
            break; % One missing is enough to trigger the patch
        end
    end

    if missing_flag
        disp('Missing variance files detected. Running scout and patching...');
        success=0;

        preffix = 'biceps_cmdln_';
        [~, ~, ~, ~] = scout_bids_for_gui_env(input_folder, ...
            'preffix', preffix, 'depth', max_depth);

        % Run variance patch
        list_file = fullfile(pwd, [preffix 'list.txt']);
        dtvariance_patch(list_file);
    else
        disp('All variance files present. No patching needed.');
        success=1;
    end
end
