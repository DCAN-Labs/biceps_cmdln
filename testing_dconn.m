in_folder = '/panfs/jay/groups/4/miran045/miran045/training/BIDS_fconn_maker/Erik/input_with_variance/fake_ID_01/fake_visit_1/func';
in_file = 'fake_ID_01_fake_visit_1_task-rest_bold_timeseries.dtseries.nii';
output_folder = '/home/midb-ig/shared/repositories/leex6144/biceps_fconn_more_skip_vols_v2/bids/fake_ID_01/fake_visit_1/func';
wb_path = '/home/faird/shared/code/external/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command';
subject_masks = load('/panfs/jay/groups/19/midb-ig/shared/repositories/leex6144/biceps/example_subj_mask.mat');
subject_masks = subject_masks(1).subject_masks;
mask_description_cell = {'frames-MaxIndividual', 'frames-MaxGroup', 'frames-MinGroup'};

in_full_path = fullfile(in_folder, in_file);
%img_mat = cifti2mat(in_full_path);

%Should add some possibility for smoothing here too....


partial_name = split(in_file, '.');
partial_name = partial_name{1};
partial_path = fullfile(output_folder, partial_name);

error();

%Img Mat Masked 1
if length(subject_masks) > 0
    for i = 1 : length(subject_masks)

        %Create new version of dtseries using current mask
        new_dtseries_path = strrep(partial_path, '_bold', ['_' mask_description_cell{i} '_bold']);
        new_dtseries_path = [new_dtseries_path '.dtseries.nii'];
        temp_masked = img_mat(:,subject_masks{i}==1);
        mat2cifti(temp_masked, new_dtseries_path, in_full_path);
        delete(temp_masked);

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
    disp('hello')

end