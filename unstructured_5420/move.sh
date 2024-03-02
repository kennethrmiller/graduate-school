#!/bin/bash
# This should move the old files to a new folder
for f in *tar.gz
do
mv "$f" ~/work/week7/cwl-data/data/structured/old_files
done
for f in *tar
mv "$f" ~/work/week7/cwl-data/data/structured/old_files
done
