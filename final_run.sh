#!/usr/bin/env bash

# =
# Script to run everything for analytics
# =
RANDOM_GEN="/root/random_hive.rb"
HIVE_LOAD_SCRIPT="/tmp/hive_schema.q"
HIVE_FINAL_SCRIPT="/tmp/0_demo_grouping.q"
R_SCRIPT="/tmp/gen_dtree.R"
R_INPUT="/tmp/1_demo_data.tsv"
R_OUTPUT="/tmp/gen_dtree.Rout"
if [ "$(id -u)" != "0" ];
then
  echo "You must have Admin privileges to run this script"
  exit 1
fi

if [[ ! -f $RANDOM_GEN && ! -f $HIVE_LOAD_SCRIPT && ! -f $HIVE_FINAL_SCRIPT ]]; then
 echo "Files are not found, change the variables or place them in correct paths"
 exit 1
fi

if [ $1 == "gen" ]; then
  echo "Generating data required for Analytics"
  ruby random_hive.rb --lines=50000 -m || ( echo "cannot load ruby 1.9.3" ; exit 1 )
fi

echo "Loading data into hive"
cd /tmp && sudo -u hdfs hive -f $HIVE_LOAD_SCRIPT && echo "Loading data sucessful" || ( echo "Loading data failed" ; exit 1 )

echo "Modiying data set"
cd /tmp && sudo -u hdfs hive -f $HIVE_FINAL_SCRIPT && echo "Final dataset generated" || ( echo "Final dataset not genereated!"; exit 1 )

echo "Loading data to LFS"
echo -e "gender\tage\tcountry\tfriend_count\tlifetime\tcity_played\tpictionary_played\tscramble_played\tsniper_played\tpaid" > ${R_INPUT}
cd /tmp && sudo -u hdfs hive -e "select * from datafile_table;" >> ${R_INPUT}

echo "Running R on ${R_INPUT}"
R CMD BATCH ${R_SCRIPT}
if [ $? -eq 0 ]; then
 echo "Decision tree generated"
 cat ${R_OUTPUT}
else
 echo "somethig went wrong gen decision tree" && exit 1
fi
