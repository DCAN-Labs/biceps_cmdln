function make_dense_conns(in_folder, in_fname, out_folder, run_masks, mask_descriptions, ...
    smoothing_kernel, left_hem_surface, right_hem_surface, wb_path)
%MADE_DENSE_CONNS 
%
%   This function takes an input dtseries file, and optionally some masks.
%   If a mask(s) is provided a new censored copy of the dtseries will be
%   created in the output folder. If no mask is to be used, set run_masks
%   and mask_descriptions to be empty arrays (i.e. []). The dtseries image
%   will be used with wb_command to create dconn files.
%
%   in_folder: path to folder containing the input dtseries
%   in_fname: name of dtseries found in in_folder
%   out_folder: the folder to place output files
%   run_masks: 1xn cell with array containing binary values for each n runs
%              saying which TRs should be included/excluded
%   mask_descriptions: 1xn cell array with descriptions that will be
%   inserted into name of output file. Suggested example for one
%   description may be frames-Max, or something like that which is a
%   key-value pair describing the specific masking scheme
%   wb_path: path to workbench command. This means wb_command must be found
%   on your system.
%   smoothing_kernel: smoothing kernel to be applied to surface/volume
%   elements, defined in mm. set to 0 if you don't need to smooth the data
%   left_hem_surface: path to left hemisphere gifti file to use for
%   smoothing. If smoothing_kernel is 0, this can be set to anything.
%   right_hem_surface: path to right hemisphere gifti file to use for
%   smoothing. If smoothing_kernel is 0, this can be set to anything.

in_full_path = fullfile(in_folder, in_fname);
img_mat = cifti2mat(in_full_path);

partial_name = split(in_fname, '.');
partial_name = partial_name{1};
partial_path = fullfile(out_folder, partial_name);

%If smoothing is desired, run it before calculating dense conns
if smoothing_kernel
    smoothing_kernel_char = char(string(smoothing_kernel));
    smoothing_kernel_char_clean = strrep(smoothing_kernel_char, '.', 'p');
    smoothed_path_partial = strrep(partial_path, '_bold', ['_smoothing-' smoothing_kernel_char_clean 'mm_bold']);
    smoothed_path = [smoothed_path_partial '.dtseries.nii'];
    command = [wb_path ' -cifti-smoothing ' in_full_path ' ' smoothing_kernel_char ' ' smoothing_kernel_char];
    command = [command ' COLUMN ' smoothed_path];
    command = [command ' -left-surface ' left_hem_surface];
    command = [command ' -right-surface ' right_hem_surface];
    command = join(command);
    system(command);

    %Reset some of the names for later
    in_full_path = smoothed_path; %Use smoothed path as new reference image
    [folder, name, ext] = fileparts(in_full_path);
    partial_name = name(1:end-9); %This will get rid of dtseries also (.nii already removed)
    partial_path = fullfile(folder, partial_name);
end


if length(run_masks) > 0
    for i = 1 : length(run_masks)

        %Create new version of dtseries using current mask
        new_dtseries_path = strrep(partial_path, '_bold', ['_' mask_descriptions{i} '_bold']);
        new_dtseries_path = [new_dtseries_path '.dtseries.nii'];
        temp_masked = img_mat(:,run_masks{i}==1);
        mat2cifti(temp_masked, new_dtseries_path, in_full_path);
        clear temp_masked;

        %Use wb_command to convert the new dtseries into a dconn
        new_dconn_path = strrep(new_dtseries_path, '.dtseries.nii', '.dconn.nii');
        command = [wb_path ' -cifti-correlation ' new_dtseries_path ' ' new_dconn_path];
        system(command);
        disp(['Made dconn at: ' new_dconn_path]);
    end
else

    %If there is no mask, then just calculate the dconn on the
    %original dtseries
    new_dconn_path = [partial_path '.dconn.nii'];
    command = [wb_path ' -cifti-correlation ' in_full_path ' ' new_dconn_path];
    system(command);
    disp(['Made dconn at: ' new_dconn_path]);

end

end