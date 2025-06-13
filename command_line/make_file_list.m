function make_file_list(input_bids_directory, output_file_list_path)
%MAKE_FILE_LIST 
%
% This function looks for all files ending in .ptseries.nii in the
% input_bids_directory. BIDS structure with/without sessions is assumed.
% Within the .ptseries files, the script will look for the parcellation
% name (using either 'roi-*' or the token before 'timeseries') to figure 
% out which parcellations are most common. All sessions (or subjects) 
% with the most frequently found parcellation will be written to 
% output_file_list_path.

% Ensure trailing slash is removed
if input_bids_directory(end) == filesep
    input_bids_directory = input_bids_directory(1:end-1);
end

% Find all *.ptseries.nii files (with or without sessions)
output_files = dir([input_bids_directory filesep '*' filesep '*' filesep 'func' filesep '*.ptseries.nii']);
if isempty(output_files)
    output_files = dir([input_bids_directory filesep '*' filesep 'func' filesep '*.ptseries.nii']);
end

% Confirm presence of ptseries files
if isempty(output_files)
    error(['Error: no files with ending *.ptseries.nii found in BIDS directory ' input_bids_directory '.']);
end

% Extract parcellation tokens
rois = cell(size(output_files));
session_folders = cell(size(output_files));
for i = 1:length(output_files)
    tokens = split(output_files(i).name, '_');
    roi_token = '';
    
    % Preferred: look for 'roi-*' token
    for j = 1:length(tokens)
        if contains(tokens{j}, 'roi-')
            roi_token = tokens{j};
            break;
        end
    end
    
    % Fallback: use token before 'timeseries'
    if isempty(roi_token)
        timeseries_index = find(contains(tokens, 'timeseries'), 1);
        if ~isempty(timeseries_index) && timeseries_index > 1
            roi_token = tokens{timeseries_index - 1};
        end
    end
    
    % Error if still not found
    if isempty(roi_token)
        error(['Error: Could not determine parcellation in ' output_files(i).name]);
    end

    rois{i} = roi_token;
    session_folders{i} = output_files(i).folder;
end

% Count frequency of each roi
num_files_per_roi = zeros(size(rois));
for i = 1:length(rois)
    for j = 1:length(output_files)
        if contains(output_files(j).name, rois{i})
            num_files_per_roi(i) = num_files_per_roi(i) + 1;
        end
    end
end

% Find most common parcellation
[max_val, max_ind] = max(num_files_per_roi);

% Collect folders using the most common parcellation
folders_for_list = {};
folder_ind = 1;
for i = 1:length(output_files)
    if contains(output_files(i).name, rois{max_ind})
        temp = output_files(i).folder;
        [a, ~, ~] = fileparts(temp);
        folders_for_list{folder_ind} = a;
        folder_ind = folder_ind + 1;
    end
end

% Write unique folder list to output file
unique_folders = unique(folders_for_list);
fid = fopen(output_file_list_path, 'wt');
for i = 1:length(unique_folders)
    fprintf(fid, '%s\n', unique_folders{i});
end
fclose(fid);
end
