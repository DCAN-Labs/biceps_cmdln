#!/usr/bin/env python3

import argparse
import subprocess
import os
import sys
import scipy.io

# Known valid BICEPS flags and their expected types
VALID_FLAGS = {
    "-out_dir": str,
    "-save_bids": int,
    "-attempt_pconn": int,
    "-save_timeseries": int,
    "-fd": float,
    "-n_skip_vols": int,
    "-minutes": float,
    "-outlier": int,
    "-validate_frame_counts": int,
    "-wb_command_path": str,
    "-make_dense_conns": int,
    "-dtseries_smoothing": float,
    "-left_hem_surface": str,
    "-right_hem_surface": str,
    "-custom_dtvar_folder": str,
}

DEFAULTS = {
    "-wb_command_path": "/common/software/install/manual/workbench/2.0.1-rocky8/bin/wb_command",
}

def build_matlab_command(input_list, flags):
    args = [f"'{input_list}'"]
    for k, v in flags.items():
        val = f"'{v}'" if isinstance(v, str) else str(v)
        args.append(f"'{k}'")
        args.append(val)
    args_str = ", ".join(args)

    out_dir = flags["-out_dir"]
    rename_call = f"rename_biceps_files('{out_dir}')"

    return f"biceps_cmdln({args_str}); {rename_call}; exit;"

def parse_flags(flag_args):
    flags = {}
    i = 0
    while i < len(flag_args):
        if not flag_args[i].startswith('-'):
            raise ValueError(f"Expected flag starting with '-', got '{flag_args[i]}'")
        key = flag_args[i]
        if key not in VALID_FLAGS:
            raise ValueError(f"Invalid flag: '{key}'. Must be one of: {', '.join(VALID_FLAGS.keys())}")

        if i + 1 >= len(flag_args):
            raise ValueError(f"Missing value for flag '{key}'")
        raw_value = flag_args[i + 1]

        expected_type = VALID_FLAGS[key]
        try:
            value = expected_type(raw_value)
        except ValueError:
            raise ValueError(f"Invalid value for {key}. Expected {expected_type.__name__}, got '{raw_value}'")

        flags[key] = value
        i += 2

    # Inject defaults
    for key, default_value in DEFAULTS.items():
        if key not in flags:
            flags[key] = default_value

    # Ensure -out_dir is provided
    if "-out_dir" not in flags:
        raise ValueError("Missing required flag: '-out_dir'")

    return flags

def main():
    parser = argparse.ArgumentParser(
        description="Run biceps_cmdln from Python via MATLAB with validated flags"
    )
    parser.add_argument("input_list", help="Path to input folder or file list")
    parser.add_argument("flags", nargs=argparse.REMAINDER,
                        help="Key-value flag arguments for biceps_cmdln, required flag -out_dir")

    args = parser.parse_args()

    try:
        flags = parse_flags(args.flags)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    # If -custom_dtvar_folder is not provided, check variance files
    if "-custom_dtvar_folder" not in flags:
        check_command = [
            "matlab",
            "-nodesktop",
            "-nosplash",
            "-r",
            (
                f"cd('{os.getcwd()}'); "
                f"addpath(genpath('{os.getcwd()}/biceps_cmdln')); "
                f"success=check_and_patch_variance('{args.input_list}'); "
                f"save('check_result.mat','success'); exit;"
            )
        ]

        print("Checking for missing variance files...")
        subprocess.run(check_command, check=True)

        mat_result = scipy.io.loadmat("check_result.mat")
        success_flag = mat_result.get("success", [[1]])[0][0]
        
        os.remove("check_result.mat")

        if success_flag == 0:
            custom_dtvar_location=os.path.join(os.getcwd(), "dtvariance_files")
            flags["-custom_dtvar_folder"] = custom_dtvar_location
            print("Variance patch triggered, setting -custom_dtvar_folder to", custom_dtvar_location)

    # Build and run the main MATLAB command
    matlab_call = build_matlab_command(args.input_list, flags)

    matlab_command = [
        "matlab",
        "-nodesktop",
        "-nosplash",
        "-r",
        f"cd('{os.getcwd()}'); addpath(genpath('{os.getcwd()}/biceps_cmdln')); {matlab_call}"
    ]

    print("Running MATLAB command:")
    print(" ".join(matlab_command))
    subprocess.run(matlab_command, check=True)

if __name__ == "__main__":
    main()
