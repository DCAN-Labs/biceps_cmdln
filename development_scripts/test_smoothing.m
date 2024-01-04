in_folder = '/home/cullenkr/shared/leex6144_BRIDGES/smoothing_test/';
in_fname = 'sub-7310_ses-52930_task-GNG1_run-02_bold_Atlas_MSMAll_2_d40_WRN_hp2000_clean_GSR.dtseries.nii';
wb_path = '/panfs/roc/msisoft/workbench/1.5.0/bin_rh_linux64/wb_command';
smoothing_kernel_fwhm = 2;
left_hem_surface = '/home/midb-ig/shared/repositories/leex6144/biceps/data/fslr_surface/Q1-Q6_RelatedParcellation210.L.midthickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii';
right_hem_surface = '/home/midb-ig/shared/repositories/leex6144/biceps/data/fslr_surface/Q1-Q6_RelatedParcellation210.R.midthickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii';
out_folder = '/home/cullenkr/shared/leex6144_BRIDGES/smoothing_test/out_folder/';

make_dense_conns(in_folder, in_fname, out_folder, run_masks, mask_descriptions, ...
    smoothing_kernel_fwhm, left_hem_surface, right_hem_surface, wb_path)