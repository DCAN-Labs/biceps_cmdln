function make_file_list(input_bids_directory, output_file_list_path)
%MAKE_FILE_LIST 
%
% This function looks for all files ending in .ptseries.nii in the
% input_bids_directory. BIDS structure with/without sessions is assumed.
% Within the .ptseries files, the script will look for the roi-* key/value
% pair to figure out which parcellations are most common. All sessions
% (or subjects) with the most frequently found roi will then be represented
% in the output text file found at output_file_list_path.

%find all the ptseries files in the input directory whether or not the
%input directory has session structure
if input_bids_directory(end) == filesep
    input_bids_directory = input_bids_directory(1:(end-1));
end

output_files = dir([input_bids_directory filesep '*' filesep '*' filesep '*' filesep 'func' filesep '*.ptseries.nii']);
if length(output_files) == 0
    output_files = dir([input_bids_directory filesep '*' filesep '*' filesep 'func' filesep '*.ptseries.nii']);
end

%Confirm that the directory actually has any ptseries files
if length(output_files) == 0
    error(['Error: no files with ending *.ptseries.nii found in BIDS directory ' input_bids_directory '. Files with this pattern must be found for processing to occur.']);
end

%Figure out what different types of parcellations/rois are represented
%amont all the ptseries files
rois = cell(size(output_files));
session_folders = cell(size(output_files));
for i = 1 : length(output_files)
    temp_rois = split(output_files(i).name, '_');
    roi_found = 0;
    for j = 1 : length(temp_rois)
        if contains(temp_rois(j), 'roi-')
            rois(i) = temp_rois(j);
            session_folders{i} = output_files(i).folder;
            roi_found = 1;
        end
    end
    if roi_found == 0
        error(['Error: No roi-* key/value pair found in ' output_files(i).name '. roi-* must be present in all ptseries.nii files to identify which parcellations will be used during proccessing.']);
    end
end

%Find the most frequent parcellation in the directory
num_files_per_roi = zeros(size(rois));
for i = 1 : length(rois)
    temp_num_files = 0;
    for j = 1 : length(output_files)
        if contains(output_files(j).name, rois(i))
            num_files_per_roi(i) = num_files_per_roi(i) + 1;
        end
    end
end

%Make a list that has the folders containing the most frequently found
%parcellation.
[max_val, max_ind] = max(num_files_per_roi);
folders_for_list = {};
folder_ind = 1;
for i = 1 : length(output_files)
    if contains(output_files(i).name, rois(max_ind))
        temp = output_files(i).folder;
        [a, b, c] = fileparts(temp);
        folders_for_list{folder_ind} = a;
        folder_ind = folder_ind + 1;
    end
end

unique_folders = unique(folders_for_list);
fid = fopen(output_file_list_path, 'wt');
for i = 1 : length(unique_folders)
    fprintf(fid, '%s\n', unique_folders{i});
end

end