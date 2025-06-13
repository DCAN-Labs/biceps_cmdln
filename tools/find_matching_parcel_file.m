% Function to find a matching filename for a given parcel
function matched_file = find_matching_parcel_file(path_to_nii, subj_id, visit_id, parcel)
    files = dir(fullfile(path_to_nii, '*.ptseries.nii'));
    matched_file = '';
    for f = 1:length(files)
        fname = files(f).name;
        if contains(fname, subj_id) && ...
           contains(fname, visit_id) && ...
           contains(fname, 'rest') && ...
           contains(fname, 'bold') && ...
           contains(fname, parcel)
            matched_file = fullfile(path_to_nii, fname);
            return
        end
    end
    error(['No matching file found for ' subj_id ', parcel ' parcel ' in ' path_to_nii]);
end
