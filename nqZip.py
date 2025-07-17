#!/usr/bin/env python3

# Quick script to add patient sex and age to dicom files
# Author: Krisanne Litinas and Trevor Exell

import os
import sys
import shutil

try:
    import pydicom as dicom
except:
    import dicom as dicom

def check_fields(DCMFILE, OUTDIR, ABSPATH):
    ds = dicom.read_file(DCMFILE)
    if ds.PatientAge != '000Y' and ds.PatientSex:
        print('Age and Sex already present: ' + ds.PatientAge
              + ' ' + ds.PatientSex)
        print('Zipping to ' + OUTDIR)
        shutil.make_archive(OUTDIR, 'zip', ABSPATH)
        sys.exit(0)
        
    
def update_fields(DCMFILE,PAT_SEX,PAT_AGE):
    ds = dicom.read_file(DCMFILE)
    dsOut = ds
    
    dsOut.PatientSex = PAT_SEX.upper()
    dsOut.PatientAge = '{:03d}Y'.format(int(PAT_AGE))

    return dsOut


if len(sys.argv) != 2:
    print('Usage: dcm_neuroquant.py <DCMDIR>')
    sys.exit(0)
'''
INPUT = sys.argv[1]
PAT_SEX = sys.argv[2]
PAT_AGE = sys.argv[3]

if PAT_SEX.upper() not in ['M','F']:
    print("Enter 'M' or 'F' for gender.")
    sys.exit(0)
'''
INPUT = sys.argv[1]
if os.path.isdir(INPUT):
    ABSPATH = os.path.abspath(INPUT)
    os.chdir(INPUT)
    DCMFILES = os.listdir('.')
    if not DCMFILES:
        print('No files found in ' + INPUT)
        sys.exit(0)

    PDIR = os.path.dirname(ABSPATH)
    BASEDIR = os.path.basename(INPUT)
    OUTDIR = os.path.join(PDIR, 'neuroquant_' + BASEDIR)

    check_fields(DCMFILES[0], OUTDIR, ABSPATH)
    PAT_SEX = input('Enter M or F for sex: ')
    PAT_AGE = input('Enter age in years: ')
    if PAT_SEX.upper() not in ['M','F'] or not PAT_AGE.isdigit():
        print('Invalid input')
        sys.exit(0)
        
    if not os.path.exists(OUTDIR):
        os.makedirs(OUTDIR)

    for DCMFILE in DCMFILES:
        dsOut = update_fields(DCMFILE,PAT_SEX,PAT_AGE)
        FILEOUT = OUTDIR + '/neuroquant_' + DCMFILE

        # Write the file
        dicom.write_file(FILEOUT,dsOut)
        
# Zip the folder
print('Zipping to ' + OUTDIR)
shutil.make_archive(OUTDIR, 'zip', OUTDIR)

