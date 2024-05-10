#/bin/bash

min=$1
merge=$2
TMP1=$(mktemp --tmpdir=".")

cut -f 11 $merge >> "${TMP1}"
grep -i -f $min $TMP1 >> min_core_found.txt
grep -i -v -f "min_core_found.txt" $min >> min_core_missing.txt
rm tmp.*
