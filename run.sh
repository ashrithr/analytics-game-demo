#!/usr/bin/env bash

# =
# Desc: Script to demo analytics for strata
# Date: Feb 23, 2013
# Version: 1.0
# Author: Ashrith (ashrith at cloudwick dot com)
# =
RANDOM_GEN="${PWD}/random_hive.rb"
HIVE_LOAD_SCRIPT="${PWD}/hive_schema.q"
HIVE_FINAL_SCRIPT="/${PWD}/0_demo_grouping.q"
R_SCRIPT="${PWD}/gen_dtree.R"
R_INPUT="/tmp/1_demo_data.tsv"
R_OUTPUT="/tmp/gen_dtree.Rout"

if [ "$(id -u)" != "0" ]; then
  echo "You must have Admin privileges to run this script"
  exit 1
fi

command -v hive >/dev/null 2>&1 || { echo >&2 "I require hive but it's not installed. Aborting."; exit 1; }
command -v R >/dev/null 2>&1 || { echo >&2 "I require R but it's not installed. Aborting."; exit 1; }

if [[ ! -f $RANDOM_GEN && ! -f $HIVE_LOAD_SCRIPT && ! -f $HIVE_FINAL_SCRIPT ]]; then
 echo "Required files not found ! (change the variables in ${basename $0} or place them in correct paths)"
 exit 1
fi

if [ $1 == "gen" ]; then
  echo "Generating data required for Analytics"
  ruby random_hive.rb --lines=50000 -m -p /tmp || { echo "cannot load ruby 1.9.3" ; exit 1; }
fi

echo "Loading data into hive"
cp ${HIVE_LOAD_SCRIPT} /tmp # because hive need permissions for now put in /tmp
cd /tmp && sudo -u hdfs hive -f `basename ${HIVE_LOAD_SCRIPT}` && echo "Loading data sucessful" || { echo "Loading data failed" ; exit 1; }

echo "Transforming data set"
cp ${HIVE_FINAL_SCRIPT} /tmp
cd /tmp && sudo -u hdfs hive -f `basename ${HIVE_FINAL_SCRIPT}` && echo "Final dataset generated" || { echo "Final dataset not genereated!, Something went wrong."; exit 1; }

echo "Loading transformed data from HDFS to Local-FS"
echo -e "gender\tage\tcountry\tfriend_count\tlifetime\tcity_played\tpictionary_played\tscramble_played\tsniper_played\tpaid" > ${R_INPUT}
cd /tmp && sudo -u hdfs hive -e "select * from datafile_table;" > ${R_INPUT}
[ $? -ne 0 ] && { echo "Failed loading data from HDFS to Local-FS"; exit 1; }

echo "Running R on ${R_INPUT}"
R CMD BATCH ${R_SCRIPT}
if [ $? -eq 0 ]; then
 echo "Decision tree generated to ${R_OUTPUT}"
 echo "Contents of ${R_OUTPUT}"
 cat ${R_OUTPUT}
else
 echo "Somethig went wrong while generating decision tree" && exit 1
fi

exit 0
