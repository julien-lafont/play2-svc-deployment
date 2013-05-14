#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load Configuration
source "$DIR/config.properties" || exit 1

#
# Helpers
#
red="\033[31m"
reset="\033[0m"
green="\033[32m"
yellow="\033[33m"
cyan="\033[36m"

ask() { # Read a value with default
  local default=$1
  read -p "(default: $default) " name
  name=${name:-$default}
  echo $name
}

#
# Check configuration
#

# Check if all variables are defined?
: ${rep?not defined}
: ${service?not defined}
: ${jenkinsBuild?not defined}
: ${filename?not defined}
: ${jenkinsUser?not defined}
: ${jenkinsToken?not defined}
: ${log?not defined}

# Folders are valid?
if [ ! -d "$service" ]; then echo "Service $service not found"; exit 1; fi;
if [ ! -d "$rep" ]; then echo "Base directory $rep not found"; exit 1; fi;
if [ ! -d "$rep/app" ]; then echo "App directory $rep/app not found"; exit 1; fi;
if [ ! -d "$rep/delivery" ]; then echo "Delivery directory $rep/delivery not found"; exit 1; fi;

# Extract data
appuser=$(ls -l $rep | grep "app" | awk '{ print $3 }')
appgroup=$(ls -l $rep | grep "app" | awk '{ print $3 }')
d=`date +"%Y-%m-%d-%Hh%M"`

#
# Summary
#
echo ""
echo -e "Play2.X Deployment -$red Please double check the configuration! $reset"
echo ""
echo -e "  Directory       >$cyan $rep $reset"
echo -e "  Service         >$cyan $service $reset"
echo -e "  User-Group      >$cyan $appuser:$appgroup $reset"
echo -ne "  Build Jenkins   > "; jenkinsRealBuild=$(ask $jenkinsBuild);
echo ""
echo -e "If everything is OK: $green<Enter>$reset, otherwise: $red<CTRL+C>$reset"

read pause

#
# Deploying
#
echo -ne "- Preparing delivery directory in $d: "
cd $rep/delivery || exit 1
rm -Rf ./$d 2>/dev/null                           # Empty if already exist
mkdir $d || exit 1                                # Create new directory with the current date
cd $d
echo "OK"

echo -ne "- Downloading last release of $jenkinsBuild/$filename: "
wget --auth-no-challenge --http-user=$jenkinsUser --http-password=$jenkinsToken -q \
  "http://build-01.znx.fr/job/$jenkinsRealBuild/lastSuccessfulBuild/artifact/dist/$filename" || exit 1
echo "OK"

echo -ne "- Preparing server for new deployment: "
unzip $filename > /dev/null || exit 1             # Unzip app in current  folder
foldername=$(find -mindepth 1 -maxdepth 1 -type d | sed 's/\.\/*//') # Get the name of the project
cp -R $rep/conf .                                 # Backup current configuration
cd $foldername                                    # Go inside the unziped dir
echo "OK"

echo -ne "- Stopping server: "
svc -d $service                                   # Stop server and wait a little time
sleep 2
echo "OK"

echo -ne "- Installing new app: "
rm -Rf $rep/app/* || exit 1                       # Remove app directory
mv * $rep/app/ || exit 1                          # Move app files to app folder
echo "OK"

echo -ne "- Configuring new app: "
chown -R "$appuser:$appgroup" $rep/app/ || exit 1 # Chown the app to good user:group
chmod u+x $rep/app/start || exit 1                # Make start executable
echo "OK"

echo -ne "- Starting new app: "
svc -u $service                                   # Restart server
echo "OK"

echo -ne "- Cleaning: "
rmdir "$rep/delivery/$d/$foldername"              # Remove empty dir
echo "OK"

echo ""
echo -ne "$green"; echo -e "Deploy finished with success! $reset"
echo "Check logs at: $log"
echo ""

exit 0