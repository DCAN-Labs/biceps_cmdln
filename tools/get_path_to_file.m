function list_func = get_path_to_file(root_path, depth, string_to_match)
%GET_PATH_TO_FILE Recursively search for folders or files matching a pattern
%
% list_func = get_path_to_file(root_path, depth, string_to_match)
%
% Inputs:
%   root_path        - Root directory to begin search
%   depth            - Max depth to recurse
%   string_to_match  - Pattern to match. 
%                      If it contains '*' or '?', it matches files.
%                      Otherwise, it matches folders.
%
% Output:
%   list_func        - Cell array of matching full paths

    if nargin < 3
        error('Usage: get_path_to_file(root_path, depth, string_to_match)');
    end

    is_file_pattern = contains(string_to_match, {'*', '?'});
    list_func = recursive_search(root_path, depth, string_to_match, 0, is_file_pattern);
end

function matches = recursive_search(current_path, max_depth, pattern, current_depth, is_file_pattern)
    matches = {};

    if current_depth > max_depth
        return;
    end

    if is_file_pattern
        % Case 1: Search for matching files in current directory
        matched_files = dir(fullfile(current_path, pattern));
        matched_files = matched_files(~[matched_files.isdir]);  % Only files

        for i = 1:length(matched_files)
            matches = [matches; {fullfile(current_path, matched_files(i).name)}]; %#ok<AGROW>
        end
    else
        % Case 2: Look for directories matching a name (partial match)
        subdirs = dir(current_path);
        subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name}, {'.', '..'}));

        for i = 1:length(subdirs)
            sub_path = fullfile(current_path, subdirs(i).name);

            % Match by name (partial match)
            if strcmp(subdirs(i).name, pattern) || contains(subdirs(i).name, pattern)
                matches = [matches; {sub_path}]; %#ok<AGROW>
            end

            % Recurse deeper
            sub_matches = recursive_search(sub_path, max_depth, pattern, current_depth + 1, is_file_pattern);
            matches = [matches(:); sub_matches(:)]; %#ok<AGROW>
        end
    end
end
