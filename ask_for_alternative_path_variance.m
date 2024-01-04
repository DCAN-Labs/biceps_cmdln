function alternative_path_variances=ask_for_alternative_path_variance(has_variance_flag, gui, handles)

alternative_path_variances=pwd;
if (sum(has_variance_flag)<numel(has_variance_flag)) && (gui == 1)
    title='Some variance files might not exist in the derivatives folder. If existing, provide an alternative path to look for variance files';
    display(title);
    alternative_path_variances = uigetdir([],title);
elseif (sum(has_variance_flag)<numel(has_variance_flag)) && (gui == 0)
    error('Error: at least some of the variance files for the sessions of interest do not exist in the derivatives folder. If you want to specify the path to a different folder with dtvariance files, use the flag -custom_dtvar_folder')
end