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



```bash 
input_denoised_dir=/path/to/fmri/processing_output/
biceps_output_dir=/path/to/directory/for/biceps/output/
container_path=/path/to/biceps/singularity/container.sif
singularity run -B $input_denoised_dir:/input \
-B $biceps_output_dir:/output $container_path
```

Hello hello hello



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
