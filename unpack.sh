#!/bin/bash
#this script will run through json files and extract them one by one
for f in *.tar.gz
do tar zxvf "$f" 
done
