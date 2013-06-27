Strata Analytics Demo
=====================

This is a demo application to perform analytics using random data generated using Hive & R

**Files Description:**

* `random_hive.rb` => generates data required for the analytics
* `hive_shema.q` => contains hive schema to impose on the dataset
* `0_demo_grouping.q` => hive script to parse random data & make transformations on data
* `gen_dtree.R` => R script to generate decision tree
* `gen_dtree.Rout` => sample decision tree from R
* `run.sh` => wrapper shell script to execute the workflow

Usage:
-----

```
# to generate data
./run.sh --gen

# to kick off analytics
./run.sh
```