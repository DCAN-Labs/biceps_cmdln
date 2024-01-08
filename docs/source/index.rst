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

Using this pipeline is likely to be easiest if you are using tools generated  
by the DCAN group at the University of Minnesota to denoise your fMRI data.  

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
* MinGroup - where only the minimum requirement for number of frames will be used. For example if 5 min is required..
and the TR is 2 seconds, only 150 frames (30*5) will be used for each run.
* MaxGroup - where the maximum number of frames are used that allows for a consistent number of frames across runs...
For example if the worst run in the group has 160 frames, then 160 frames will be used as a threshold for all other..
runs in the study.

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
of the BICEPS GUI can be seen [HERE](https://gui-environments-documentation.readthedocs.io/en/latest/GUI_environments/).
Because singularity containers are only able to look at paths that are specified by the user
at the time the container is ran, it is still necessary to "bind" the input and output directories
where any data is stored prior to running biceps_cmdln: ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/directory/for/biceps/output/
    $ container_path=/path/to/biceps/singularity/container.sif
    $ singularity run \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
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

1. General BIDS Derivatives structure with session folders.

For biceps_cmdln to be able to parse files correctly there needs
to first be a BIDS Derivatives-like study folder. This study folder
should contain different subject folders. Below each subject folder
it is required for there to be session folders and then func folders
containing denoised fMRI data. While it is generally BIDS acceptable
for data to be organized either with or without a session structure,
biceps_cmdln requires there to be a session structure. An example of
the file structure for a given subject and session may look like:

/study_dir/sub-01/ses-01/func/

2. ptseries.nii files for each subject/session.

Each session and subject that will be processed should have at least one
file with extension "ptseries.nii". The ptseries file must have a key-value
pair such as "*_roi-Gordon2014FreeSurferSubcortical_*" in the name. The
underscores, roi key, and dash will let biceps_cmdln figure out which
parcellations are available in the input dataset. For each parcellation scheme
biceps_cmdln will calculate a set of connectivity matrices. 

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
