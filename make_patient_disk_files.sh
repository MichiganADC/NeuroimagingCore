#!/usr/bin/env bash

# Quick script to make .jpgs and anon. dicoms for burning to a disk.
# Author: Krisanne Litinas

if [ -z "${1}" ]
then
  echo -e "\n$(basename $0): creates .jpgs and anon. dicoms for given exam directory."
  echo "Requires python with dicom/pydicom package installed and dcmj2pnm (part of dcmtk)" 
  echo -e "\nUsage: \n\t $(basename $0) <EXAMDIR> <SERIES NUMBERS>\n"
  exit 0
fi

# Configure path
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export PATH=$PATH:$SCRIPTPATH

SUBJDIR=$1

# optional inputs of series
DCMSERIESNUMS=${@:2}
DCMDIRS=""
for DIR in ${DCMSERIESNUMS}
do
	DIRNAME=$(printf "s%05d" $DIR)
	DCMDIRS="${DCMDIRS} ${DIRNAME}"	
done

OUTDIR="$(basename $SUBJDIR)_structurals"
mkdir $OUTDIR
PDIR=$(pwd)

echo -e "\nOutputs will be in ${OUTDIR}."
if [ ! -d $SUBJDIR/dicom ]
then
  TGZ=$SUBJDIR/dicom.tgz
  if [ ! -f "${TGZ}" ]
  then
      echo -e "\nNo dicom or dicom.tgz file found in ${SUBJDIR}!"
      exit 1
  fi

  echo -e "\nFound dicoms in ${TGZ}, extracting with: \n\n\ttar -xzf ${TGZ} --directory ${OUTDIR}/"
  tar -xzf $TGZ --directory $OUTDIR/
else
  echo -e "\nFound dicom directory in ${SUBJDIR}, copying temporarily to ${OUTDIR}"
  cp -r  $SUBJDIR/dicom $OUTDIR/
fi


# Find which series dirs to use.
REFFILE=$SUBJDIR/raw/raw_data_cross_reference.dat

if [ -z "${DCMDIRS}" ]
then
	DCMDIRS=$(sort $REFFILE | awk '{if ($4 ~ "^t") print $1; if ($4 ~ "ORIG") print $1}')
fi

for DCMDIR in $DCMDIRS
do
  SEDESC=$(sort $REFFILE | awk -v dir=$DCMDIR '{if ($1 == dir) print $4;}')
  echo -e "\nWorking on ${DCMDIR} (${SEDESC})..."
  cd $OUTDIR
  mkdir $SEDESC

  echo -e "\n\tCreating jpegs."
  dcm2jpeg.sh dicom/${DCMDIR} $SEDESC/

  echo -e "\n\tAnonymising dicoms."
  dcm_anon.py dicom/${DCMDIR}
  mv dicom/anon_${DCMDIR} $SEDESC/anon_dicom
  cd $PDIR
done

rm -rf $OUTDIR/dicom
