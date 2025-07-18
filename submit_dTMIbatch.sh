#!/bin/bash

# Quick script to submit batch to do copy job on the cluster

# Author: Trevor Exell, adapted from Krisanne Litinas template

# Need file that lists the subjects to work on called subj2do.txt in this scripts  directory

SCRIPTSDIR=$(dirname .)
SUBJECTLISTFILE=${SCRIPTSDIR}/subjs2do.txt
SUBJS=$(cat $SUBJECTLISTFILE)

for SUBJNAME in $SUBJS
do
  MY_JOB_NAME=$SUBJNAME
  cp ${SCRIPTSDIR}/dTMI_stub.sbat ${MY_JOB_NAME}.sbat
  sed -i "s/MY_JOB_NAME/${MY_JOB_NAME}/" ${MY_JOB_NAME}.sbat
  egrep ${MY_JOB_NAME} ${MY_JOB_NAME}.sbat
  sbatch ${MY_JOB_NAME}.sbat
  sleep 1
done