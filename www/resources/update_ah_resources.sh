#!/bin/bash

# update_ah_resources.sh
# v 0.1
# author : Hamilton G. Chua (ham@solutiongrove.com)
# date : 4/1/2009

# This bash script is meant to be executed in
#  packages/ajaxhelper/www/resources/.
# It is responsible for updating the javascript libraries
#  for the ajaxhelper package.

# The idea behind this file is to be able to easily update
#  the javascript libraries to the latest available versions
#  by running this script.

# NOTE :
# the following must be in your PATH
# - unzip
# - wget

# To execute :
#  ./update_ah_resources.sh

# CHANGELOG :
# 0.1 :
#  initially works with YUI

# ******* START **********

STAMP=`date +%m%d%y%H%M`

# create an archive folder
ARCHFOLDER="archive"-$STAMP
mkdir $ARCHFOLDER

# create a temporary folder
TMPFOLDER="tmp"-$STAMP
mkdir $TMPFOLDER


# ****** YUI ************

# move yui to the archive folder
mv yui $ARCHFOLDER

# use wget to fetch YUI
# and put it into the TMPFOLDER
YUIZIP="yui_2.7.0b.zip"
cd $TMPFOLDER
wget http://developer.yahoo.com/yui/download/

# unzip the downloaded file
unzip $YUIZIP

cd yui/

# copy build/ in www/resources as yui
mv build ../../yui

# ****** EXT2 *************

# move ext2 to the archive folder
cd ../../
mv ext2 $ARCHFOLDER

# use wget to fetch ExtJS 2
# and put it into the TMPFOLDER
EXT2ZIP="ext-2.2.1.zip"
cd $TMPFOLDER
mkdir ext2
cd ext2
wget http://extjs.com/products/extjs/download.php?dl=extjs221

# unzip the downloaded file
unzip $EXT2ZIP
rm $EXT2ZIP
cd ../

# copy ext2/ in www/resources as ext2
mv ext2 ../
cd ../

# ****** CLEANUP **********

# delete temporary folder

rm -rf $TMPFOLDER