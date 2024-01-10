#!/usr/bin/env python3
import glob, argparse, os, json
import numpy as np
from localizer_alignment import localizer_alignment_anat_update_osprey

#Configure the commands that can be fed to the command line
parser = argparse.ArgumentParser()
parser.add_argument("bids_dir", help="The path to the BIDS directory for your study (this is the same for all subjects)", type=str)
parser.add_argument("output_dir", help="The path to the folder where outputs will be stored (this is the same for all subjects)", type=str)
parser.add_argument("analysis_level", help="Should always be participant", type=str)
parser.add_argument("json_settings", help="The path to the subject-agnostic JSON file that will be used to configure processing settings", type=str)

parser.add_argument('--participant_label', '--participant-label', help="The name/label of the subject to be processed (i.e. sub-01 or 01)", type=str)
parser.add_argument('--segmentation_dir', '--segmentation-dir', help="The path to the folder where segmentations are stored (this is the same for all subjects)", type=str)
parser.add_argument('--session_id', '--session-id', help="OPTIONAL: the name of a specific session to be processed (i.e. ses-01)", type=str)
parser.add_argument('--localizer_registration', '--localizer-registration', help="OPTIONAL: Use localizer to register anatomical images to MRS scan. Also requires the use of --segmentation_dir argument", action='store_true')
parser.add_argument('--localizer_search_term', '--localizer-search-term', help="OPTIONAL: The search term to use to find localizer images (i.e. *localizer*)", type=str, default='*localizer*.nii*')
parser.add_argument('--preferred_anat_modality', '--preferred-anat-modality', help="OPTIONAL: The preferred modality to use for anatomical images (i.e. T1w or T2w)", type=str, default='T1w')
parser.add_argument('--terms_not_allowed_in_anat', nargs='+', help='One or more terms (seperated by spaces) that are not allowed in the file name of high-res anatomical reference images. Useful for getting rid of localizer images that can be confused for high-res anatomical scans. example - "--terms_not_allowed_in_anat mrs ax coronal"', required=False)
args = parser.parse_args()

compiled_executable_path = os.getenv("EXECUTABLE_PATH")
mcr_path = os.getenv("MCR_PATH")
basis_sets_path = os.getenv("BASIS_SETS_PATH")