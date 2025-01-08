#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 T1.nii.gz FLAIR.nii.gz OUTPUT_DIR (to store the newly created files)"
    exit 1
fi

# Assign input arguments to variables
delete_if_exists() {
    if [ -f "$1" ]; then
        echo "Deleting existing file: $1"
        rm "$1"
    fi
}

OUTPUT_DIR=$3
mkdir -p "$OUTPUT_DIR"

T1_FILE="$OUTPUT_DIR/T1_LPI.nii.gz"
FLAIR_FILE="$OUTPUT_DIR/FLAIR_RPI.nii.gz"

delete_if_exists $T1_FILE
delete_if_exists $FLAIR_FILE

3dresample -orient LPI -prefix $T1_FILE -input "$1"
# 3drefit -deoblique $T1_FILE

3dresample -orient RPI -prefix $FLAIR_FILE -input "$2"
# 3drefit -deoblique $FLAIR_FILE

output=$(3dinfo $FLAIR_FILE)

# Extract the number of voxels from each extent line
r_to_l=$(echo "$output" | grep "R-to-L extent" | sed -E 's/.*\[ *([0-9]+) voxels\].*/\1/')
a_to_p=$(echo "$output" | grep "A-to-P extent" | sed -E 's/.*\[ *([0-9]+) voxels\].*/\1/')
i_to_s=$(echo "$output" | grep "I-to-S extent" | sed -E 's/.*\[ *([0-9]+) voxels\].*/\1/')


# Display the input files
echo "Proper position images:"
echo "T1 File: $T1_FILE"
echo "FLAIR File: $FLAIR_FILE"

TEMP_T1="$OUTPUT_DIR/T1_temp.nii.gz"
delete_if_exists $TEMP_T1

3dresample -orient RPI -prefix $TEMP_T1 -dxyz $r_to_l $a_to_p $i_to_s -input "$T1_FILE"

# Check if the flirt command was successful
if [ $? -eq 0 ]; then
    echo "Registration completed successfully. Output saved as T1.nii.gz."
else
    echo "Registration failed."
    exit 1
fi


delete_if_exists "$OUTPUT_DIR/FLAIR_N4.nii.gz"
delete_if_exists "$OUTPUT_DIR/3DT1_N4.nii.gz"

# Run N4 Bias Field Correction with default parameters for human brain T1w images
N4BiasFieldCorrection -i $FLAIR_FILE -o "$OUTPUT_DIR/FLAIR_N4.nii.gz"
N4BiasFieldCorrection -i $T1_FILE -o "$OUTPUT_DIR/3DT1_N4.nii.gz"

T1="$OUTPUT_DIR/T1.nii.gz"
flirt -in "$OUTPUT_DIR/3DT1_N4.nii.gz" -ref "$OUTPUT_DIR/FLAIR_N4.nii.gz" -out "$T1"

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Bias field for flair correction completed successfully."
else
    echo "Bias field for flair correction failed."
fi

mv "$OUTPUT_DIR/FLAIR_N4.nii.gz" "$OUTPUT_DIR/FLAIR.nii.gz"

# Exit the script
exit 0