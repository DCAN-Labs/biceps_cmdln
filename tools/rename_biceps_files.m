function rename_biceps_files(out_dir)
%RENAME_BICEPS_FILES Renames BICEPS .txt files and associated folders based on embedded metadata.
%
%   rename_biceps_files(out_dir)
%
%   This function searches the given directory for BICEPS-formatted .txt files
%   that include 'FD_th_', 'min_frames_', and 'TRseconds_' in their names.
%   It then:
%     - Extracts metadata using encode_time_min_list_biceps
%     - Renames each .txt file to a standardized filename
%     - Moves associated folders under 'standard/Functional' to match the new names
%
%   Input:
%     out_dir : string
%         Full path to the directory containing BICEPS .txt files and
%         'standard/Functional' folder with matching subdirectories.
%
%   Dependencies:
%     - encode_time_min_list_biceps (must be in MATLAB path)
%
%   Example:
%     rename_biceps_files('/my/output/folder');

    if nargin < 1 || ~isfolder(out_dir)
        error('Please provide a valid path to the output directory.');
    end

    root = out_dir;
    output_root = out_dir;

    % Find all .txt files in the directory
    file_list = dir(fullfile(root, '*.txt'));

    % Filter BICEPS-formatted filenames
    pattern_files = file_list( ...
        contains({file_list.name}, 'FD_th_') & ...
        contains({file_list.name}, 'min_frames_') & ...
        contains({file_list.name}, 'TRseconds_') ...
    );

    if isempty(pattern_files)
        disp('No matching BICEPS .txt files found.');
        return;
    end

    % Process each matching file
    for j = 1:numel(pattern_files)
        orig_filename = fullfile(root, pattern_files(j).name);
        stripped_orig_name = pattern_files(j).name(1:end-4);

        % Generate new filename from metadata
        [new_filename, T] = encode_time_min_list_biceps(orig_filename);

        % Move and rename the .txt file
        new_txt_path = fullfile(root, new_filename);
        movefile(orig_filename, new_txt_path);

        % Move associated folder
        stripped_name = new_filename(1:end-4);  % remove .csv
        old_folder = fullfile(output_root, 'standard', 'Functional', stripped_orig_name);
        new_folder = fullfile(output_root, 'standard', 'Functional', stripped_name);
        if isfolder(old_folder)
            movefile(old_folder, new_folder);
        else
            warning('Missing folder: %s', old_folder);
        end

        disp(['Done with file ' num2str(j) ' of ' num2str(numel(pattern_files))]);
    end

    disp('All files processed successfully.');
end
