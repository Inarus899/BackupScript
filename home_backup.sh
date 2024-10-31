#!/bin/bash


# Number of files left in backup directory, includes log files
backup_number=10
home='_home.tar.gz'
today=$(date '+%Y%m%d')
home_directory='/home/alex'
backup_directory='backup'
logfile=$home_directory/$backup_directory/$today.log
offsite_backup='/mnt/c/Users/ama89/Desktop/backup'


# log info. This section is copied and pasted in most of my projects
# It is more complicated than needed for this example.
# This is the only part that is different than the video, the lines
# are rearranged for better readability.

# To undo our changes, on exit values 0-3, run quoted command
trap 'exec 2>&4 1>&3' 0 1 2 3
# Move inputs 3 and 4 to 1 and 2 to capture all output streams
exec 3>&1 4>&2
# sends all output to logfile, this is undone when program exits
exec 1>$logfile 2>&1

pushd $home_directory

# backup bundling
tar \
  --exclude=$backup_directory \
  -zcvf $backup_directory/$today$home \
  .bashrc \
  playground \
  scripts \
  .vimrc

# limit number of backups
  pushd $backup_directory
  file_count=$(ls | wc -l)
  if [ $file_count -ge $backup_number ]
  then
    ls -t | sed -e "1,${backup_number}d" | xargs -d '\n' rm
  fi
  popd

# transfering
if [ -d $offsite_backup ]
then
  rsync -azv $backup_directory/ $offsite_backup/
  echo "success"
else
  echo "ERROR: backup directory was not there"
fi

popd
