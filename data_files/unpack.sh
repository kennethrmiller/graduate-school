#!/bin/bash
#this script will run through json files and extract them one by one
for f in /work/unstructured_5420/zipped_files/*.tar.gz
do tar zxvf "$f" 
done
