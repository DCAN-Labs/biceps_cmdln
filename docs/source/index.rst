.. biceps_cmdln documentation master file, created by
   sphinx-quickstart on Thu Jan  4 15:10:00 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to biceps_cmdln's documentation!
========================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

What is biceps_cmdln?  
---------------------
biceps_cmdln is a tool for calculating functional connectivity matrices.  
The tool is specifically designed for individuals who already have fMRI  
data that has been (1) denoised, (2) projected into a parcellated cifti space,  
(3) concatenated [in the case where multiple versions of a run type exist], (4)  
and the data is formatted using general BIDS Derivatives principles.

Using this pipeline is only recommended if you are using tools generated  
by the DCAN group at the University of Minnesota to denoise and parcellate
your fMRI data.  

biceps_cmdln is specifically designed to calculate functional connectivity  
matrices for a group of individuals. With this in mind, it is easiest to use  
the tool once all of the data for your study has been acquired and processed.  
When you run biceps_cmdln, the tool will first evaluate which subjects and
sessions have sufficient data for calculating functional connectivity matrices. 
For each subject and session where there is enough data, each run will have three
types of functional connectivity matrices that are generated for a given parcellation.
The remaining three matrices will differ by the number of frames used to generate the 
underlying matrices. The three types are:
 
* MaxIndividual - where all good frames that an individual has will be used to construct connectivity matrix.  
* MinGroup - where only the minimum requirement for number of frames will be used. For example if 5 min is required and the TR is 2 seconds, only 150 frames (30*5) will be used for each run.
* MaxGroup - where the maximum number of frames are used that allows for a consistent number of frames across runs. For example if the worst run in the group has 160 frames, then 160 frames will be used as a threshold for all other runs in the study.

From the above description it is seen that the MaxGroup type connectivity matrices will  
change as a function of which runs are included in the study. In general, the results of  
biceps_cmdln are generally expected to change upon reprocessing even if the same runs are  
given as input. This is expected behavior because the individual frames in the MinGroup and 
MaxGroup cases will be randomly selected among high quality frames for a given run.

Beyond calculating functional connectivity matrices based on .ptseries.nii files, biceps_cmdln
can also be used to calculate .dconn.nii files from .dtseries.nii files. Because the file 
selection algorithm behind biceps_cmdln utilizes .ptseries.nii files to operate, both .ptseries.nii
files and .dtseries.nii files must be present for every subject if you want to calculate so-called
"dense" connectivity matrices. During this procedure the same temporal mask that determines which
frames will be included/excluded for calculating connectivity matrices from .ptseries.nii files will also
be applied to the .dtseries.nii file. See "Calculating Dense Connectivity Matrices" section for more
details.



Starting biceps_cmdln as GUI application
----------------------------------------

It is still possible to run biceps as a GUI application, which supports
legacy application of biceps_cmdln's parent tool "BICEPS". Full documentation
of the BICEPS GUI can be seen `here <https://gui-environments-documentation.readthedocs.io/en/latest/GUI_environments/>`_.
Because singularity containers are only able to look at paths that are specified by the user
at the time the container is ran, it is still necessary to "bind" the input and output directories
where any data is stored prior to running biceps_cmdln. Also be sure to bind the directory
containing the file list that will be grabbed to run processing. Binding the directory with
the file list is required both so that desired file list can be read, and because by default
the GUI application will save the list of subjects that met processing requirements to the
same directory where the file list was taken from (note, this is not necessary for command
line driven processing): ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/directory/for/biceps/output/
    $ folder_with_file_list=/path/to/folder/containing/file/list/
    $ container_path=/path/to/biceps/singularity/container.sif
    $ singularity run \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
        -B $folder_with_file_list:/file_list_dir \
        $container_path

Running biceps_cmdln using an input folder with processed fmri data
--------------------------------------------------------------------

The recommended way of running biceps_cmdln is to have a directory of
processed fMRI data that is formatted roughly as "BIDS Derivatives".
The exact formatting requirements can be seen later in this document.
During processing, the user is able to pass an input and output directory,
and biceps_cmdln will identify which data to process based on organizational
assumptions. The code to run this is as follows: ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/directory/for/biceps/output/
    $ container_path=/path/to/biceps/singularity/container.sif
    $ singularity run \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
        $container_path /input \
        -out_dir /output


Running biceps_cmdln using an input file list pointing to sessions
------------------------------------------------------------------

If you have a directory with processed fMRI data and you want to
exclude one or more subjects or sessions from biceps_cmdln processing,
then you may want to run biceps_cmdln by passing the tool a file list
instead of a folder. This file list should be a plain text file having 
one entry per line, where each line points to a session directory that 
should be included in biceps_cmdln attempts to calculate functional 
connectivity matrices. 

One line of this file is likely to look something like:
/study_dir/sub-01/ses-01/

When running processing, you will want to remember to bind
the input directory where the processed fmri data is stored,
the output directory where results will be stored, and the path
to the file list. Importantly, if the binding of the input directory
changes what the container thinks the paths to the input files are, then
this difference should be reflected in the file list. So the example
line listed above might instead need to be something like:
/input/sub-01/ses-01

If the input file list refers to data from multiple input directories,
then be sure to bind each input directory to a unique name in the container.

Example code for base case of using file list to run biceps_cmdln: ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/directory/for/biceps/output/
    $ file_list=/path/to/file_list.txt
    $ container_path=/path/to/biceps/singularity/container.sif
    $ singularity run \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
        -B $file_list:/file/list.txt \
        $container_path /file/list.txt \
        -out_dir /output



Organization requirements for running biceps_cmdln
--------------------------------------------------

It is important to remember that all of these requirements need to be satisfied
for you to be able to use biceps_cmdln. If they are not satisfied, you may consider
reformatting your data to meet current pipeline requirements or using a different
pipeline to calculate connectivity matrices.

1. General BIDS Derivatives structure with session folders.

  * For biceps_cmdln to be able to parse files correctly there needs
    to first be a BIDS Derivatives-like study folder. This study folder
    should contain different subject folders. Below each subject folder
    it is required for there to be session folders and then func folders
    containing denoised fMRI data. While it is generally BIDS acceptable
    for data to be organized either with or without a session structure,
    biceps_cmdln requires there to be a session structure. An example of
    the file structure for a given subject and session may look like:  

    /study_dir/sub-01/ses-01/func/
|
2. ptseries.nii files for each subject/session.

  * Each session and subject that will be processed should have at least one
    file with extension "ptseries.nii". The ptseries file must have a key-value
    pair such as "*_roi-Gordon2014FreeSurferSubcortical_*" in the name. The
    underscores, roi key, and dash will let biceps_cmdln figure out which
    parcellations are available in the input dataset. For each parcellation scheme
    biceps_cmdln will calculate a set of connectivity matrices.
|
3. Files with signal variance information.

  * For every concatenated run that is to be processed, the user should have a file
    with naming ending in "_variance.txt", where the beginning of the file name has
    the subject and session name, along with the task identifier (i.e. task-rest).
    There should be one entry at each row referring to the signal's ________. This file
    will be screened for frames that are more than 3 scaled median absolute deviations
    from the sample median. If the "_variance.txt" files can not be found within the
    subject/session/func folders, the user can provide a new folder that solely contains
    these files (one for each run to be processed) at the base level of the directory. 
    This directory can be passed to biceps_cmdln via the custom_dtvar_folder
    argument. Note - even if the user does not want to remove outliers (i.e. if outlier
    flag is given a value of 0), these "_variance.txt" files must still be provided
    during processing.
|
4. A biceps_cmdln compatible file with motion and TR information.

  * For every concatenated run that is to be processed, the user should have a file
    with naming ending in "_mask.mat", where the beginning of the file name has
    the subject and session name, along with the task identifier (i.e. task-rest).
    This file should be a matlab compatible object that has information about which
    frames are high moton and also what the TR is of the scan. 

Arguments
---------

| **Positional:**
|
| **input** - if not provided, biceps_cmdln will open to the GUI. If provided this can either be a file list or path to a study directory that should be parsed.
|
|
| **Flag Key/Value Pairs:**
|
| **-out_dir**: string. Path to where BICEPS output should be stored. Default option is in current working directory. Remember to bind this path if using the singularity version of the tool.    
|
| **-save_bids**: int. Set to a positive number if you want the output to be saved in BIDS on top of standard BICEPS output format. Default is to not save in this way.  
|
| **-attempt_pconn**: 0 or 1, default 0 Set to 1 if you want BICEPS to try making .pconn.nii files out of the generated connectivity matrices. Default = 0  
|
| **-save_timeseries**: int. Set to positive value if you want to save the timeseries. The saved timeseries will only be propogated to the outputs with standard formatting, not the BIDS formatted outputs. 
|
| **-fd**: float. The framewise displacement threshold in mm, default value 0.2.
|
| **-n_skip_vols**: int. The number of frames to skip at the beginning of every scan. Default is 5. Remember - if you are working with concatenated runs, this will only remove frames from the first run in the concatenated series.   
|
| **-minutes**: float. The minimum amount of data a subject must have to be included in processing, measured in minutes. Default value = 8 min. To convert frames to time, the tool will extract TR from input metadata (file ending in "_mast.mat").
|
| **-outlier**: 1 or 0. Whether to remove outliers based on signal variability, default 1.  
|
| **-validate_frame_counts**: int. Set to a positive number if you want to validate that all runs have the same number of frames.  
|
| **-wb_command_path**: string. Set the path to wb_command from HCP. By default BICEPS will try to find this path on its own.  
|
| **-make_dense_conns**: int. Set to positive number to make dconn files from dtseries. Note - you must have corresponding ptseries files for this to work. The output dconn files will have the same temporal masking as the pconn files.   
|
| **-dtseries_smoothing**: float. The amount of smoothing to use, for both surface and volume space, in millimeters (sigma of gaussian kernel). This only is used if -make_dense_conns flag is activated.  
|
| **-left_hem_surface**: string. The path to the left hemisphere to use for smoothing. If -dtseries_smoothing > 0 and no input is provided here, smoothing will use the default fslr midthicknes file stored in BICEPS. It is better for this to point to the actual midthickness file for a given subject. If that is the case, processing can only occur one subject at a time since it is only possible to give inputs for one surface.  
|
| **-right_hem_surface**: string. The path to the right hemisphere to use for smoothing. See description from left_hem_surface for more info.  
|
| **-custom_dtvar_folder**: string. If flag is used BICEPS will accept the path to a folder where all dtvariance files are found directly within the folder specified (i.e. NOT BIDS organized)  
|


Expected Outputs
================

Standard Formatting
-------------------

biceps_cmdln will produce two output directories within the parent output directory.
The first directory will be under the user specified output directory and named "standard".
Under "standard" will be a folder named "Functional" and underneath that will be a folder
whose name varies based on the settings used to run biceps_cmdln. Underneath that folder
will be one folder for each parcellation present in the input dataset. The overall contents
of this "standard" folder will look something like:

- ── Functional
    - ── list_with_variance_MCMethod_power_2014_FD_only_FD_th_0_20_min_frames_600_skip_frames_5_TRseconds_0_80
        - ── frame_removal_mask.mat
        - ── Gordon2014FreeSurferSubcortical_timeseries.ptseries
            - ── fconn_600_frames.mat
            - ── fconn_820_frames.mat
            - ── fconn_all_surv_frames.mat
            - ── raw_timecourses.mat
        - ── HCP2016FreeSurferSubcortical_timeseries.ptseries
            - ── fconn_600_frames.mat
            - ── fconn_820_frames.mat
            - ── fconn_all_surv_frames.mat
            - ── raw_timecourses.mat

In the example above, we see how the folder below "Functional" contains infomation relevant
to the current processing, such as the minimum frames requirement, the TR, and the FD threshold.

In addition to these files there will be file list of subjects that were included in processing. This
file will generally be directly under the output directory (meaning adjacent to "standard"), and have
one line for each subject that was included in processing. Additionally if the user provided biceps_cmdln
with a folder to process instead of a file list, there will be a file named "biceps_file_list.txt" that
displays all the subjects/sessions that were candidates for processing. The difference between the two
file lists is that the first list excludes subjects that didn't have the prerequisite number of frames
for processing. The exception to this file layout is if the GUI form of biceps_cmdln was used to initiate
processing. In the case the GUI is used, the copy of the list describing which files were used in
processing will instead be found in the same directory as the file list that was selected by the
GUI at the beginning of processing.

The files outlined in the chart above will have the following structure. For all instances
where there are "n" dimensions representing some number of subjects/sessions that were included
in processing, the ordering of those n subjects will be the same as listed in the output file
list described in the last paragraph.
|
* frame_removal_mask.mat: This is a matlab file with variable "mask" representing a cell array
  with shape <n,3> where n is the number of sessions that had runs meeting the minimum
  processing requirements, and 3 represents the different temporal masking options
  (MaxIndividual, MaxGroup, then MinGroup, respectively). Mask values are 1 for included
  frames and 0 for excluded frames.
* fconn_all_surv_frames.mat: A matlab file with variable "fconn". fconn is a three dimensional
  array with shape <m,m,n> where m is the number of regions in the parcellation and n is the
  number of of subjects. The frames used to create these connectivity matrices is found in
  the <:,1>th entries of the frame_removal_mask file. There will be one of these files generated
  for each parcellation that was used during processing.
* fconn_820_frames.mat: Same structure as fconn_all_surv_frames.mat. Now the mask entries
  used to generate these matrices can be found in the <:,2>th entries. The exact name of
  this type of file will change based on your dataset. This file represents the "MaxGroup"
  type of frame sampling.
* fconn_600_frames.mat: Same structure as fconn_all_surv_frames.mat. Now the mask entries
  used to generate these matrices can be found in the <:,3>th entries. The exact name of
  this type of file will change based on your dataset. This file represents the "MinGroup"
  type of frame sampling.
* raw_timecourses.mat: This file will only be created when the save_timeseries flag is set
  to 1. If generated, the matlab file will have one variable named raw_tc. raw_tc will be 
  a <n,1> cell array for n subjects that were processed. Each cell array element represents
  a <m,p> matrix where m is the number of regions in a parcellation and p is the number of
  frames in the scan.


BIDS formatting
---------------


- ── sub-01
    - ──  ses-01
        - ──  func
            - ── sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.json
            - ── sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.mat
            - ── sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries.json
            - ── sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries.mat
            - ── sub-01_ses-01_task-rest_frames-MaxIndividual_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.json
            - ── sub-01_ses-01_task-rest_frames-MaxIndividual_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.mat
            - ── sub-01_ses-01_task-rest_frames-MaxIndividual_bold_roi-HCP2016FreeSurferSubcortical_timeseries.json
            - ── sub-01_ses-01_task-rest_frames-MaxIndividual_bold_roi-HCP2016FreeSurferSubcortical_timeseries.mat
            - ── sub-01_ses-01_task-rest_frames-MinGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.json
            - ── sub-01_ses-01_task-rest_frames-MinGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries.mat
            - ── sub-01_ses-01_task-rest_frames-MinGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries.json
            - ── sub-01_ses-01_task-rest_frames-MinGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries.mat



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

