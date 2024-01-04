.. biceps_cmdln documentation master file, created by
   sphinx-quickstart on Thu Jan  4 15:10:00 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to biceps_cmdln's documentation!
========================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

###What is biceps_cmdln?  
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
When you run biceps_cmdln, the tool will generate three types of connectivity  
matrices for each concatenated run a subject has with a given parcellation. The
three types will differ by the number of frames used to generate the underlying
matrices. The three types are:
 
* MaxIndividual - where all good frames an individual has will be used to construct connectivity matrix.  
* MaxGroup - where 

Hello hello hello



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
