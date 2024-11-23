#!/bin/sh

write_msg()
{
  echo $(date +"20%y-%m-%d %H:%M:%S") $1
}

duration()
{
DURATION=$2
HOUR=$((DURATION/3600))
HOURINSEC=$((HOUR*3600))
DURATION=$((DURATION-HOURINSEC))
MINUTE=$(((DURATION/60)))
SECOND=$((DURATION%60))
write_msg "$1 finished took $HOUR hours, $MINUTE minutes, $SECOND seconds"
}

# ===== MAIN PROGRAM =====
BASEDIR=$(dirname "$0")
CONFIG="$BASEDIR/rclone.conf"
SOURCE=/mnt/atlas_cc
DEST="B2:jenkinshome-atlas-cluster-backup"
THREADS=24

START=$(date +%s)

write_msg "BackBlaze Atlas Cluster Remote Backup Sync"
write_msg "rclone script running from $BASEDIR"
write_msg "Starting rclone of $SOURCE to B2:$DEST"
CMD="rclone sync --stats-one-line --stats=30s --transfers $THREADS --checkers $THREADS --config $CONFIG $SOURCE $DEST"
#write_msg "using command: $CMD"

#Execute the command as prepared
$CMD

#Report Back the results
END=$(date +%s)
duration "rclone" $((END-START))