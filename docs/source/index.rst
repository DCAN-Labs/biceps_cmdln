.. biceps_cmdln documentation master file, created by
   Kody DeGolier on Mon Aug  8 15:10:00 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to biceps_cmdln's documentation!
========================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

What is biceps_cmdln?
======================

.. note::

   **Summary:** ``biceps_cmdln`` generates functional connectivity matrices from preprocessed, parcellated fMRI timeseries. 
   It's optimized for group-level analysis and designed to work with data formatted using DCAN Lab's conventions and BIDS derivatives.

Overview
--------

``biceps_cmdln`` is a command-line tool for calculating **functional connectivity matrices** from **parcellated fMRI timeseries** data.  
It is intended for users who already have fMRI data that has been:

1. Denoised  
2. Projected into a **parcellated CIFTI** space (e.g., `.ptseries.nii`)  
3. Concatenated (if multiple versions of a run type exist)  
4. Organized using **BIDS Derivatives** conventions  

.. note::

   ``biceps_cmdln`` is optimized for data preprocessed using tools developed by the **CDNI Lab** at the University of Minnesota.
   While it may work with other pipelines, we recommend using CDNI-compliant data for best results.

Supported Input Data
--------------------

The tool is designed for **group-level analysis**, so it works best once your entire dataset has been processed and is ready for analysis.  
When executed, ``biceps_cmdln`` scans your dataset and identifies subjects and sessions with sufficient usable data for computing functional connectivity.

Connectivity Matrix Types
-------------------------

For each run with sufficient data, three versions of the functional connectivity matrix are generated per parcellation:

- **MaxIndividual**:  
  Uses all good frames available for each individual's run.  
  Maximizes within-subject data usage.

- **MinGroup**:  
  Uses a fixed minimum number of frames across all individuals.  
  For example, if 5 minutes are required and TR is 2 seconds, then 150 frames (5 * 60 / 2) are used consistently.

- **MaxGroup**:  
  Uses the maximum number of frames that all runs can share.  
  For example, if the shortest valid run in the group has 160 frames, then 160 frames are used for all runs to ensure consistency.


.. note::

   The **MaxGroup** matrices only change when:
   - Different participants are included in the dataset
   - Different data or runs are selected
   - The frame selection parameters (e.g., **FD thresholds**) are modified

   Reprocessing the **same data with the same parameters** will not change MaxGroup outputs.  
   However, **MinGroup** and **MaxIndividual** matrices may show minor variability due to random sampling of eligible frames.

Dense Connectivity Matrix Support
---------------------------------

In addition to `.ptseries.nii`-based matrices, ``biceps_cmdln`` can compute **dense connectivity matrices** (`.dconn.nii`) from **dense timeseries** data (`.dtseries.nii`).

.. important::

   If you want to generate dense connectivity matrices, **both** `.ptseries.nii` and `.dtseries.nii` files must be present for each subject.  
   The file selection and frame inclusion are based entirely on the `.ptseries.nii` files.

During this process:

- The **temporal mask** used for `.ptseries.nii`-based matrices is also applied to the `.dtseries.nii` file.
- This ensures consistency across both parcellated and dense outputs.
- The resulting `.dconn.nii` matrices represent whole-brain connectivity using only the selected high-quality frames.

For more, see the :ref:`Calculating Dense Connectivity Matrices` section.



Acronym Definitions
-------------------

For clarity:

- **BIDS**: Brain Imaging Data Structure  
- **TR**: Repetition Time (e.g., 2 seconds between fMRI frames)  
- **FD**: Framewise Displacement (used to assess motion)


Downloading biceps_cmdln
=========================

There are three ways to use ``biceps_cmdln``:

1. **Python wrapper** (recommended for most users)
2. **Singularity container** (easy setup, good for reproducibility)
3. **MATLAB source code** (for full control and development)

Running via Python (Recommended)
--------------------------------

The recommended method for most users is the **Python wrapper**, which launches MATLAB behind the scenes while handling:

- Flag validation
- Output organization
- Variance patching (if needed)
- Command-line simplicity

This approach gives you the **flexibility of MATLAB** without needing to interact with it directly.

Requirements
~~~~~~~~~~~~

- Python 3.6+
- MATLAB installed
- `scipy` Python package (`pip install scipy`)
- Connectome Workbench (or set via `-wb_command_path`)
- ``biceps_cmdln`` repository and Python wrapper script

Setup Instructions
~~~~~~~~~~~~~~~~~~

1. Clone the repository:  
   `https://github.com/DCAN-Labs/biceps_cmdln <https://github.com/DCAN-Labs/biceps_cmdln>`_

2. Place the Python wrapper script (`run_biceps.py`) in the root folder.

3. Make it executable: ::

    chmod +x run_biceps.py

4. Run from the command line: ::

    ./run_biceps.py <input_list_or_folder> -out_dir <output_path> [other flags]

**Example:** ::

    ./run_biceps.py subject_list.txt -out_dir results/ -fd 0.2 -minutes 5 -make_dense_conns 1

Automatic Variance Patching
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If your input data is missing required variance files, the wrapper will:

- Detect the issue
- Trigger a patch step via MATLAB
- Set the `-custom_dtvar_folder` flag automatically

Workbench Command Path
~~~~~~~~~~~~~~~~~~~~~~

If `wb_command` is not in your system's default path, the script will use: ::

   /common/software/install/manual/workbench/2.0.1-rocky8/bin/wb_command

You can override this with the `-wb_command_path` flag.



Singularity Container (Portable & Reproducible)
-----------------------------------------------

Using the provided **Singularity container** is the easiest way to run ``biceps_cmdln`` without needing to install MATLAB or Workbench tools.

Ideal if you:

- Want a portable, reproducible environment
- Are running on an HPC system with Singularity support
- Don't need advanced custom flags (e.g., `--fd`, `--min`)

.. note::

   You must have **Singularity** installed on your system to use this option.

Download and Build the Container
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Visit the `DCAN Labs Docker Hub page <https://hub.docker.com/u/dcanumn>`_.
2. Locate the latest version of the container (e.g., `dcanumn/biceps_cmdln:1.8`).
3. Ensure you have **at least 100 GB** of temporary disk space.

If using SLURM (e.g., at UMN), request build resources: ::

   srun -N 1 --ntasks-per-node=1 --tmp=100g --mem-per-cpu=30g -t 5:00:00 -p interactive --pty bash

Then build the image: ::

   singularity pull docker://dcanumn/biceps_cmdln:1.8

.. warning::

   Building may take up to **3 hours** and will produce a `.sif` file in your working directory.

Known Limitations
~~~~~~~~~~~~~~~~~

Some customization flags (e.g., ``--fd``, ``--min``) may not behave as expected in the container.  
If your analysis relies on these, use the Python wrapper or MATLAB version.



Running via MATLAB (Full Control)
---------------------------------

Use this method if you:

- Want access to all internal functions
- Are developing or debugging the code
- Need GUI-based functionality

Setup Instructions
~~~~~~~~~~~~~~~~~~

1. Clone the repository:  
   `https://github.com/DCAN-Labs/biceps_cmdln <https://github.com/DCAN-Labs/biceps_cmdln>`_

2. Ensure you have:
   - **MATLAB** installed
   - **Connectome Workbench** installed (``wb_command``)

3. Launch MATLAB and add the path recursively: ::

    addpath(genpath('path/to/biceps_cmdln'))

4. You can now run ``biceps_cmdln`` directly: ::

    biceps_cmdln('input_list.txt', '-out_dir', 'results/', '-fd', 0.2, ...)

Workbench Path Requirements
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. important::

   If not using the container, ``wb_command`` must be specified correctly.

Options:

- Edit the default inside `biceps_cmdln.m`
- Use the ``--wb_command_path`` flag at runtime



Summary of Usage Options
------------------------

- **Python Wrapper**  
  - **Best for:** Most users, scripting, CLI flags, automation  
  - **Requires MATLAB?** Yes (runs behind the scenes)

- **Singularity**  
  - **Best for:** Reproducibility, no MATLAB installation, HPC/container environments  
  - **Requires MATLAB?** No

- **Native MATLAB**  
  - **Best for:** Development, debugging, full customization, GUI mode  
  - **Requires MATLAB?** Yes (interactive use)



Ways of Running biceps_cmdln
============================

``biceps_cmdln`` can be run in several ways, depending on your workflow and system setup.  
We recommend prioritizing **Python or Singularity-based command-line execution** for reproducibility and automation.  
The **GUI** remains available for legacy use and visualization.

Available Methods:

1. **Python Wrapper** (Recommended)
2. **Singularity Container (CLI)**  
   - Using an input directory  
   - Using an input directory + making dense dconns  
   - Using a file list  
3. **GUI Mode (Legacy)**



1. Running via Python Wrapper (Recommended)
-------------------------------------------

The **Python wrapper** is the simplest and most flexible way to run ``biceps_cmdln``:

- Handles MATLAB calls behind the scenes
- Automatically checks and patches missing variance files
- Validates flags and outputs clearer errors
- Easy to use in scripts or SLURM jobs

Basic usage: ::

    ./run_biceps.py <input_list_or_folder> -out_dir <output_path> [flags]

Example with dense connectivity calculation: ::

    ./run_biceps.py subject_list.txt -out_dir results/ -fd 0.2 -minutes 5 -make_dense_conns 1

See :ref:`Downloading biceps_cmdln` for full Python wrapper instructions.



2. Running via Singularity Container (Command Line)
---------------------------------------------------

The **Singularity container** is portable and requires no local MATLAB installation.  
You must **bind** the directories for input data, output data, and (if using file lists) the list location.

Input Folder with Processed fMRI Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is the simplest container usage. You provide a BIDS-derivative style folder of fMRI data: ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/biceps/output/
    $ container_path=/path/to/biceps_cmdln.sif
    
    singularity run --cleanenv \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
        $container_path /input \
        -out_dir /output



Input Folder + Dense Connectivity Matrices (dconns)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To also generate dense connectivity matrices:

1. Set the ``-make_dense_conns`` flag to 1.
2. Bind your home directory to allow temporary file writes.

Example: ::

    $ singularity run --cleanenv \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
        -B /home/<group>/<user>:/home/<group>/<user> \
        $container_path /input \
        -out_dir /output -make_dense_conns 1

Dense connectivity outputs will appear under the **BIDS derivatives** structure.



Input File List
~~~~~~~~~~~~~~~

If you want to **restrict processing** to a subset of sessions or subjects, provide a **text file** with one session path per line. Example line: ::

    /study_dir/sub-01/ses-01/

.. important::

   If you bind input directories to a different path (like `/input`),  
   the paths in your file list **must match the bound paths**: ::

       /input/sub-01/ses-01/

**Base case with file list**: ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/biceps/output/
    $ file_list=/path/to/file_list.txt
    $ container_path=/path/to/biceps_cmdln.sif
    
    singularity run --cleanenv \
        -B $input_denoised_dir:/input \
        -B $biceps_output_dir:/output \
        -B $file_list:/file/list.txt \
        $container_path /file/list.txt \
        -out_dir /output

If your list references **multiple input directories**, bind each one to a unique container path.



3. Starting biceps_cmdln as GUI (Legacy)
----------------------------------------

The GUI mode supports **interactive use** and is a legacy feature from the original **BICEPS** tool.  
Full documentation: `BICEPS GUI Documentation <https://gui-environments-documentation.readthedocs.io/en/latest/GUI_environments/>`_

GUI mode requires:

- A system with **graphical display access** (``DISPLAY`` variable)
- Proper **binding** of input/output directories and the file list folder
- Singularity container execution with display forwarding

Example: ::

    $ input_denoised_dir=/path/to/fmri/processing_output/
    $ biceps_output_dir=/path/to/biceps/output/
    $ folder_with_file_list=/path/to/file/list/folder/
    $ container_path=/path/to/biceps_cmdln.sif
    
    singularity run --cleanenv \
        -B $input_denoised_dir:$input_denoised_dir \
        -B $biceps_output_dir:/output \
        -B $folder_with_file_list:/file_list_dir \
        --env DISPLAY=$DISPLAY \
        $container_path

.. note::

   - GUI is **not required** for CLI processing.
   - By default, the GUI saves the list of successfully processed subjects to the **same folder** as the input file list.



**Summary Recommendation:**

- **Python wrapper** -> Best balance of simplicity and flexibility  
- **Singularity CLI** -> Most portable and reproducible (HPC-friendly)  
- **GUI** -> Use only for legacy workflows or interactive visualization


Organization Requirements for Running biceps_cmdln
==================================================

``biceps_cmdln`` requires a specific **data organization and file structure** to function properly.  
If these requirements are not met, you may need to:

- Reformat your data to meet the requirements, **or**
- Use another pipeline to compute connectivity matrices.

Below are the required components:



1. General BIDS Derivatives Structure with Session Folders
----------------------------------------------------------

``biceps_cmdln`` expects your fMRI data to be organized in a **BIDS Derivatives-like** hierarchy with:

- **Study folder**  contains subject folders
- **Subject folder**  contains session folders
- **Session folder**  contains `func` folder with denoised fMRI outputs

**Important:** Unlike standard BIDS, ``biceps_cmdln`` **requires** a session structure  
(`ses-xx`) even if you only have a single session per subject.

**Example folder structure:** ::

    /study_dir/
        sub-01/
            ses-01/
                func/
                    <fMRI output files>



2. Parcellated Timeseries Files (`.ptseries.nii`)
-------------------------------------------------

Each **subject/session** must have at least one **CIFTI parcellated timeseries file**:

- File extension: `.ptseries.nii`
- File name should contain a **parcellation key**, such as: ::

    sub-01_ses-01_task-rest_roi-Gordon2014FreeSurferSubcortical_ptseries.nii

``biceps_cmdln`` uses this key (the `roi-<parcellation>` portion) to:

- Detect available parcellation schemes
- Generate connectivity matrices for **each parcellation**



3. Signal Variance Files (`_variance.txt`)
------------------------------------------

Each **concatenated run** requires a corresponding **variance file**:

- File extension: `_variance.txt`
- Filename should start with **subject, session, and task identifiers**, for example: ::

    sub-01_ses-01_task-rest_variance.txt

- Each row contains a **signal variance value per frame**

**Purpose in biceps_cmdln:**

- Frames exceeding **3 scaled median absolute deviations** are considered **outliers**
- Even if **outlier removal is disabled** (`-outlier 0`),  
  the `_variance.txt` files **must still exist**

**If `_variance.txt` files are stored elsewhere:**

- Place all variance files in a single folder
- Pass this folder to ``biceps_cmdln`` using the ``-custom_dtvar_folder`` flag



4. Motion and TR Information (`_mask.mat`)
------------------------------------------

Each run also requires a **MATLAB `.mat` file** containing:

- **Framewise motion mask** (which frames are high-motion)
- **Repetition Time (TR)** of the scan

File naming convention: ::

    sub-01_ses-01_task-rest_mask.mat

This file is used by ``biceps_cmdln`` to:

- Apply temporal masks
- Correctly compute frame counts and frame-based thresholds



**Summary of Required Files per Run**
-------------------------------------

- **Python Wrapper**  
  - **Best for:** Most users, scripting, CLI flags, automation  
  - **Requires MATLAB?** Yes (runs behind the scenes)

- **Singularity**  
  - **Best for:** Reproducibility, no MATLAB installation, HPC/container environments  
  - **Requires MATLAB?** No

- **Native MATLAB**  
  - **Best for:** Development, debugging, full customization, GUI mode  
  - **Requires MATLAB?** Yes (interactive use)

.. note::

   If any required files are missing, ``biceps_cmdln`` will fail to process that run.  
   The **Python wrapper** can assist by **detecting and patching missing variance files** automatically.



Command-Line Arguments
======================

The ``biceps_cmdln`` tool accepts **one optional positional argument** (the input)
followed by **optional key/value flags** for customization.

If no arguments are provided, the graphical user interface (GUI) will launch.

Quick Start Examples
--------------------

Here are some example commands to get started quickly:

.. code-block:: bash

    # Example 1: Run with a study directory, adjust minimum minutes and FD threshold
    biceps_cmdln /path/to/study -minutes 6 -fd 0.15

    # Example 2: Run with a study directory and use a custom dtvar folder
    biceps_cmdln /path/to/study -custom_dtvar_folder /path/to/dtvar_files

    # Example 3: Combine all three flags in one run
    biceps_cmdln /path/to/study -minutes 6 -fd 0.15 -custom_dtvar_folder /path/to/dtvar_files


1. Positional Argument: ``input``
---------------------------------

**Usage:**

.. code-block:: bash

    biceps_cmdln [input]

**Description:**

- If **omitted**  launches the GUI.
- If **provided**, ``input`` can be:

  1. **Path to a study directory** (BIDS-derivatives format)
  2. **Path to a file list** containing session directories (one path per line)

**Examples:**

.. code-block:: bash

    # Run with a study directory
    biceps_cmdln /path/to/study

    # Run with a file list
    biceps_cmdln session_list.txt


2. Optional Flags
-----------------

Flags are provided in the form:

.. code-block:: bash

    -flag_name <value>

Below is a breakdown of available flags.

General Output
~~~~~~~~~~~~~~

- **``-out_dir``** *(str, default: ``.``)*  
  Output directory for results.  
  **Tip:** Bind this path if using Singularity.

- **``-save_bids``** *(int, default: ``0``)*  
  Save results in **BIDS format** in addition to standard outputs.


Connectivity & Timeseries
~~~~~~~~~~~~~~~~~~~~~~~~~

- **``-attempt_pconn``** *(int, default: ``0``)*  
  Generate ``.pconn.nii`` from connectivity matrices.  
  Automatically enables ``-save_bids``.

- **``-save_timeseries``** *(int, default: ``0``)*  
  Save parcellated timeseries in the standard (non-BIDS) format.


Frame Selection & Motion
~~~~~~~~~~~~~~~~~~~~~~~~

- **``-fd``** *(float, default: ``0.2``)*  
  Framewise displacement threshold in millimeters.

- **``-n_skip_vols``** *(int, default: ``5``)*  
  Number of frames to skip at the start of each scan.  
  Only affects the **first run** in concatenated runs.

- **``-minutes``** *(float, default: ``8``)*  
  Minimum usable data per subject (minutes).  
  **Note:** Some versions have a bug preventing changes from the default.

- **``-outlier``** *(int, default: ``1``)*  
  Remove high-variance frames (3× MAD rule).  
  Set to ``0`` to disable removal (variance files still required).

- **``-validate_frame_counts``** *(int, default: ``0``)*  
  Ensure all runs have the same number of frames before processing.


Dense Connectivity
~~~~~~~~~~~~~~~~~~

- **``-make_dense_conns``** *(int, default: ``0``)*  
  Generate ``.dconn.nii`` from ``.dtseries.nii`` (requires matching ``.ptseries.nii``).  
  Automatically enables ``-save_bids``.

- **``-dtseries_smoothing``** *(float, default: ``0``)*  
  Gaussian smoothing kernel size (sigma, mm) for dense matrices.  
  Only applies if ``-make_dense_conns`` is set.

- **``-left_hem_surface``** *(str, default: internal template)*  
  Path to **left hemisphere midthickness surface** for smoothing.  
  If set, process only **one subject at a time**.

- **``-right_hem_surface``** *(str, default: internal template)*  
  Same as above, but for the right hemisphere.


Custom File Layouts
~~~~~~~~~~~~~~~~~~~

- **``-wb_command_path``** *(str, default: auto-detected)*  
  Path to the HCP ``wb_command`` binary if not on PATH or using a custom version.

- **``-custom_dtvar_folder``** *(str, default: None)*  
  Path to a folder containing ``_variance.txt`` files in a flat (non-BIDS) layout.


Notes & Tips
~~~~~~~~~~~~

- Boolean flags treat **any positive integer** as "true".
- ``-attempt_pconn`` and ``-make_dense_conns`` **automatically enable** ``-save_bids``.
- Even with ``-outlier 0``, ``_variance.txt`` files **must exist**.
- If lowering ``-minutes`` below 8, check for version compatibility due to the known bug.


.. _calculating_dense_connectivity_matrices:

Calculating Dense Connectivity Matrices
=======================================

Dense connectivity matrices store vertex- or voxel-wise correlations across the brain, rather than parcel-averaged values.  
They are much larger than parcellated matrices but preserve the full spatial resolution of the input data.

**When to use:**  
- Required if you need `.dconn.nii` outputs for vertex-level analyses.  
- Useful for generating high-resolution network visualizations or running analyses that cannot be performed on parcellated data.

**How to enable:**  
- Add the ``-make_dense_conns 1`` flag to your BICEPS command.

**Requirements:**  
- Matching `.ptseries.nii` files must be available for all runs to be processed.  
- If subject-specific smoothing is desired, supply:
  - ``-left_hem_surface`` = path to left hemisphere midthickness surface
  - ``-right_hem_surface`` = path to right hemisphere midthickness surface
- Otherwise, BICEPS will use the fslr template surfaces.

**Optional settings:**  
- ``-dtseries_smoothing <sigma_mm>`` - Apply Gaussian smoothing (sigma in mm) to the dense data before correlation.  
- ``-save_bids 1`` - Save dense connectivity outputs in BIDS format alongside standard BICEPS outputs.

**Outputs:**  
- One `.dconn.nii` file per parcellation/dataset processed.  
- Output location matches your ``-out_dir`` setting (and ``bids/`` subdirectory if ``-save_bids`` is used).

**Notes:**  
- Dense matrices are very large in memory; ensure you have sufficient RAM and disk space.  
- Processing time can be significantly longer compared to parcellated matrices.

Expected Outputs
================

After running ``biceps_cmdln``, outputs are organized under the directory specified by ``-out_dir``.  
Two main formats are produced:

1. **Standard formatting** (always created)
2. **BIDS formatting** (if `-save_bids` or certain flags are used)



Standard Formatting
-------------------

``biceps_cmdln`` will always generate a **standard/** folder inside the output directory.

**Example directory tree:**

.. code-block:: text

    output_dir/
    +-- standard/
        +-- Functional/
            +-- list_with_variance_MCMethod_power_2014_FD_only_FD_th_0_20_min_frames_600_skip_frames_5_TRseconds_0_80/
                +-- frame_removal_mask.mat
                +-- Gordon2014FreeSurferSubcortical_timeseries.ptseries/
                |   +-- fconn_600_frames.mat
                |   +-- fconn_820_frames.mat
                |   +-- fconn_all_surv_frames.mat
                |   +-- raw_timecourses.mat
                +-- HCP2016FreeSurferSubcortical_timeseries.ptseries/
                    +-- fconn_600_frames.mat
                    +-- fconn_820_frames.mat
                    +-- fconn_all_surv_frames.mat
                    +-- raw_timecourses.mat
    +-- included_subjects.txt
    +-- biceps_file_list.txt

**Key Points:**

- The folder under **Functional/** encodes run settings:
  - FD threshold
  - Minimum frames required
  - TR and skip frames
- **`included_subjects.txt`** -> sessions that met frame requirements
- **`biceps_file_list.txt`** -> all candidate sessions (if input was a folder)

.. note::
   If you launch processing via the **GUI**, the list of included subjects  
   is saved next to the **input file list** you selected, not in the output folder.




Standard Output Files
---------------------

- **frame_removal_mask.mat**  
  - Cell array `<n,3>` where `n` = number of sessions that met requirements.  
  - Columns correspond to temporal masks:  
    1. **MaxIndividual**  
    2. **MaxGroup**  
    3. **MinGroup**  
  - Value `1` = included frame, `0` = excluded frame.

- **fconn_all_surv_frames.mat**  
  - 3D array `<m,m,n>` per parcellation  
    - `m` = number of ROIs  
    - `n` = number of sessions  
  - Uses frames from **column 1** of `frame_removal_mask.mat` (MaxIndividual mask).

- **fconn_<X>_frames.mat**  
  - Same 3D shape `<m,m,n>` as above.  
  - `X` = number of frames used (corresponds to **MaxGroup** or **MinGroup** masks).

- **raw_timecourses.mat** *(only if `-save_timeseries 1`)*  
  - Contains variable `raw_tc`: `<n,1>` cell array, one per processed session.  
  - Each cell is a `<m,p>` matrix:  
    - `m` = number of ROIs in the parcellation  
    - `p` = number of frames in the scan



BIDS Formatting
----------------

If **`-save_bids`**, **`-attempt_pconn`**, or **`-make_dense_conns`** are used,  
a **bids/** folder is also created next to **standard/**.

**Example per-subject structure:**

.. code-block:: text

    output_dir/
    +-- standard/
    +-- bids/
        +-- sub-01/
            +-- ses-01/
                +-- func/
                    +-- sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries_desc-conn.json
                    +-- sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries_desc-conn.mat
                    +-- sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-Gordon2014FreeSurferSubcortical_timeseries_desc-conn.pconn.nii
                    +-- sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries_desc-conn.json
                    +-- sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries_desc-conn.mat
                    +-- sub-01_ses-01_task-rest_frames-MaxGroup_bold_roi-HCP2016FreeSurferSubcortical_timeseries_desc-conn.pconn.nii
                    +-- sub-01_ses-01_task-rest_frames-MaxIndividual_bold_roi-Gordon2014FreeSurferSubcortical_timeseries_desc-conn.json
                    +-- ...
                    +-- sub-01_ses-01_task-rest_smoothing-15mm_frames-MaxGroup_bold_timeseries.dtseries.nii
                    +-- sub-01_ses-01_task-rest_smoothing-15mm_frames-MaxGroup_bold_timeseries_desc-conn.dconn.nii



BIDS Output File Types
~~~~~~~~~~~~~~~~~~~~~~

- **`.mat`** -> `ind_fconn` (<m,m>), single-session connectivity matrix
- **`.json`** -> metadata (subject, session, frames used, FD threshold, skip volumes)
- **`.pconn.nii`** -> parcellated connectivity, viewable in Connectome Workbench
- **`.dtseries.nii` / `.dconn.nii`** -> dense outputs (if `-make_dense_conns 1`)

.. note::
   Dense connectivity outputs are processed using the **same temporal mask**  
   and **settings** as the parcellated matrices.  
   The `.json` files from the parcellated outputs describe the parameters used.



**Summary:**

- **Standard output** = group-level `.mat` files per parcellation and frame-sampling scheme  
- **BIDS output** = per-session `.mat` + `.json` (and optional `.pconn.nii` / `.dconn.nii`)  
- **Dense outputs** mirror the parcellated processing and appear only if requested


Troubleshooting
===============

If you see the text listed below after starting up the containerized version of biceps_cmdln
and after several minutes no additional text has appeared, it is possible that the cache
directory created by matlab compiler runtime in your home directory is preventing the application
from moving forward. In this case look for a folder like /home/{InsertGroup}/{InsertUser}/.mcrCache9.12/
and delete it from your system. Alternatively you should be able to export a new MCR_CACHE_ROOT path
to the container during processing, and this may also solve the issue. ::

    LD_LIBRARY_PATH is .:/mcr_path/v912/runtime/glnxa64:/mcr_path/v912/bin/glnxa64:/mcr_path/v912/sys/os/glnxa64:/mcr_path/v912/sys/opengl/lib/glnxa64
